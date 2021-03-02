-- Weather

local weatherType = "FOGGY"

local currentMood = nil

-- Disable normal peds

AddEventHandler('populationPedCreating', function(x, y, z, model, overrideCalls)
    overrideCalls.setModel(71929310) --clown model hash disables peds? wtf
end)

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