DecorRegister("PED_LIGHT_ENABLED")
DecorRegister("PED_LIGHT_DIR_X")
DecorRegister("PED_LIGHT_DIR_Y")
DecorRegister("PED_LIGHT_DIR_Z")

local lightCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)

Citizen.CreateThread(function()
    while true do Citizen.Wait(1)
         
        -- Toggle light

        if IsControlJustPressed(0, 19) then

            if not DecorExistOn(GetPlayerPed(-1), "PED_LIGHT_ENABLED") then
                DecorSetBool(GetPlayerPed(-1), "PED_LIGHT_ENABLED", true)
            else
                local currentVal = DecorGetBool(GetPlayerPed(-1), "PED_LIGHT_ENABLED")
                DecorSetBool(GetPlayerPed(-1), "PED_LIGHT_ENABLED", not currentVal)
            end
        end
    end
end)

local camRand = vec3(
    (math.random() * 2),
    (math.random() * 2),
    (math.random() * 2)
)
local camOffset = vec3(0,0,0)
local currentPos = 1.0
local alpha = 0.0

local alphaX = 0.0
local alphaY = 0.0
local alphaZ = 0.0
local camOffsetX = 0.0
local camOffsetY = 0.0
local camOffsetZ = 0.0
local camRandX = 0.0
local camRandY = 0.0
local camRandZ = 0.0

local cachedPedLights = {}

-- Main logic/magic loop
Citizen.CreateThread(function()
    while true do Citizen.Wait(1)

        local rot = vec3(1,0,0)

        local camCoords = GetGameplayCamCoord()
        local camRot = GetGameplayCamRot(0)

        alphaX = alphaX + 0.05
        alphaY = alphaY + 0.06
        alphaZ = alphaZ + 0.07
        
        if alphaX > 1.0 then alphaX = 0.0 camOffsetX = camRot.x + camRandX camRandX = (math.random() * 5) end
        if alphaY > 1.0 then alphaY = 0.0 camOffsetY = camRot.y + camRandY camRandY = (math.random() * 5) end
        if alphaZ > 1.0 then alphaZ = 0.0 camOffsetZ = camRot.z + camRandZ camRandZ = (math.random() * 5) end

        SetCamCoord(lightCam, camCoords.x, camCoords.y, camCoords.z)
        SetCamRot(lightCam, camRot, 0)
        SetCamRot(lightCam,
            lerp(camOffsetX, camRot.x + camRandX, alphaX),
            lerp(camOffsetY, camRot.y + camRandY, alphaY),
            lerp(camOffsetZ, camRot.z + camRandZ, alphaZ), 0)

        local camRight, forward, camUp, camPosition = GetCamMatrix(lightCam)

        local playerPos = GetEntityCoords(GetPlayerPed(-1))
        local lightPos = vector3(playerPos.x, playerPos.y, playerPos.z + 0.8)
        
        local dir = nil

        local bFacingForward  = IsPlayerLookingForward()
        if bFacingForward then
            dir = (camPosition + forward) - GetGameplayCamCoord()
        else
            dir = GetEntityForwardVector(GetPlayerPed(-1))
        end

        DecorSetFloat(GetPlayerPed(-1), "PED_LIGHT_DIR_X", dir.x)
        DecorSetFloat(GetPlayerPed(-1), "PED_LIGHT_DIR_Y", dir.y)
        DecorSetFloat(GetPlayerPed(-1), "PED_LIGHT_DIR_Z", dir.z)

        local lightPosFinal = lightPos+ (forward/3)
        --print(cam)
        
        --
        --DrawSpotLightWithShadow(lightPosFinal, dir, 152, 176, 233, 100.0, 1.1, 10, 10.0, 10.0, 1.0) 
        --
    end
end)

-- Render lights and flares on peds

local netAlphaLerp = 0.0

Citizen.CreateThread(function()
    while true do Citizen.Wait(1)

        netAlphaLerp = netAlphaLerp + 0.05

        if netAlphaLerp > 1.0 then
            -- Finished interpolating so let's reset and get a new target vec
            netAlphaLerp = 0.0
        end

        for ped in EnumeratePeds() do
            if DoesEntityExist(ped) and DecorExistOn(ped, "PED_LIGHT_ENABLED") then
                if DecorGetBool(ped, "PED_LIGHT_ENABLED") then

                    local lightPos = GetPedBoneCoords(ped, 0x60F2, 0.0, 0.2, 0.0)
                    local dir = GetEntityForwardVector(ped)

                    local cPedID = NetworkGetNetworkIdFromEntity(ped)

                    if cachedPedLights[cPedID] == nil then cachedPedLights[cPedID] = {['current'] = vec3(0,0,0), ['new'] = vec3(0,0,0)} end

                    if DecorExistOn(ped, "PED_LIGHT_DIR_X") and DecorExistOn(ped, "PED_LIGHT_DIR_Y") and DecorExistOn(ped, "PED_LIGHT_DIR_Z") then

                        if netAlphaLerp == 0.0 then

                            local netDir = vec3(
                                DecorGetFloat(ped, "PED_LIGHT_DIR_X"),
                                DecorGetFloat(ped, "PED_LIGHT_DIR_Y"),
                                DecorGetFloat(ped, "PED_LIGHT_DIR_Z")
                            )

                            cachedPedLights[cPedID]['current'] = cachedPedLights[cPedID]['new']
                            cachedPedLights[cPedID]['new'] = netDir
                        end                       

                        dir = vec3(
                            lerp(cachedPedLights[cPedID]['current'].x, cachedPedLights[cPedID]['new'].x, netAlphaLerp),
                            lerp(cachedPedLights[cPedID]['current'].y, cachedPedLights[cPedID]['new'].y, netAlphaLerp),
                            lerp(cachedPedLights[cPedID]['current'].z, cachedPedLights[cPedID]['new'].z, netAlphaLerp)
                        )
                    end
    
                    DrawSpotLightWithShadow(lightPos, dir, 152, 176, 233, 100.0, 1.1, 10, 10.0, 10.0, 1.0 + cPedID)
                    
                    DrawLightWithRangeAndShadow(lightPos, 255, 255, 255, 10.00, 0.5, 200.00)
                    DrawLightWithRangeAndShadow(lightPos, 255, 255, 255, 2.00, 10.0, 200.00)

                    -- Draw flare sprite

                    local camCoords = GetGameplayCamCoord()
                
                    --DrawLine(camCoords, lightPos, 255, 255, 255, 255)	
                    
                    local shpTstFlags = -1
                    local shpTstIgnEntity = 0
                    local shpTstBitMask = 4

                    local CoB = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)

                    local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(camCoords, CoB, shpTstFlags, shpTstIgnEntity, shpTstBitMask)
                    local retval, hit, endCoords, surfaceNormal, Ent = GetRaycastResult(RayHandle)
                    

                    if not IsPlayerLookingForward(ped) then
                        --print(endCoords)
                    end

                    if endCoords == vec3(0,0,0) and not IsPlayerLookingForward(ped) then
                        --print("SHOW SPIRTE?")
                        SetDrawOrigin(lightPos, 0)
                        RequestStreamedTextureDict("factions", false)
                        DrawSprite("factions", "flare", -0.01, -0.01, 0.2, 0.2, 0.0, 255, 255, 255, 255)
                        ClearDrawOrigin()
                    end

                end
            end
        end
    end
end)