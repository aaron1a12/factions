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