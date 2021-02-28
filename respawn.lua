-- Turn off automatic respawn here instead of updating FiveM file.
AddEventHandler('onClientMapStart', function()
	exports.spawnmanager:spawnPlayer() -- Ensure player spawns into server.
	Citizen.Wait(2500)
	exports.spawnmanager:setAutoSpawn(false)
end)

spawnPoints = {
    {['x'] = 867.07, ['y'] = -551.1, ['z'] = 57.33, ['h'] = 280.0}
}

AddEventHandler("cl_playerHasDied", function()
    print("cl_playerHasDied")
    respawnPed()
end)

function respawnPed()
    NetworkResurrectLocalPlayer(spawnPoints[1].x, spawnPoints[1].y, spawnPoints[1].z, spawnPoints[1].h, true, false) 
end

--for _, hospital in pairs(HospitalLocations) do

local bPlayerHasDied = false

--  Death event polling
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)

        if IsPedDeadOrDying(GetPlayerPed(-1), true)  and not bPlayerHasDied then
            TriggerEvent("cl_playerHasDied")
        end

    end
end)