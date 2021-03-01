local Round = {}

function ResetRound()
    Round.TimeLeft = Config.Round.DefaultTime

    TriggerClientEvent('factions:cl_onResetRound', -1)
end ResetRound()

function OnRoundEnd()
    TriggerClientEvent('factions:cl_onRoundEnd', -1)

    Citizen.Wait(4000)

    ResetRound();
end


-- Round timer

Citizen.CreateThread(function()
	while Round.TimeLeft > 0 do
        Citizen.Wait(1000)

        Round.TimeLeft = Round.TimeLeft - 1
        
        if Round.TimeLeft == 0 then
            OnRoundEnd()
        end
	end
end)

-- For Client


RegisterServerEvent('factions:getRoundTimeLeft')
AddEventHandler('factions:getRoundTimeLeft', function(cbId)
    TriggerClientEvent('factions:cl_getRoundTimeLeft', source, Round.TimeLeft, cbId)
end)


-- Callback demo
AddEventHandler("factions:foo", function(args, cbId)
    TriggerClientEvent('factions:cl_onCallback_OneParam', source, cbId, "bar")
end)
RegisterServerEvent("factions:foo")