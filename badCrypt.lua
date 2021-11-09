local function crypt(key, msg)
    local res = {}
    math.randomseed(key)
    for i = 1, #msg do
        res[i] = bit32.bxor(math.random(0, 255), msg:byte(i))
    end
    return string.char(unpack(res))
end

return {crypt = crypt}
