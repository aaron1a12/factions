Citizen.CreateThread(function()
    while true do
        if IsPlayerFreeAiming(PlayerId()) then
			local currentWeaponGroup = GetWeapontypeGroup(GetSelectedPedWeapon(GetPlayerPed(-1)))
			local type2Send = 0
			
			if currentWeaponGroup == 860033945 then
				type2Send = 1
			end			
			
			SendNUIMessage({name = 'showReticule', type = type2Send})	
        else	
            SendNUIMessage({name = 'hideReticule'})
        end
        
        Citizen.Wait(100)
    end
end)
