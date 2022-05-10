--[[
    a single file implementation of GuiH image wrapping and displaying api
    made by 9551Dev
]]

local chars = "0123456789abcdef"
local saveCols, loadCols = {}, {}
for i = 0, 15 do
    saveCols[2^i] = chars:sub(i + 1, i + 1)
    loadCols[chars:sub(i + 1, i + 1)] = 2^i
end

local function read_characters(file,start,en)
    local out = {}
    for i=start,en do
        file.seek("set",i)
        table.insert(out,file.read())
    end
    return string.char(table.unpack(out))
end

local function get_meta(file,on)
    local sekt = on
    local out = {}
    for i=1,3 do
        local full = {}
        local data = ""
        while not (data == 0x20 or data == 0x0A) do
            file.seek("set",sekt)
            data = file.read()
            table.insert(full,data)
            sekt = sekt + 1
        end
        table.insert(out,tonumber(string.char(table.unpack(full))))
    end
    return out,sekt
end

local function get_image_data(file,on,meta)
    local sekt = on
    local out = {}
    local pixels = 0
    file.seek("set",on)
    while file.read() do pixels = pixels + 1 end
    file.seek("set",sekt)
    for i=1,math.floor(pixels/3) do
        local data = ""
        for i=1,3 do
            local running = 0
            local full = {}
            while data and running < 3 do
                file.seek("set",sekt)
                data = file.read()
                if data ~= nil then data = data/meta[3] end
                table.insert(full,data)
                sekt = sekt + 1
                running = running + 1
            end
            if not next(full) then break end
            table.insert(out,{r=full[1],g=full[2],b=full[3]})
        end
    end
    return out,pixels/3
end

local function process_to_2d_array(list,width,tp)
    local out = {}
    for k,v in pairs(list) do
        local x = math.floor((k-1)%width+1)
        local y = math.ceil(k/width)
        if not out[tp and x or y] then out[tp and x or y] = {} end
        out[tp and x or y][tp and y or x] = v
    end
    return out
end

local function decode_ppm(_file)
    local file = fs.open(_file,"rb")
    if not file then error("File: "..(_file or "").." doesnt exist",3) end
    if read_characters(file,0,2) == "P6\x0A" then
        local seek_offset = -math.huge
        while true do
            local data = file.read()
            if string.char(data) == "#" then
                while true do
                    local cmt_part = file.read()
                    if cmt_part == 0x0A then break end
                    seek_offset = file.seek("cur")+1
                end
            else
                local meta,seek_offset = get_meta(file,seek_offset)
                local _temp,pixels = get_image_data(file,seek_offset,meta)
                local data = process_to_2d_array(_temp,meta[1],true)
                local file_data = file.readAll()
                file.close()
                return {
                    data=file_data,
                    meta=meta,
                    pixels=data,
                    pixel_count=pixels,
                    width=meta[1],
                    height=meta[2],
                    color_type=meta[3],
                    get_pixel=function(x,y)
                        local y_list = data[math.floor(x+0.5)]
                        if y_list then
                            return y_list[math.floor(y+0.5)]
                        end
                    end,
                    get_palette=function()
                        local cols = {}
                        local palette_cols = 0
                        local out = {}
                        local final = {}
                        for k,v in pairs(_temp) do
                            local hex = colors.packRGB(v.r,v.g,v.b)
                            if not cols[hex] then
                                palette_cols = palette_cols + 1
                                cols[hex] = {c=hex,count=0}
                            end
                            cols[hex].count = cols[hex].count + 1
                        end
                        for k,v in pairs(cols) do
                            table.insert(out,v)
                        end
                        table.sort(out,function(a,b) return a.count > b.count end)
                        for k,v in ipairs(out) do
                            local r,g,b = colors.unpackRGB(v.c)
                            table.insert(final,{r=r,g=g,b=b,c=v.count})
                        end
                        return final,palette_cols
                    end
                }
            end
        end
    else
        error("File is unsupported format: "..read_characters(file,0,1),2)
        file.close()
    end
end

local function decode(tbl)
    local output = setmetatable({},{
        __index=function(t,k)
            local new = {}
            t[k]=new
            return new
        end
    })
    output["offset"] = tbl["offset"]
    for k,v in pairs(tbl) do
        for ko,vo in pairs(v) do
            if type(vo) == "table" then
                output[k][ko] = {}
                if vo then
                    output[k][ko].t = loadCols[vo.t]
                    output[k][ko].b = loadCols[vo.b]
                    output[k][ko].s = vo.s 
                end
            end
        end
    end
    return setmetatable(output,getmetatable(tbl))
end

local function createNDarray(n, tbl)
    tbl = tbl or {}
    if n == 0 then return tbl end
    setmetatable(tbl, {__index = function(t, k)
        local new = createNDarray(n - 1)
        t[k] = new
        return new
    end})
    return tbl
end

local function get2DarraySquareWH(array)
    local minx, maxx = math.huge, -math.huge
    local miny,maxy = math.huge, -math.huge
    for x,yList in pairs(array) do
        minx, maxx = math.min(minx, x), math.max(maxx, x)
        for y,_ in pairs(yList) do
            miny, maxy = math.min(miny, y), math.max(maxy, y)
        end
    end
    return math.abs(minx)+maxx,math.abs(miny)+maxy
end

