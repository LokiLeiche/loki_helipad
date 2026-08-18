local Cache = {
    ped = PlayerPedId(),
    helipads = {},
    playerJob = nil
}

function LoadPlayerPed()
    Cache.ped = PlayerPedId()
end

function LoadPlayerJob(job)
    Cache.playerJob = job
end


local function loadHelipadModel()
    local modelLoadTries = 0
    RequestModel(Config.HelipadModel)
    while not HasModelLoaded(Config.HelipadModel) do
        Wait(100)
        modelLoadTries = modelLoadTries + 1
        if modelLoadTries > 30 then
            error("Unable to load model "..Config.HelipadModel)
        end
    end
end
loadHelipadModel()


-- spawn helipads on startup
for idx, helipad in ipairs(Config.Helipads) do
    local object
    if helipad.defaultPosition == "inside" then
        object = CreateObjectNoOffset(
            Config.HelipadModel, helipad.coords.insideX, helipad.coords.insideY, helipad.coords.zPos,
            false, true, false
        )
    else
        object = CreateObjectNoOffset(
            Config.HelipadModel, helipad.coords.outsideX, helipad.coords.outsideY, helipad.coords.zPos,
            false, true, false
        )
    end
    SetEntityRotation(object, 0.0, 0.0, helipad.coords.rotation, 2, false)
    Cache.helipads[idx] = {
        attatchedVehicle = nil,
        moving = false,
        object = object,
    }
end


---@param idx integer the id of the helipad
local function moveHelipad(idx)
    local vehicles = GetGamePool("CVehicle")
    local helipadCoords = GetEntityCoords(Cache.helipads[idx].object)
    for _, v in pairs(vehicles) do
        local vehModel = GetEntityModel(v)
        if IsThisModelAHeli(vehModel) and #(helipadCoords - GetEntityCoords(v)) < 5.0 then
            local heliRot = GetEntityRotation(v)
            local offset = Config.CustomOffsets[vehModel]
            if not offset then
                offset = Config.DefaultOffset
            end
            AttachEntityToEntity(v, Cache.helipads[idx].object, 0, offset.x, offset.y, offset.z, heliRot.x, heliRot.y, heliRot.z, false, false, true, false, 2, false)
            Cache.helipads.attatchedVehicle = v
            break
        end
    end
    TriggerServerEvent('loki_helipad:moveHelipad', GetNetworkTimeAccurate(), idx)
end


---moves the helipad from starting postion to target position
---@param startTime integer when the slide was triggered (for syncing)
---@param idx integer id of the helipad to move
---@param backwards boolean forwards = inside->outside, backwards = outside->inside
local function slideHelipad(startTime, idx, backwards)
    Cache.helipads[idx].moving = true

    local gameTime = GetGameTimer()
    local endGameTime = gameTime + Config.Helipads[idx].slideDuration - (GetNetworkTimeAccurate() - startTime)

    local delta = endGameTime - gameTime
    local startingX, startingY, offsetX, offsetY

    if backwards then
        startingX = Config.Helipads[idx].coords.outsideX
        startingY = Config.Helipads[idx].coords.outsideY
    else
        startingX = Config.Helipads[idx].coords.insideX
        startingY = Config.Helipads[idx].coords.insideY
    end
    local offX = Config.Helipads[idx].coords.outsideX - Config.Helipads[idx].coords.insideX
    local offY = Config.Helipads[idx].coords.outsideY - Config.Helipads[idx].coords.insideY

    offsetX = offX / delta
    offsetY = offY / delta

    CreateThread(function()
        local currentTime = gameTime

        while currentTime < endGameTime do
            currentTime = GetGameTimer()
            local curDelta = endGameTime - currentTime
            local curX, curY
            if backwards then
                curX = startingX + (curDelta * offsetX) - offX
                curY = startingY + (curDelta * offsetY) - offY
            else
                curX = startingX - (curDelta * offsetX) + offX
                curY = startingY - (curDelta * offsetY) + offY
            end

            SetEntityCoords(
                Cache.helipads[idx].object, curX, curY, Config.Helipads[idx].coords.zPos, false, false, false, false
            )
            Wait(Config.LoopWait)
        end

        if Cache.helipads[idx].attachedVeh then DetachEntity(Cache.helipads[idx].attachedVeh, false, false) end
        Cache.helipads[idx].moving = false
    end)
end

---@param start integer start time of the slide
---@param idx integer id of the helipad
---@param backwards boolean forwards = inside->outside, backwards = outside->inside
RegisterNetEvent('loki_helipad:moveHelipad', function(start, idx, backwards)
    slideHelipad(start, idx, backwards)
end)


