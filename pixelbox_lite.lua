--[[
    * api for easy interaction with drawing characters

    * single file implementation of GuiH pixelbox api

    * this version is very fast and ment for implementing into other apis
]]

local PIXELBOX = {}
local OBJECT = {}
local graphic = {}

local CEIL  = math.ceil
local t_sort = table.sort
local s_char = string.char
local distances = {
    {5,256,16,8,64,32},
    {4,16,16384,256,128},
    [4]    ={4,64,1024,256,128},
    [8]    ={4,512,2048,256,1},
    [16]   ={4,2,16384,256,1},
    [32]   ={4,8192,4096,256,1},
    [64]   ={4,4,1024,256,1},
    [128]  ={6,32768,256,1024,2048,4096,16384},
    [256]  ={6,1,128,2,512,4,8192},
    [512]  ={4,8,2048,256,128},
    [1024] ={4,4,64,128,32768},
    [2048] ={4,512,8,128,32768},
    [4096] ={4,8192,32,128,32768},
    [8192] ={3,32,4096,256128},
    [16384]={4,2,16,128,32768},
    [32768]={5,128,1024,2048,4096,16384}
}

local chars = "0123456789abcdef"
graphic.to_blit = {}
graphic.logify  = {}
for i = 0, 15 do
    graphic.to_blit[2^i] = chars:sub(i + 1, i + 1)
    graphic.logify [2^i] = i
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

function PIXELBOX.RESTORE(BOX,color)
    local bc = {}
    local chars = {}

    for y=1,BOX.height*3 do
        for x=1,BOX.width*2 do
            if not bc[y] then bc[y] = {} end
            bc[y][x] = color
        end
    end
    for y=1,BOX.height do
        for x=1,BOX.width do
            if not chars[y] then chars[y] = {} end
            chars[y][x] = {symbol=" ",background=graphic.to_blit[color],fg="f"}
        end
    end

    BOX.CANVAS = bc
    BOX.CHARS = chars
    BOX.UPDATES = {}
end

local blck = colors.black
function OBJECT:push_updates()
    self.symbols = {}
    local newlines = {}
    for i=1,self.height do
        newlines[i] = {"","",""}
    end
    self.lines = newlines
    self.pixels = createNDarray(1)
    for y=1,self.height*3,3 do
        local canv = self.CANVAS
        local layer_1 = canv[y]
        local layer_2 = canv[y+1]
        local layer_3 = canv[y+2]
        for x=1,self.width*2,2 do
            local block_color = {
                layer_1[x],layer_1[x+1],
                layer_2[x],layer_2[x+1],
                layer_3[x],layer_3[x+1]
            }
            local B1 = layer_1[x]
            local SCREEN_X = CEIL(x/2)
            local SCREEN_Y = CEIL(y/3)
            local LINES_Y = self.lines[SCREEN_Y]
            local C = self.CHARS
            local b2,b3,b4,b5,b6 = block_color[2],block_color[3],block_color[4],block_color[5],block_color[6]
            if not self.UPDATES[SCREEN_Y] then self.UPDATES[SCREEN_Y] = {} end
            if self.UPDATES[SCREEN_Y][SCREEN_X] or not self.prev_data then
                local char,fg,bg = " ",blck,B1
                if not (b2 == B1
                    and b3 == B1
                    and b4 == B1
                    and b5 == B1
                    and b6 == B1) then
                    char,fg,bg = graphic.build_drawing_char(block_color)
                    if not C[y] then C[y] = {} end
                    C[y][x] = {symbol=char, background=graphic.to_blit[bg], fg=graphic.to_blit[fg]}
                end
                self.lines[SCREEN_Y] = {
                    LINES_Y[1]..char,
                    LINES_Y[2]..graphic.to_blit[fg],
                    LINES_Y[3]..graphic.to_blit[bg]
                }
            else
                local prev_data = self.CHARS[y][x]
                self.lines[SCREEN_Y] = {
                    LINES_Y[1]..prev_data.symbol,
                    LINES_Y[2]..prev_data.fg,
                    LINES_Y[3]..prev_data.background
                }
            end
            self.pixels[y][x]     = block_color[1]
            self.pixels[y][x+1]   = b2
            self.pixels[y+1][x]   = b3
            self.pixels[y+1][x+1] = b4
            self.pixels[y+2][x]   = b5
            self.pixels[y+2][x+1] = b6
        end
    end
    local t = {}
    os.queueEvent(tostring(t))
    os.pullEvent(tostring(t))
    self.UPDATES = createNDarray(1)
end

function OBJECT:clear(color)
    PIXELBOX.RESTORE(self,color)
end

function OBJECT:draw()
    for y,line in ipairs(self.lines) do
        self.term.setCursorPos(1,y)
        self.term.blit(
            table.unpack(line)
        )
    end
end

function OBJECT:set_pixel(x,y,color)
    local spx = self.pixels
    if not spx or spx[y][x] ~= color then
        local y = CEIL(y/3)
        local u = self.UPDATES
        if not u[y] then u[y] = {} end
        u[y][CEIL(x/2)] = true
    end
    self.CANVAS[y][x] = color
end

function PIXELBOX.new(terminal,bg)
    local bg = bg or terminal.getBackgroundColor() or colors.black
    local BOX = {}
    local w,h = terminal.getSize()
    BOX.term = terminal
    setmetatable(BOX,{__index = OBJECT})
    BOX.width  = w
    BOX.height = h
    PIXELBOX.RESTORE(BOX,bg)
    return BOX
end

local function sort(a,b) return a[2] > b[2] end
function graphic.build_drawing_char(arr)
    local c_types = {}
    local sortable = {}
    local ind = 0
    for i=1,6 do
        local c = arr[i]
        if not c_types[c] then
            ind = ind + 1
            c_types[c] = {0,ind}
        end
        local t = c_types[c]

        t[1] = t[1] + 1
        sortable[t[2]] = {c,t[1]}
    end
    local n = #sortable
    while n > 2 do
        t_sort(sortable,sort)
        local bit6 = distances[sortable[n][1]]
        local index,run = 1,false
        for i=2,bit6[1] do
            if run then break end
            local tab = bit6[i]
            for j=1,n-1 do
                if sortable[j][1] == tab then
                    index = j
                    run = true
                    break
                end
            end
        end
        local from,to = sortable[n][1],sortable[index][1]
        for i=1,6 do
            if arr[i] == from then
                arr[i] = to
                local sindex = sortable[index]
                sindex[2] = sindex[2] + 1
            end
        end

        sortable[n] = nil
        n = n - 1
    end

    local n = 128
    for i = 1, #arr - 1 do
        if arr[i] ~= arr[6] then n = n + 2^(i-1) end
    end

    if sortable[1][1] == arr[6] then
        return s_char(n),sortable[2][1],arr[6]
    else
        return s_char(n),sortable[1][1],arr[6]
    end
end

return PIXELBOX
