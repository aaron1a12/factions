Citizen.CreateThread(function()
    while true do
        if IsPlayerFreeAiming(PlayerId()) then
            SendNUIMessage({name = 'showReticule', type = 0})
        else
            SendNUIMessage({name = 'hideReticule'})
        end
        
        Citizen.Wait(100)
    end
end)