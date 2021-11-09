----angle calculation API by 9551----
local function deg(entity)
    local x, y, z = entity.x, entity.y, entity.z
    local pitch = -math.atan2(y, math.sqrt(x * x + z * z))
    local yaw = math.atan2(-x, z)
    return ({math.deg(yaw), math.deg(pitch)})
end

return {deg = deg}
