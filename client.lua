local myScore = 0

local bScoreboardIsOpen = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsControlPressed(1, 243) and not bScoreboardIsOpen then
            SendNUIMessage({name = 'showScoreboard'})
            bScoreboardIsOpen = true
        elseif bScoreboardIsOpen and IsControlReleased(1, 243) then
            bScoreboardIsOpen = false
            SendNUIMessage({name = 'hideScoreboard'})
        end
    end
end)

function onResetRound()
    myScore = 0

    TriggerEvent("factions:updateMood", Global.Round.CurrentMood)
    respawnPed()
    SetPlayerControl(PlayerId(), true)
    SendNUIMessage({name = 'onResetRound'})
end

AddEventHandler('gameEventTriggered', function (name, args)
    if name == 'CEventNetworkStartMatch' and Global.Round == nil then
    end
end)

AddEventHandler("playerSpawned", function(spawn)
    TriggerServerEvent('factions:playerJoined')

    Call('factions:getRoundInfo', {}, function(RoundInfo)
        Global.Round = RoundInfo
        onResetRound()
    end)    
end)

RegisterNUICallback('getRoundTimeLeft', function(data, cb)
    -- and so does callback response data
    --cb(256)

    local callbackId = randomString(8)

    CallbackTable[callbackId] = cb
    TriggerServerEvent('factions:getRoundTimeLeft', callbackId)
end)

AddEventHandler("factions:cl_getRoundTimeLeft", function(timeLeft, cbId)
    -- Call from the callback table and then delete it
    CallbackTable[cbId](timeLeft)
    CallbackTable[cbId] = nil
end)
RegisterNetEvent("factions:cl_getRoundTimeLeft")

AddEventHandler("factions:cl_onRoundEnd", function(timeLeft, cbId)
    SetPlayerControl(PlayerId(), false)
    SendNUIMessage({name = 'onRoundEnd'})
end)
RegisterNetEvent("factions:cl_onRoundEnd")

AddEventHandler("factions:cl_onResetRound", function(newRoundInfo)
    Global.Round = newRoundInfo
    onResetRound()
end)
RegisterNetEvent("factions:cl_onResetRound")

RegisterNUICallback('getScoreboard', function(data, cb)
    Call('factions:getScoreboard', {}, function(scoreboard)

        -- Stupid fix. Unlike Lua, javascript requires strings as keys NOT numbers
        local sb = {}
        for playerId, score in pairs(scoreboard) do
            sb[tostring(playerId)] = scoreboard[playerId];
        end

        cb(sb)
    end)
end)




AddEventHandler("getWeaponLoadout", function()
    print("GET WEAPON LOADOUT!? ")


    local loadout = {}
    local playerPed = GetPlayerPed(-1)

    for _, rank in ipairs(Config.Ranks) do
        --rank.MinScore
        --rank.Unlocks

        for __, weapon in ipairs(rank.Unlocks) do
            if weapon[2] == nil then weapon[2] = 1 end

            GiveWeaponToPed(playerPed, GetHashKey( weapon[1] ), weapon[2], false, false)

            if weapon[3] ~= nil then
                GiveWeaponComponentToPed(playerPed, GetHashKey(weapon[1]), GetHashKey(weapon[3]))
            end
        end

        print('rank.MinScore:' .. rank.MinScore .. ', myScore:'..myScore)

        if rank.MinScore >= myScore then break end
    end    
end)

AddEventHandler("factions:cl_killReward", function(totalKills)
    myScore = totalKills

    TriggerEvent("getWeaponLoadout")
end)
RegisterNetEvent("factions:cl_killReward")