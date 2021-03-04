charCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)

--SetCamActive(charCam, true)

-- Blend in
--RenderScriptCams(true, true, 0, true, true)

--ShakeCam(charCam, "JOLT_SHAKE", 2.0)


local shakeAmount = 0.0
local bIsShaking = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        SetGameplayCamShakeAmplitude(shakeAmount)
    end
end)

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(20)
        
        if not bIsShaking and shakeAmount > 2.0 then  
            print("start shaking!?")
            
            bIsShaking = true
        end
    end
end)



local shakeMinSpeed = 2.0 
local shakeMaxSpeed = 6.0
local maxShakeAmount = 0.5

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        local vel = GetEntityVelocity(GetPlayerPed(-1))
        local speed = math.abs(vel.x) + math.abs(vel.y) + math.abs(vel.z)


        local percentageMax = shakeMaxSpeed - shakeMinSpeed
        
        local speedPercentage = speed/percentageMax*100

       
        --print(speedPercentage)

        if speed <= shakeMinSpeed then
            shakeAmount = 0.0
            bIsShaking = false
        else
            shakeAmount = (maxShakeAmount/100*speedPercentage) + 0.0
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
--ShakeGameplayCam(‘SMALL_EXPLOSION_SHAKE’, 0.18)
        --SetGameplayCamShakeAmplitude(5.0)
        local camCoords = GetGameplayCamCoord()
        local camRot = GetGameplayCamRot(2)
        local camHeading = GetGameplayCamRelativeHeading()
        --print(camHeading)

        --local playerVector = GetEntityCoords(GetPlayerPed(-1))
        --local _, forwardVector, _, position = GetEntityMatrix(vehicle)

        local forwardVector, rightVector, upVector, position = GetEntityMatrix(GetPlayerPed(-1))        
        local playerVector = (upVector * 0.5) + (rightVector * 0.5) + position

    
        local midpoint = (playerVector + camCoords) / 2

        local dist = #(position - midpoint)  


        -- -- Use Z

       
        SetCamCoord(charCam, midpoint.x, midpoint.y, midpoint.z)
        
        SetCamRot(charCam, camRot.x, camRot.y, camRot.z, 2)
        SetCamFov(charCam, 60.0)

        --SetGameplayCamShakeAmplitude(1.0)
        --SetFollowPedCamThisUpdate(charCam, 0)
        --SetFollowPedCamViewMode(1)
       

        
    end
end)