---Makes the player press the button to move the helipad
---@param idx integer the id of the helipad to move
local function PressButton(idx)
    if Cache.helipads[idx].moving then return end

    RequestAnimDict(Config.Helipads[idx].button.anim.dict)
    TaskGoStraightToCoord(
        Cache.ped, Config.Helipads[idx].button.anim.playerPos.x, Config.Helipads[idx].button.anim.playerPos.y,
        Config.Helipads[idx].button.anim.playerPos.z, 3.0, -1, Config.Helipads[idx].button.anim.playerPos.w, 3.0
    )
    local taskStatus = GetScriptTaskStatus(Cache.ped, "SCRIPT_TASK_GO_STRAIGHT_TO_COORD")

    -- wait till player arrived at pos
    while taskStatus ~= 7 do
        Wait(50)
        taskStatus = GetScriptTaskStatus(PlayerPedId(), "SCRIPT_TASK_GO_STRAIGHT_TO_COORD")
    end

    local tries = 0
    while not HasAnimDictLoaded(Config.Helipads[idx].button.anim.dict) do
        tries = tries + 1
        Wait(100)
        if tries > 30 then
            error("Unable to load anim dict for pressing the button: "..Config.Helipads[idx].button.anim.dict)
        end
    end

    TaskPlayAnim(PlayerPedId(), Config.Helipads[idx].button.anim.dict, Config.Helipads[idx].button.anim.anim, 8.0, 1.0, -1, 1, 1.0, false, false, false)
    Wait(Config.Helipads[idx].button.anim.duration)
    ClearPedTasks(PlayerPedId())

    if not Cache.helipads[idx].moving then
        moveHelipad(idx)
    end
end


---Callback for syncing the current helipad postions on startup
---@param positions ("inside" | "outside")[] list of current helipad positions
RegisterNetEvent('loki_helipad:loadPosition', function(positions)
    for idx, pos in ipairs(positions) do
        if pos == "inside" then
            SetEntityCoords(
                Cache.helipads[idx].object, Config.Helipads[idx].coords.insideX, Config.Helipads[idx].coords.insideY,
                Config.Helipads[idx].coords.zPos, false, false, false, false
            )
        else
            SetEntityCoords(
                Cache.helipads[idx].object, Config.Helipads[idx].coords.outsideX, Config.Helipads[idx].coords.outsideY,
                Config.Helipads[idx].coords.zPos, false, false, false, false
            )
        end
    end
end)

---Request initial helipad positions from server on startup
CreateThread(function()
    Wait(1000)
    TriggerServerEvent('loki_helipad:syncPosition')
    AddTextEntry("loki_helipad", _U('helpText'))

    for idx, helipad in ipairs(Config.Helipads) do
        if helipad.button then
            RequestModel(helipad.button.model)
            local tries = 0
            while not HasModelLoaded(helipad.button.model) do
                tries = tries + 1
                Wait(100)
                if tries > 30 then
                    error("Unable to load model for button: "..helipad.button.model)
                end
            end
            local button = CreateObject(
                helipad.button.model, helipad.button.position.x, helipad.button.position.y, helipad.button.position.z,
                false, true, false
            )
            SetEntityRotation(button,  helipad.button.rotation.x,  helipad.button.rotation.y,  helipad.button.rotation.z, 2, false)
        end

        CreateThread(function()
            while true do
                Wait(2000)
                if not helipad.job or helipad.job == Cache.playerJob then
                    local dist = #(GetEntityCoords(Cache.ped) - helipad.marker.position)
                    while dist < 50 and (not helipad.job or helipad.job == Cache.playerJob) do
                        Wait(0)
                        if helipad.marker then
                            DrawMarker(
                                helipad.marker.type, helipad.marker.position.x, helipad.marker.position.y, helipad.marker.position.z,
                                0.0, 0.0, 0.0, helipad.marker.rotation.x, helipad.marker.rotation.y, helipad.marker.rotation.z,
                                helipad.marker.scale, helipad.marker.scale, helipad.marker.scale, helipad.marker.color.r,
                                helipad.marker.color.g, helipad.marker.color.b, helipad.marker.transparency, helipad.marker.bop,
                                helipad.marker.faceCamera, 2, helipad.marker.rotate,
                                ---@diagnostic disable-next-line: param-type-mismatch
                                false, false, -- needs diagnostic disable because it's typed as string and false/nil is not accepted, but using an empty string instead produces errors
                                false
                            )
                        end
                        dist = #(GetEntityCoords(Cache.ped) - helipad.marker.position)
                        if dist < 1.5 then
                            DisplayHelpTextThisFrame("loki_helipad", false)
                            if IsControlJustPressed(0, Config.InteractionKey) and not Cache.helipads[idx].moving then
                                if helipad.button then
                                    PressButton(idx)
                                else
                                    moveHelipad(idx)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

