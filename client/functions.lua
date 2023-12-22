local QBCore = exports['qbx-core']:GetCoreObject()

function loadPlayerNeeds() -- This is only executed on script start or player load to update the hunger after loaded needs to use the event triggered down here
    local PlayerData = QBCore.Functions.GetPlayerData()
    TriggerEvent('hud:client:UpdateNeeds', PlayerData.metadata.hunger, PlayerData.metadata.thirst)
end