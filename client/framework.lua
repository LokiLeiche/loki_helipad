if GetResourceState('es_extended') == 'started' then
    RegisterNetEvent('esx:setJob', function(job)
        LoadPlayerJob(job.name)
    end)
    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        LoadPlayerJob(xPlayer.job.name)
    end)
elseif GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started' then
    local QBCore = exports['qb-core']:GetCoreObject()
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        LoadPlayerJob(QBCore.Functions.GetPlayerData().job.name)
    end)
    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
        LoadPlayerJob(JobInfo.name)
    end)
else
    -- custom framework
end

-- used to cache the players ped, add custom events if necessary
AddEventHandler('playerSpawned', function()
    LoadPlayerPed()
end)

AddEventHandler('respawnPlayerPedEvent', function()
    LoadPlayerPed()
end)
