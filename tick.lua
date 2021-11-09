local function tick(ltc)
    if type(ltc) ~= "string" then
        error("this function requires C lamp to work!", 0)
    end
    local change = 3600
    local ot = (os.time("utc") * change)
    local tick = 0
    repeat
        peripheral.call(ltc, "setLampColor", 0)
        tick = tick + 1
    until ot < os.time("utc") * change
    if tick > 20 then
        tick = 20
    end
    return tick
end
return {tick = tick}
