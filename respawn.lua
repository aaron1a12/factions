-- Turn off automatic respawn here instead of updating FiveM file.
AddEventHandler('onClientMapStart', function()
	exports.spawnmanager:spawnPlayer() -- Ensure player spawns into server.
	Citizen.Wait(2500)
	exports.spawnmanager:setAutoSpawn(false)
end)

spawnPoints = {
    {['x'] = 867.07, ['y'] = -551.1, ['z'] = 57.33, ['h'] = 280.0},
    {['x'] = 875.31, ['y'] = -609.16, ['z'] = 58.29, ['h'] = 51.02},
    {['x'] = 907.58, ['y'] = -535.40, ['z'] = 58.13, ['h'] = 68.81},    
    {['x'] = 915.76, ['y'] = -553.23, ['z'] = 57.96, ['h'] = 240.63},
}

local deathCam = nil





function AnimateCamera()
    local headPos = GetPedBoneCoords(GetPlayerPed(-1), 31086, 0.0, 0.0, 0.0)

    local camPos = GetCamCoord(deathCam)
    
    SetCamCoord(deathCam, camPos.x, camPos.y, headPos.z + 1.0)

    
    local camRot = GetCamRot(deathCam)

   
    local camAngle = ( 360 - math.deg(math.atan2((headPos.x - camPos.x), (headPos.y - camPos.y))) ) % 360

    SetCamRot(deathCam, -50.0, 20.0, camAngle, 2)
end

local bPlayerHasDied = false

AddEventHandler("cl_playerHasDied", function()
    local playerPed = GetPlayerPed(-1)

    local killerPed = GetPedSourceOfDeath(playerPed)
    local killerPlayerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(killerPed))
    local killerName = GetPlayerName(NetworkGetPlayerIndexFromPed(killerPed))

    if killerPed ~= 0 then
        TriggerServerEvent("factions:reportDeath", killerPlayerId)
    else
        TriggerServerEvent("factions:reportDeath")
    end
    

    SendNUIMessage({
        name = 'playDeathSound'
    })
    
    local playerOffset = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 0.0, 0.0)
    
    deathCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    
    SetCamActive(deathCam, true)

    SetCamCoord(deathCam, playerOffset.x, playerOffset.y, playerOffset.z)
    
    -- Keep animating the cam while it's active
    AnimateCamera()
    Citizen.CreateThread(function() while IsCamActive(deathCam) do Citizen.Wait(1) AnimateCamera() end end)

    -- Blend in
    RenderScriptCams(true, true, 1000, true, true)

    local camera = GetRenderingCam()
    local fov = 120.0
    
    SetCamFov(camera, fov)
    
    Citizen.Wait(1000)

    DoScreenFadeOut(1)

    Citizen.Wait(3000)

    DoScreenFadeIn(1)

    --while IsScreenFadingOut() do
	--	Citizen.Wait(0)
    --end

    --Citizen.Wait(1000)

	--DoScreenFadeIn(2000)

	--while IsScreenFadingIn() do
	--	Citizen.Wait(0)
    --end
    
    SetCamActive(deathCam, false)
	RenderScriptCams(false, 1, 0, 300, 300)
	--enderScriptCams(false, 1, 4000, 300, 300)
	
	DestroyCam(deathCam,false)

    respawnPed()
end)

function respawnPed()
    Call('factions:getMyId', {}, function(playerId)
        -- Load model
        local model = GetHashKey(Global.Round.Scoreboard[playerId].Character)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)	
        end
        
        -- Change
        SetPlayerModel(PlayerId(), model) 
        SetModelAsNoLongerNeeded(model)

        -- Clean and choose a new spawn point

        local playerPed = GetPlayerPed(-1)

        ClearPedBloodDamage(playerPed)
        
        local newSpawnPoint = spawnPoints[ math.random( #spawnPoints ) ]

        if bPlayerHasDied then
            NetworkResurrectLocalPlayer(newSpawnPoint.x, newSpawnPoint.y, newSpawnPoint.z, newSpawnPoint.h, true, false) 
        else
            StartPlayerTeleport(playerPed, newSpawnPoint.x, newSpawnPoint.y, newSpawnPoint.z, newSpawnPoint.h, true, true, true)
            StopPlayerTeleport()

            SetEntityCoords(playerPed, newSpawnPoint.x, newSpawnPoint.y, newSpawnPoint.z)
            SetEntityHeading(newSpawnPoint.h)
        end

        -- Enable pvp
        NetworkSetFriendlyFireOption(true)
        SetCanAttackFriendly(playerPed, true, true)

        RemoveAllPedWeapons(playerPed, true)
        TriggerEvent("getWeaponLoadout")

        ShakeGameplayCam('SKY_DIVING_SHAKE', 0.0)

        bPlayerHasDied = false
    end)
end

--for _, hospital in pairs(HospitalLocations) do



--  Death event polling
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)

        if IsPedDeadOrDying(GetPlayerPed(-1), true)  and not bPlayerHasDied then
            bPlayerHasDied = true
            TriggerEvent("cl_playerHasDied")
        end

    end
end)

