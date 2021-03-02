local Round = {}

function ResetRound()
    Round.TimeLeft = Config.Round.DefaultTime
    Round.CurrentMood = Config.Moods[ math.random( #Config.Moods ) ]
    Round.Scoreboard = {}

    if #GetPlayers() > 0 then
        for _, playerId in ipairs(GetPlayers()) do
            TriggerEvent("factions:playerJoined", tonumber(playerId))
        end
    end

    TriggerClientEvent('factions:cl_onResetRound', -1, Round)
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



function IsCharacterInUse( modelName )
    for _, playerId in ipairs(GetPlayers()) do
        if Round.Scoreboard[playerId] ~= nil and Round.Scoreboard[playerId].Character == modelName then
            return true
        end
    end
    return false
end

function FindAvailableCharacter()
    local modelName = nil

    repeat
        modelName = Config.Models[ math.random( #Config.Models ) ][1]

        -- Break if we will never find a free char
        if #GetPlayers() >= #Config.Models then break end
    until( not IsCharacterInUse(modelName) )

    return modelName
end

-- Scoreboard

AddEventHandler("factions:playerJoined", function(pId)
    if pId == nil then pId = source end

    -- Add the player to the scoreboard
    Round.Scoreboard[pId] = {
        ['Name'] = GetPlayerName(pId),
        ['Kills'] = 0,
        ['Deaths'] = 0,
        ['Character'] = FindAvailableCharacter(),
    }

end) RegisterServerEvent('factions:playerJoined')

AddEventHandler("playerDropped", function(source, reason)
    -- Remove the player from the scoreboard
	Round.Scoreboard[source] = nil
end)


-- Fix for restarting resource

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then

        -- Not all clients are ready
        Citizen.Wait(2000)

        ResetRound()
	end
end)

---------------------------------------------------------------------------
-- For Client
---------------------------------------------------------------------------

RegisterServerEvent('factions:getRoundTimeLeft')
AddEventHandler('factions:getRoundTimeLeft', function(cbId)
    TriggerClientEvent('factions:cl_getRoundTimeLeft', source, Round.TimeLeft, cbId)
end)

AddEventHandler("factions:getRoundInfo", function(args, cbId)
    TriggerClientEvent('factions:cl_onCallback_OneParam', source, cbId, Round)
end)
RegisterServerEvent("factions:getRoundInfo")

-- Callback demo
AddEventHandler("factions:foo", function(args, cbId)
    TriggerClientEvent('factions:cl_onCallback_OneParam', source, cbId, "bar")
end)
RegisterServerEvent("factions:foo")  

AddEventHandler('factions:reportDeath', function(killer)
    Round.Scoreboard[source].Deaths = Round.Scoreboard[source].Deaths + 1

    -- DEBUG: REWARD DEATHS INSTEAD OF KILLS, LUL
    --TriggerClientEvent('factions:cl_killReward', source, Round.Scoreboard[source].Deaths)

    if killer ~= nil then
        Round.Scoreboard[killer].Kills = Round.Scoreboard[killer].Kills + 1
        TriggerClientEvent('factions:cl_killReward', killer, Round.Scoreboard[killer].Kills)
    end
end)
RegisterServerEvent('factions:reportDeath')

-- Get the score board

AddEventHandler("factions:getScoreboard", function(args, cbId)
    TriggerClientEvent('factions:cl_onCallback_OneParam', source, cbId, Round.Scoreboard)
end)
RegisterServerEvent("factions:getScoreboard")  