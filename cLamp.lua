local function toLamp(R, G, B)
  local divider = 255/32
	local R = math.min(divider*R,31)
	local G = math.min(divider*G,31)
	local B = math.min(divider*B,31)
    return B + G * 32 + R * 1024
end
return {toLamp = toLamp}
