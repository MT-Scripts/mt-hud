local vehicleHUDActive = false
local playerHUDActive = false
local hunger = 100
local thirst = 100
local seatbeltOn = false
local showAltitude = false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(500)
    StartHUD()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(500)
    StartHUD()
end)

function StartHUD()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, true) then
        DisplayRadar(false)
    else
        DisplayRadar(true)
        SendNUIMessage({ action = 'showVehicleHUD' })
    end
    TriggerEvent('hud:client:LoadMap')
    SendNUIMessage({ action = 'showPlayerHUD' })
    playerHUDActive = true
    LoadPlayerNeeds()
end

local lastCrossroadUpdate = 0
local lastCrossroadCheck = {}

function GetCrossroads(vehicle)
    local updateTick = GetGameTimer()
    if updateTick - lastCrossroadUpdate > 1500 then
        local pos = GetEntityCoords(vehicle)
        local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
        lastCrossroadUpdate = updateTick
        lastCrossroadCheck = { GetStreetNameFromHashKey(street1), GetStreetNameFromHashKey(street2) }
    end
    return lastCrossroadCheck
end

CreateThread(function()
    while true do
        local stamina = 0
        local playerId = PlayerId()
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if not IsPauseMenuActive() then
            if not playerHUDActive then SendNUIMessage({ action = 'showPlayerHUD' }) end
            if not IsEntityInWater(player) then stamina = (100 - GetPlayerSprintStaminaRemaining(playerId)) end
            if IsEntityInWater(player) then stamina = (GetPlayerUnderwaterTimeRemaining(playerId) * 10) end
            SendNUIMessage({
                action = 'updatePlayerHUD',
                health = (GetEntityHealth(ped) - 100),
                armor = GetPedArmour(ped),
                thirst = thirst,
                hunger = hunger,
                stamina = stamina,
                voice = LocalPlayer.state['proximity'].distance,
                radio = LocalPlayer.state['radioActive'],
                talking = NetworkIsPlayerTalking(PlayerId()),
            })
            if IsPedInAnyHeli(ped) or IsPedInAnyPlane(ped) then
                if not vehicleHUDActive then
                    vehicleHUDActive = true
                    DisplayRadar(true)
                    TriggerEvent('hud:client:LoadMap')
                    SendNUIMessage({ action = 'showVehicleHUD' })
                end
                local crossroads = GetCrossroads(vehicle)
                SendNUIMessage({
                    action = 'updateVehicleHUD',
                    speed = math.ceil(GetEntitySpeed(vehicle) * Config.speedMultiplier),
                    fuel = math.ceil(GetVehicleFuelLevel(vehicle)),
                    gear = GetVehicleCurrentGear(vehicle),
                    street1 = crossroads[1],
                    street2 = crossroads[2],
                    direction = GetDirectionText(GetEntityHeading(vehicle)),
                    seatbelt = seatbeltOn,
                    altitude = math.ceil(GetEntityCoords(ped).z * 0.5),
                    altitudetexto = "ALT"
                })
            else if IsPedInAnyVehicle(ped, true) then
                if not vehicleHUDActive then
                    vehicleHUDActive = true

                    DisplayRadar(true)
                    TriggerEvent('hud:client:LoadMap')
                    SendNUIMessage({ action = 'showVehicleHUD' })
                end
                local crossroads = GetCrossroads(vehicle)
                SendNUIMessage({
                    action = 'updateVehicleHUD',
                    speed = math.ceil(GetEntitySpeed(vehicle) * Config.speedMultiplier),
                    fuel = math.ceil(GetVehicleFuelLevel(vehicle)),
                    gear = GetVehicleCurrentGear(vehicle),
                    street1 = crossroads[1],
                    street2 = crossroads[2],
                    direction = GetDirectionText(GetEntityHeading(vehicle)),
                    seatbelt = seatbeltOn,
                    altitude = "",
                    altitudetexto = ""
                })
            else
                if vehicleHUDActive then
                    vehicleHUDActive = false
                    DisplayRadar(false)
                    SendNUIMessage({ action = 'hideVehicleHUD' })
                end
            end
        else
            vehicleHUDActive = false
            DisplayRadar(false)
            SendNUIMessage({ action = 'hideVehicleHUD' })
            SendNUIMessage({ action = 'hidePlayerHUD' })
            playerHUDActive = false
        end
        SetBigmapActive(false, false)
        SetRadarZoom(1000)
        Wait(Config.updateDelay)
    end
end)

function GetDirectionText(heading)
    if ((heading >= 0 and heading < 30) or (heading >= 330 and heading < 360)) then
        return 'N'
    elseif (heading >= 30 and heading < 60) then
        return 'NW'
    elseif (heading >= 60 and heading < 120) then
        return 'W'
    elseif (heading >= 120 and heading < 160) then
        return 'SW'
    elseif (heading >= 160 and heading < 210) then
        return 'S'
    elseif (heading >= 210 and heading < 240) then
        return 'SE'
    elseif (heading >= 240 and heading < 310) then
        return 'E'
    elseif (heading >= 310 and heading < 330) then
        return 'NE'
    end
end

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
    thirst = newThirst
    hunger = newHunger
end)

RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function()
    seatbeltOn = not seatbeltOn
    SendNUIMessage({ action = 'setSeatbelt', seatbelt = seatbeltOn })
end)

RegisterNetEvent('hud:client:ToggleAirHud', function()
    showAltitude = not showAltitude
end)

RegisterNetEvent('hud:client:LoadMap', function()
    Wait(100)
    local defaultAspectRatio = 1920 / 1080
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local safezone = GetSafeZoneSize()
    local aspectRatio = (resolutionX - (safezone / 2)) / (resolutionY - (safezone / 2))
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.019 end
    RequestStreamedTextureDict('squaremap', false)
    if not HasStreamedTextureDictLoaded('squaremap') then Wait(150) end
    SetMinimapClipType(0)
    AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'squaremap', 'radarmasksm')
    AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'squaremap', 'radarmasksm')
    SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.0 + minimapOffset, 0.0, 0.128, 0.20)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.00 + minimapOffset, 0.065, 0.252, 0.338)
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetMinimapClipType(0)
    SetRadarBigmapEnabled(true, false)
    Wait(50)
    SetRadarBigmapEnabled(false, false)
end)
