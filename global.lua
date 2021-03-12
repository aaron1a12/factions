Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        math.randomseed(GetGameTimer())
    end
end)

rsCharset = {}  do -- [0-9a-zA-Z]
    for c = 48, 57  do table.insert(rsCharset, string.char(c)) end
    for c = 65, 90  do table.insert(rsCharset, string.char(c)) end
end

function randomString(length)
    if not length or length <= 0 then return '' end
    return randomString(length - 1) .. rsCharset[math.random(1, #rsCharset)]
end

function lerp(pos1, pos2, alpha)
    return (1-alpha)*pos1 + alpha*pos2
end

function IsPlayerLookingForward(pPed)
    if pPed == nil then local pPed = GetPlayerPed(-1) end
    
    local camCoords = GetGameplayCamCoord() - GetEntityCoords(pPed)
    local forward = GetEntityForwardVector(pPed)
    local dot = (forward.x * camCoords.x) + (forward.y * camCoords.y) + (forward.z * camCoords.z)

    if dot > 0 then return false else return true end
end

-- Nice enumerator functions. I forgot who wrote this originally but it wasn't me.

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
      local iter, id = initFunc()
      if not id or id == 0 then
        disposeFunc(iter)
        return
      end
      
      local enum = {handle = iter, destructor = disposeFunc}
      setmetatable(enum, entityEnumerator)
      
      local next = true
      repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
      until not next
      
      enum.destructor, enum.handle = nil, nil
      disposeFunc(iter)
    end)
  end

function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
    return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

--  Event Callback Helpers --------------------------------

--  How to Use (Client):

--  Call('factions:foo', {}, function(retVal1)
--      print("Nice! retVal:"..retVal1)
--  end)

--  How to Use (Server):

--  AddEventHandler("factions:foo", function(args, cbId)
--      TriggerClientEvent('factions:cl_onCallback_OneParam', source, cbId, "bar")
--  end)
--  RegisterServerEvent("factions:foo")

CallbackTable = {}

function Call(svEventName, args, callback)
    local cbType = type(callback)
    if cbType == "function" or cbType == "table" then
        local callbackId = randomString(8)
        CallbackTable[callbackId] = callback

        TriggerServerEvent(svEventName, args, callbackId)
    else
        TriggerServerEvent(svEventName, args, callback)
    end    
end

AddEventHandler("factions:cl_onCallback", function(callbackId)
    CallbackTable[callbackId]()
    CallbackTable[callbackId] = nil
end) RegisterNetEvent("factions:cl_onCallback")

AddEventHandler("factions:cl_onCallback_OneParam", function(callbackId, ret1)
    CallbackTable[callbackId](ret1)
    CallbackTable[callbackId] = nil
end) RegisterNetEvent("factions:cl_onCallback_OneParam")

AddEventHandler("factions:cl_onCallback_AnyParam", function(callbackId, ret1, ret2, ret3, ret4)
    if ret4 ~= nil then
        CallbackTable[callbackId](ret1, ret2, ret3, ret4)
    elseif ret3 ~= nil then
        CallbackTable[callbackId](ret1, ret2, ret3)
    elseif ret2 ~= nil then
        CallbackTable[callbackId](ret1, ret2)
    elseif ret1 ~= nil then
        CallbackTable[callbackId](ret1)
    else
        CallbackTable[callbackId]()
    end

    CallbackTable[callbackId] = nil
end) RegisterNetEvent("factions:cl_onCallback_AnyParam")

-- For debuging mainly

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

-- Singleton for Client

Global = {}