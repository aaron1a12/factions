SendNUIMessage({
    type = 'open'
})


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

AddEventHandler("factions:cl_onResetRound", function(RoundInfo)
    respawnPed()
    SetPlayerControl(PlayerId(), true)
    SendNUIMessage({name = 'onResetRound'})
end)
RegisterNetEvent("factions:cl_onResetRound")