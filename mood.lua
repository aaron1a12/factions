-- Weather

local weatherType = "FOGGY"

-- Disable normal peds

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
        Citizen.Wait(1000)
    
        -- Disable ambient sounds
        StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
        
        -- Make it windy, cool I guess
        SetWind(1000.0)
        
        -- No power
        SetBlackout(true)

        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(weatherType)
        SetWeatherTypeNow(weatherType)
        SetWeatherTypeNowPersist(weatherType)

        NetworkOverrideClockTime(12, 0, 0)

        -- Hide the radar
        DisplayRadar(true)
    end
end)


SetTimecycleModifier("int_Lost_small")
SetTimecycleModifierStrength(0.9)

