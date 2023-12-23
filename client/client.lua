local vehicleHUDActive = false
local playerHUDActive = false
local hunger = 100
local thirst = 100

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(500)
    startHUD()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(500)
    startHUD()
end)

function startHUD()
    if not IsPedInAnyVehicle(cache.ped) then DisplayRadar(false) else DisplayRadar(true) SendNUIMessage({ action = 'showVehicleHUD' }) end
    TriggerEvent('hud:client:LoadMap')
    SendNUIMessage({ action = 'showPlayerHUD' })
    playerHUDActive = true
    loadPlayerNeeds()
end

local lastCrossroadUpdate = 0
local lastCrossroadCheck = {}

function getCrossroads(vehicle)
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
        if not IsPauseMenuActive() then
            if not playerHUDActive then SendNUIMessage({ action = 'showPlayerHUD' }) end
            if not IsEntityInWater(player) then stamina = (100 - GetPlayerSprintStaminaRemaining(playerId)) end
            if IsEntityInWater(player) then stamina = (GetPlayerUnderwaterTimeRemaining(playerId) * 10) end
            SendNUIMessage({
                action = 'updatePlayerHUD',
                health = (GetEntityHealth(cache.ped) - 100),
                armor = GetPedArmour(cache.ped),
                thirst = thirst,
                hunger = hunger,
                stamina = stamina,
                voice = LocalPlayer.state['proximity'].distance,
                talking = NetworkIsPlayerTalking(PlayerId()),
            })
            if IsPedInAnyVehicle(cache.ped) then
                if not vehicleHUDActive then
                    vehicleHUDActive = true
                    DisplayRadar(true)
                    TriggerEvent('hud:client:LoadMap')
                    SendNUIMessage({ action = 'showVehicleHUD' })
                end
                local crossroads = getCrossroads(cache.vehicle)
                SendNUIMessage({
                    action = 'updateVehicleHUD',
                    speed = math.ceil(GetEntitySpeed(cache.vehicle) * Config.speedMultiplier),
                    fuel = math.ceil(GetVehicleFuelLevel(cache.vehicle)),
                    gear = GetVehicleCurrentGear(cache.vehicle),
                    street1 = crossroads[1],
                    street2 = crossroads[2],
                    direction = GetDirectionText(GetEntityHeading(cache.vehicle)),
                })
            else if vehicleHUDActive then vehicleHUDActive = false DisplayRadar(false) SendNUIMessage({ action = 'hideVehicleHUD' }) end end
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
    if ((heading >= 0 and heading < 45) or (heading >= 315 and heading < 360)) then
        return "N"
    elseif (heading >= 45 and heading < 135) then
        return "W"
    elseif (heading >=135 and heading < 225) then
        return "S"
    elseif (heading >= 225 and heading < 315) then
        return "E"
    end
end

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
    thirst = newThirst
    hunger = newHunger
end)

RegisterNetEvent("hud:client:LoadMap", function()
    Wait(100)
    local defaultAspectRatio = 1920/1080
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local safezone = GetSafeZoneSize()
    local aspectRatio = (resolutionX-(safezone/2))/(resolutionY-(safezone/2))
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then minimapOffset = ((defaultAspectRatio-aspectRatio)/3.6)-0.019 end
    RequestStreamedTextureDict("squaremap", false)
    if not HasStreamedTextureDictLoaded("squaremap") then Wait(150) end
    SetMinimapClipType(0)
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
    SetMinimapComponentPosition('minimap', 'L', 'B', -0.0100 + minimapOffset, -0.010, 0.180, 0.258)
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.0 + minimapOffset, 0.0, 0.128, 0.20)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.00 + minimapOffset, 0.065, 0.252, 0.338)
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetMinimapClipType(0)
    SetRadarBigmapEnabled(true, false)
    Wait(50)
    SetRadarBigmapEnabled(false, false)
end)