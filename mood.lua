-- Weather

local weatherType = "FOGGY"

local currentMood = nil

-- Disable normal peds

AddEventHandler('populationPedCreating', function(x, y, z, model, overrideCalls)
    overrideCalls.setModel(71929310) --clown model hash disables peds? wtf
end)



local fireIntensity = 5.0

local fireOffsetX = 870.97
local fireOffsetY = -527.44
local fireOffsetZ = 57.0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- Disabled wanted level
        SetPlayerWantedLevel(PlayerId(), 0, false)
        SetPlayerWantedLevelNow(PlayerId(), true)
        
        -- No ambient ped spawning
        SetPedDensityMultiplierThisFrame(0.0)
        SetVehicleDensityMultiplierThisFrame(0.0)
        SetParkedVehicleDensityMultiplierThisFrame(0.0)

        SetPedShootRate(GetPlayerPed(-1), 0)
        DisableFirstPersonCamThisFrame()
		
		--Fire glows
		DrawLightWithRangeAndShadow(
			fireOffsetX, --X
			fireOffsetY,  --Y
			fireOffsetZ, --Z
			255, --RED
			60, --GREEN
			5, --BLUE 
			5.00, --RANGE
			fireIntensity, --INTENSITY
			50.00) --SHADOW

    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
		
        -- Disable ambient sounds
        StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
        
        -- Make it windy, cool I guess
        SetWind(1000.0)
        
        -- No power
        SetBlackout(true)

        -- Hide the radar
        DisplayRadar(false)

        if currentMood ~= nil then
            ClearOverrideWeather()
            ClearWeatherTypePersist()
            SetWeatherTypePersist(currentMood.Weather)
            SetWeatherTypeNow(currentMood.Weather)
            SetWeatherTypeNowPersist(currentMood.Weather)

            NetworkOverrideClockTime(currentMood.Hour, 0, 0)
            SetTimecycleModifier(currentMood.Look)
            SetTimecycleModifierStrength(currentMood.Intensity)
        end
    end
end)

local fireCoords = vec3(878.30, -512.88, 59.00)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
		
		fireOffsetX = fireCoords.x+math.random()*1
		
		fireOffsetY = fireCoords.y+math.random()*1
		
		fireOffsetZ = fireCoords.z+math.random()*1
		
		fireIntensity = 3+math.random()*1
		
    end
end)




function CreateFire()
	
	local particleDictionary = "core"
	local particleName = "fire_wrecked_car"
	
	
	RequestNamedPtfxAsset(particleDictionary)
		
	while not HasNamedPtfxAssetLoaded(particleDictionary) do
		Citizen.Wait(0)
	end
	
	UseParticleFxAssetNextCall(particleDictionary)
	
	StartParticleFxLoopedAtCoord(particleName, fireCoords, 0.00, 0.00, 0.00, 1.00, 0, 0, 0, 0)
	
	StartScriptFire(fireCoords, 25, false)
	
end

CreateFire()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
		--StartParticleFxLoopedAtCoord("fire_wrecked_car", 870.97, -527.44, 56.89, 0.0, 0.0, 0.0, 100.0, false, false, false, 0)
		--StartScriptFire(870.97, -527.44, 56.89, 25, false)
		
    end
end)


function UpdateMood( newMood )
    currentMood = newMood
end


AddEventHandler('factions:updateMood', function(newMood)
    currentMood = newMood
end)

AddEventHandler("factions:cl_onResetRound", function(RoundInfo)
    print("Setting New Mood")
    currentMood = RoundInfo.CurrentMood
end)
RegisterNetEvent("factions:cl_onResetRound")