local function index_proximal_small(list,num)
    local diffirences = {}
    local outs = {}
    for k,v in pairs(list) do
        local diff = math.abs(k-num)
        diffirences[#diffirences+1],outs[diff] = diff,k
    end
    local proximal = math.min(table.unpack(diffirences))
    return list[outs[proximal]]
end
local function index_proximal_big(list,num) --credit to wojbie
    if not next(list) then return nil end
    if list[num] then return list[num] end
    local cur = math.floor(num+0.5)
    if list[cur] then return list[cur] end
    for i=1,math.huge do
        if list[cur+i] then return list[cur+i] end
        if list[cur-i] then return list[cur-i] end
    end
end
local function load_texture(file_name)
    local file,data
    if not (type(file_name) == "table") and (file_name:match(".nimg$") and fs.exists(file_name)) then
        file = fs.open(file_name,"r")
        if not file then error("file doesnt exist",2) end
        data = textutils.unserialise(file.readAll())
    else
        data = file_name
    end
    local nimg = createNDarray(2,decode(data))
    local temp = createNDarray(2)
    for x,dat in pairs(nimg) do
        if type(x) ~= "string" then
            for y,data in pairs(dat) do
                temp[x-nimg.offset[1]+1][y-nimg.offset[2]+5] = {
                    text_color=data.t,
                    background_color=data.b,
                    symbol=data.s
                }
            end
        end
    end
    temp.scale = {get2DarraySquareWH(temp)}
    return {
        tex=temp,
        offset=nimg.offset
    }
end

local function get_color(terminal,c)
    local palette = {}
    for i=0,15 do
        local r,g,b = terminal.getPaletteColor(2^i) 
        table.insert(palette,{
            dist=math.sqrt((r-c.r)^2 + (g-c.g)^2 + (b-c.b)^2),
            color=2^i
        })
    end
    table.sort(palette,function(a,b) return a.dist < b.dist end)
    return palette[1].color
end

local function build_drawing_char(arr,mode)
    local cols,fin,char,visited = {},{},{},{}
    local entries = 0
    for k,v in pairs(arr) do
        cols[v] = cols[v] ~= nil and
            {count=cols[v].count+1,c=cols[v].c}
            or (function() entries = entries + 1 return {count=1,c=v} end)()
    end
    for k,v in pairs(cols) do
        if not visited[v.c] then
            visited[v.c] = true
            if entries == 1 then table.insert(fin,v) end
            table.insert(fin,v)
        end
    end
    table.sort(fin,function(a,b) return a.count > b.count end)
    for k=1,6 do
        if arr[k] == fin[1].c then char[k] = 1
        elseif arr[k] == fin[2].c then char[k] = 0
        else char[k] = mode and 0 or 1 end
    end
    if char[6] == 1 then for i = 1, 5 do char[i] = 1-char[i] end end
    local n = 128
    for i = 0, 4 do n = n + char[i+1]*2^i end
    return string.char(n),char[6] == 1 and fin[2].c or fin[1].c,char[6] == 1 and fin[1].c or fin[2].c
end

local function set_symbols_xy(tbl,x,y,val)
    tbl[x+y*2-2] = val
    return tbl
end

local function load_ppm_texture(file,terminal,mode)
    local img = decode_ppm(file)
    if img then
        local char_arrays = {}
        for x=1,img.width do
            for y=1,img.height do
                local c = get_color(terminal or term.current(),img.get_pixel(x,y))
                local rel_x,rel_y = math.ceil(x/2),math.ceil(y/3)
                local sym_x,sym_y = (x-1)%2+1,(y-1)%3+1
                if not char_arrays[rel_x] then char_arrays[rel_x] = {} end
                char_arrays[rel_x][rel_y] = set_symbols_xy(char_arrays[rel_x][rel_y] or {},sym_x,sym_y,c)
                os.queueEvent("")
                os.pullEvent("")
            end
        end
        local texture_raw = createNDarray(2,{
            offset = {5, 13, 11, 4}
        })
        for x,yList in pairs(char_arrays) do
            for y,sym_data in pairs(yList) do
                local char,fg,bg = build_drawing_char(sym_data,mode)
                texture_raw[x+4][y+8] = {
                    s=char,
                    t=saveCols[fg],
                    b=saveCols[bg]
                }
            end
        end
        return load_texture(texture_raw),img
    end
end
local function get_pixel(tex,x,y,fill_empty)
    local texture = tex.tex
    local w,h = math.floor(texture.scale[1]-0.5),math.floor(texture.scale[2]-0.5)
    x = ((x-1)%w)+1
    y = ((y-1)%h)+1
    local pixel = texture[x][y]
    local scale = texture.scale
    texture.scale = nil
    if not pixel and fill_empty then
        local x_proximal = index_proximal_small(texture,x)
        pixel = index_proximal_big(x_proximal or {},y)
    end
    texture.scale = scale
    return pixel
end

local function draw_box_tex(term,tex,x,y,width,height,bg,tg)
    local bg_layers = {}
    local fg_layers = {}
    local text_layers = {}
    for yis=1,height do
        for xis=1,width do
            local pixel = get_pixel(tex,xis,yis)
            if pixel then
                bg_layers[yis] = (bg_layers[yis] or "")..saveCols[pixel.background_color]
                fg_layers[yis] = (fg_layers[yis] or "")..saveCols[pixel.text_color]
                text_layers[yis] = (text_layers[yis] or "")..pixel.symbol
            else
                bg_layers[yis] = (bg_layers[yis] or "")..saveCols[bg]
                fg_layers[yis] = (fg_layers[yis] or "")..saveCols[tg]
                text_layers[yis] = (text_layers[yis] or "").." "
            end
        end
    end
    for k,v in pairs(bg_layers) do
        term.setCursorPos(x,y+k-1)
        term.blit(text_layers[k],fg_layers[k],bg_layers[k])
    end
end

return {
    load_texture=load_texture,
    load_ppm_texture=load_ppm_texture,
    code={
        get_pixel=get_pixel,
        draw_box_tex=draw_box_tex,
        to_blit=saveCols,
        to_color=loadCols,
        build_drawing_char=build_drawing_char
    }
}
