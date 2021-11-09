local function getRGB(ins,mode)
    if mode == nil then
        mode = 255
    end
    local r,g,b = term.getPaletteColor(ins)
    return r*mode,g*mode,b*mode
end
 
return {getRGB = getRGB}
