Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        math.randomseed(GetGameTimer())
    end
end)