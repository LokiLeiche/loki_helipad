local function versionChecker()
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    if not currentVersion or currentVersion == "" then
        error("Unable to read resource version")
        return
    end

    PerformHttpRequest('https://api.github.com/repos/LokiLeiche/loki_helipad/releases/latest', function(status, response, headers)
        if status ~= 200 or not response then return end

        local release = json.decode(response)
        if release and release.tag_name then
            local latestVersion = release.tag_name:gsub('^v', '')

            if latestVersion ~= currentVersion then
                print('^1You are using an old version of loki_helipad!^0')
                print('Your version: '..currentVersion..' | latest version: '..latestVersion)
                print('Please update the resource for the best experience. You can download the latest version from https://github.com/LokiLeiche/loki_helipad')
            elseif not Config.VersionCheckOmitLatest then
                print('^2You are using the latest version of loki_helipad!^0')
            end
        end
    end)
end

if Config.VersionCheck then
    Citizen.CreateThread(function()
        Wait(5000) -- wait until all resources are started to avoid being lost in the spam
        versionChecker()
    end)
end


local positionCache = {}

for idx, helipad in ipairs(Config.Helipads) do
    positionCache[idx] = helipad.defaultPosition
end


---starts moving a helipad for all players
---@param time integer the time when the slide was started
---@param idx integer id of the helipad to move
RegisterServerEvent('loki_helipad:moveHelipad', function(time, idx)
    if positionCache[idx] == "inside" then
        positionCache[idx] = "outside"
        TriggerClientEvent('loki_helipad:moveHelipad', -1, time, idx, false)
    else
        positionCache[idx] = "inside"
        TriggerClientEvent('loki_helipad:moveHelipad', -1, time, idx, true)
    end
end)


---A way for the client to request a sync of the current positions on startup
RegisterServerEvent('loki_helipad:syncPosition', function()
    local src = source
    TriggerClientEvent('loki_helipad:loadPosition', src, positionCache)
end)
