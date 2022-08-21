--[[
    * api for easy interaction with drawing characters

    * single file implementation of GuiH pixelbox api
]]

local EXPECT = require("cc.expect").expect

local PIXELBOX = {}
local OBJECT = {}
local api = {}
local ALGO = {}
local graphic = {}

local CEIL  = math.ceil
local FLOOR = math.floor
local SQRT  = math.sqrt
local MIN   = math.min
local ABS   = math.abs
local t_insert, t_unpack, t_sort, s_char, pairs = table.insert, table.unpack, table.sort, string.char, pairs

local chars = "0123456789abcdef"
graphic.to_blit = {}
graphic.logify  = {}
for i = 0, 15 do
    graphic.to_blit[2^i] = chars:sub(i + 1, i + 1)
    graphic.logify [2^i] = i
end

function PIXELBOX.INDEX_SYMBOL_CORDINATION(tbl,x,y,val)
    tbl[x+y*2-2] = val
    return tbl
end

function OBJECT:within(x,y)
    return x > 0
        and y > 0
        and x <= self.width*2
        and y <= self.height*3
end

function PIXELBOX.RESTORE(BOX,color)
    BOX.CANVAS = api.createNDarray(1)
    BOX.UPDATES = api.createNDarray(1)
    BOX.CHARS = api.createNDarray(1)
    for y=1,BOX.height*3 do
        for x=1,BOX.width*2 do
            BOX.CANVAS[y][x] = color
        end
        os.queueEvent("yield")
        os.pullEvent("yield")
    end
    for y=1,BOX.height do
        for x=1,BOX.width do
            BOX.CHARS[y][x] = {symbol=" ",background=graphic.to_blit[color],fg="f"}
        end
    end
    getmetatable(BOX.CANVAS).__tostring = function() return "PixelBOX_SCREEN_BUFFER" end
end

function OBJECT:push_updates()
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    self.symbols = api.createNDarray(2)
    self.lines = api.create_blit_array(self.height)
    self.pixels = api.createNDarray(1)
    local SYMBOL_COLORS = api.createNDarray(1)
    local SYMBOL_LUT =    api.createNDarray(2)
    getmetatable(self.symbols).__tostring=function() return "PixelBOX.SYMBOL_BUFFER" end
    setmetatable(self.lines,{__tostring=function() return "PixelBOX.LINE_BUFFER" end})
    for y=1,#self.CANVAS do
        local x_list = self.CANVAS[y]
        for x=1,#x_list do
            local block_color = x_list[x]
            local RELATIVE_X = CEIL(x/2)
            local RELATIVE_Y = CEIL(y/3)
            if self.UPDATES[RELATIVE_Y][RELATIVE_X] then
                local SYMBOL_POS_X = (x-1)%2+1
                local SYMBOL_POS_Y = (y-1)%3+1
                if not SYMBOL_LUT[RELATIVE_Y][RELATIVE_X][block_color] then
                    if not SYMBOL_COLORS[RELATIVE_Y][RELATIVE_X] then SYMBOL_COLORS[RELATIVE_Y][RELATIVE_X] = 0 end
                    SYMBOL_COLORS[RELATIVE_Y][RELATIVE_X] = SYMBOL_COLORS[RELATIVE_Y][RELATIVE_X] + 1
                    SYMBOL_LUT[RELATIVE_Y][RELATIVE_X][block_color] = true
                end
                self.symbols[RELATIVE_Y][RELATIVE_X] = PIXELBOX.INDEX_SYMBOL_CORDINATION(
                    self.symbols[RELATIVE_Y][RELATIVE_X],
                    SYMBOL_POS_X,SYMBOL_POS_Y,
                    block_color
                )
                self.pixels[y][x] = block_color
            end
        end
        os.queueEvent("yield")
        os.pullEvent("yield")
    end
    local function add_prev(x,y)
        local prev_data = self.CHARS[y][x]
        self.lines[y] = {
            self.lines[y][1]..prev_data.symbol,
            self.lines[y][2]..prev_data.fg,
            self.lines[y][3]..prev_data.background
        }
    end
    local function generate_char(x,y)
        local color_block = self.symbols[y][x]
        local char,fg,bg = " ",colors.black,color_block[1]
        if SYMBOL_COLORS[y][x] > 1 then
            char,fg,bg = graphic.build_drawing_char(color_block)
        end
        self.CHARS[y][x] = {symbol=char, background=graphic.to_blit[bg], fg=graphic.to_blit[fg]}
        self.lines[y] = {
            self.lines[y][1]..char,
            self.lines[y][2]..graphic.to_blit[fg],
            self.lines[y][3]..graphic.to_blit[bg]
        }
    end
    for y=1,self.height do
        for x=1,self.width do
            local terminal_data = self.terminal_map[y][x]
            if self.UPDATES[y][x] and (terminal_data and terminal_data.clear) then
                generate_char(x,y)
            elseif terminal_data and not terminal_data.clear then
                self.lines[y] = {
                    self.lines[y][1]..terminal_data[1],
                    self.lines[y][2]..graphic.to_blit[terminal_data[2]],
                    self.lines[y][3]..graphic.to_blit[terminal_data[3]]
                }
            else
                add_prev(x,y)
            end
        end
        os.queueEvent("yield")
        os.pullEvent("yield")
    end
    self.UPDATES = api.createNDarray(1)
end

function OBJECT:get_pixel(x,y)
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,x,"number")
    EXPECT(2,y,"number")
    assert(self.CANVAS[y] and self.CANVAS[y][x],"Out of range")
    return self.CANVAS[y][x]
end

function OBJECT:clear(color)
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,color,"number")
    PIXELBOX.RESTORE(self,color)
end

function OBJECT:draw()
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    if not self.lines then error("You must push_updates in order to draw",2) end
    for y,line in ipairs(self.lines) do
        self.term.setCursorPos(1,y)
        self.term.blit(
            table.unpack(line)
        )
    end
end

function OBJECT:set_pixel(x,y,color,thiccness,base)
    if not base then
        PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
        EXPECT(1,x,"number")
        EXPECT(2,y,"number")
        EXPECT(3,color,"number")
        PIXELBOX.ASSERT(x>0 and x<=self.width*2,"Out of range")
        PIXELBOX.ASSERT(y>0 and y<=self.height*3,"Out of range")
        thiccness = thiccness or 1
        local t_ratio = (thiccness-1)/2
        self:set_box(
            CEIL(x-t_ratio),
            CEIL(y-t_ratio),
            x+thiccness-1,y+thiccness-1,color,true
        )
    else
        local RELATIVE_X = CEIL(x/2)
        local RELATIVE_Y = CEIL(y/3)
        self.UPDATES[RELATIVE_Y][RELATIVE_X] = true
        self.CANVAS[y][x] = color
    end
end

function OBJECT:set_pixel_raw(x,y,color)
    local RELATIVE_X = CEIL(x/2)
    local RELATIVE_Y = CEIL(y/3)
    if not self.pixels or self.pixels[y][x] ~= color then
        self.UPDATES[RELATIVE_Y][RELATIVE_X] = true
    end
    self.CANVAS[y][x] = color
end

function OBJECT:set_box(sx,sy,ex,ey,color,check)
    if not check then
        PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
        EXPECT(1,sx,"number")
        EXPECT(2,sy,"number")
        EXPECT(3,ex,"number")
        EXPECT(4,ey,"number")
        EXPECT(5,color,"number")
    end
    for y=sy,ey do
        for x=sx,ex do
            if self:within(x,y) then
                local RELATIVE_X = CEIL(x/2)
                local RELATIVE_Y = CEIL(y/3)
                self.UPDATES[RELATIVE_Y][RELATIVE_X] = true
                self.CANVAS[y][x] = color
            end
        end
    end
end

function OBJECT:set_ellipse(x,y,rx,ry,color,filled,thiccness,check)
    if not check then
        PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
        EXPECT(1,x,"number")
        EXPECT(2,y,"number")
        EXPECT(3,rx,"number")
        EXPECT(4,ry,"number")
        EXPECT(5,color,"number")
        EXPECT(6,filled,"boolean","nil")
    end
    thiccness = thiccness or 1
    local t_ratio = (thiccness-1)/2 
    if type(filled) ~= "boolean" then filled = true end
    local points = ALGO.get_elipse_points(rx,ry,x,y,filled)
    for _,point in ipairs(points) do
        if self:within(point.x,point.y) then
            self:set_box(
                CEIL(point.x-t_ratio),
                CEIL(point.y-t_ratio),
                point.x+thiccness-1,point.y+thiccness-1,color,true
            )
        end
    end
end

function OBJECT:set_circle(x,y,radius,color,filled,thiccness)
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,x,"number")
    EXPECT(2,y,"number")
    EXPECT(3,radius,"number")
    EXPECT(4,color,"number")
    EXPECT(5,filled,"boolean","nil")
    self:set_ellipse(x,y,radius,radius,color,filled,thiccness,true)
end

function OBJECT:set_triangle(x1,y1,x2,y2,x3,y3,color,filled,thiccness)
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,x1,"number")
    EXPECT(2,y1,"number")
    EXPECT(3,x2,"number")
    EXPECT(4,y2,"number")
    EXPECT(5,x3,"number")
    EXPECT(6,y3,"number")
    EXPECT(7,color,"number")
    EXPECT(8,filled,"boolean","nil")
    thiccness = thiccness or 1
    local t_ratio = (thiccness-1)/2 
    if type(filled) ~= "boolean" then filled = true end
    local points
    if filled then points = ALGO.get_triangle_points(
        vector.new(x1,y1),
        vector.new(x2,y2),
        vector.new(x3,y3)
    )
    else points = ALGO.get_triangle_outline_points(
        vector.new(x1,y1),
        vector.new(x2,y2),
        vector.new(x3,y3)
    ) end
    for _,point in ipairs(points) do
        if self:within(point.x,point.y) then
            self:set_box(
                CEIL(point.x-t_ratio),
                CEIL(point.y-t_ratio),
                point.x+thiccness-1,point.y+thiccness-1,color,true
            )
        end
    end
end

function OBJECT:set_line(x1,y1,x2,y2,color,thiccness)
    PIXELBOX.ASSERT(type(self)=="table","Please use \":\" when running this function")
    EXPECT(1,x1,"number")
    EXPECT(2,y1,"number")
    EXPECT(3,x2,"number")
    EXPECT(4,y2,"number")
    EXPECT(5,color,"number")
    thiccness = thiccness or 1
    local t_ratio = (thiccness-1)/2 
    local points = ALGO.get_line_points(x1,y1,x2,y2)
    for _,point in ipairs(points) do
        if self:within(point.x,point.y) then
            self:set_box(
                CEIL(point.x-t_ratio),
                CEIL(point.y-t_ratio),
                point.x+thiccness-1,point.y+thiccness-1,color,true
            )
        end
    end
end

function PIXELBOX.CREATE_TERM(pixelbox)
    local object = {}
    pixelbox.terminal_map = api.createNDarray(1)
    local map = pixelbox.terminal_map
    pixelbox.show_clears        = false

    local current_fg        = pixelbox.term.getTextColor()
    local current_bg        = pixelbox.term.getBackgroundColor()
    local cursor_x,cursor_y = pixelbox.term.getCursorPos()

    local function create_line(w,y,first)
        local line = {}
        for i=1,w do
            if not first then
                if not map[y][i].clear then
                    pixelbox.UPDATES[y][i] = true
                end
            end
            line[i] = {
                " ",current_fg,current_bg,clear=not pixelbox.show_clears
            }
        end
        return line
    end

    local function clear_object(object,first)
        local w,h = pixelbox.term.getSize()
        for y=1,h do
            object[y] = create_line(w,y,first)
        end
    end

    clear_object(map,true)

    function object.blit(chars,fg,bg)
        chars,fg,bg = chars:lower(),fg:lower(),bg:lower()
        local len = #chars
        if #bg == len and #fg == len then
            for i=1,#chars do
                local char  = chars:sub(i,i)
                local fgbit = 2^tonumber(fg:sub(i,i),16)
                local bgbit = 2^tonumber(bg:sub(i,i),16)
                map[cursor_y][cursor_x+i-1] = {char,fgbit,bgbit,clear=false}
            end
        else
            error("Arguments must be the same lenght",2)
        end
    end

    function object.write(chars)
        for i=1,#chars do
            local char  = chars:sub(i,i)
            map[cursor_y][cursor_x+i-1] = {char,current_fg,current_bg,clear=false}
        end
    end

    function object.clear()
        clear_object(map)
    end

    function object.getLine(y)
        local char,bg,fg = "","",""
        local w = pixelbox.term.getSize()
        for x=1,w do
            local point = map[y][x]
            if not point.clear then
                char = char .. point[1]
                bg   = bg   .. point[2]
                fg   = fg   .. point[3]
            else
                char = char .. " "
                fg   = fg   .. graphic.to_blit[current_fg]
                bg   = bg   .. graphic.to_blit[current_bg]
            end
        end
        return char,bg,fg
    end

    function object.clearLine()
        local w = pixelbox.term.getSize()
        map[cursor_y] = create_line(w,cursor_y)
    end

    function object.scroll(y)
        local w,h = pixelbox.term.getSize()
        if y ~= 0 then
            local temp = api.createNDarray(1)
            clear_object(temp)
            for cy=1,h do
                if cy-y > h then break end
                temp[cy-y] = map[cy]
            end
            pixelbox.terminal_map = temp
            map = temp
        end
    end

    function object.setBackgroundColor (bg)  current_bg = bg end
    function object.setBackgroundColour(bg)  current_bg = bg end
    function object.setTextColor (fg)        current_fg = fg end
    function object.setTextColour(fg)        current_fg = fg end
    function object.setCursorPos(x,y)        cursor_x,cursor_y = x,y end
    function object.setCursorBlink(...)      pixelbox.term.setCursorBlink(...) end
    function object.restoreCursor()          pixelbox.term.setCursorPos(cursor_x,cursor_y) end
    function object.setPaletteColor (...)    pixelbox.term.setPaletteColor(...) end
    function object.setPaletteColour(...)    pixelbox.term.setPaletteColor(...) end
    function object.getBackgroundColor ()    return current_bg end
    function object.getBackgroundColour()    return current_bg end
    function object.getCursorBlink()         return pixelbox.term.getCursorBlink() end
    function object.getCursorPos()           return cursor_x,cursor_y end
    function object.getPaletteColor (...)    return pixelbox.term.getPaletteColor(...) end
    function object.getPaletteColour(...)    return pixelbox.term.getPaletteColor(...) end
    function object.getSize(...)             return pixelbox.term.getSize(...) end
    function object.getTextColor()           return current_fg end
    function object.getTextColour()          return current_fg end
    function object.isColor()                return pixelbox.term.isColor() end
    function object.isColour()               return pixelbox.term.isColor() end

    object.drawPixels      = pixelbox.term.drawPixels
    object.getVisible      = pixelbox.term.getVisible
    object.getPixel        = pixelbox.term.getPixel
    object.getPixels       = pixelbox.term.getPixels
    object.getPosition     = pixelbox.term.getPosition
    object.isVisible       = pixelbox.term.isVisible
    object.redraw          = pixelbox.term.redraw
    object.reposition      = pixelbox.term.reposition
    object.setVisible      = pixelbox.term.setVisible
    object.showMouse       = pixelbox.term.showMouse

    function object.clear_visibility(state) pixelbox.show_clears = state end

    return object
end

function PIXELBOX.ASSERT(condition,message)
    if not condition then error(message,3) end
    return condition
end

function PIXELBOX.new(terminal,bg)
    EXPECT(1,terminal,"table")
    EXPECT(2,bg,"number","nil")
    local bg = bg or terminal.getBackgroundColor() or colors.black
    local BOX = {}
    local w,h = terminal.getSize()
    BOX.term = terminal
    setmetatable(BOX,{__index = OBJECT})
    BOX.width  = w
    BOX.height = h
    PIXELBOX.RESTORE(BOX,bg)
    BOX.emu    = PIXELBOX.CREATE_TERM(BOX)
    return BOX
end

function ALGO.get_elipse_points(radius_x,radius_y,xc,yc,filled)
    local rx,ry = CEIL(FLOOR(radius_x-0.5)/2),CEIL(FLOOR(radius_y-0.5)/2)
    local x,y=0,ry
    local d1 = ((ry * ry) - (rx * rx * ry) + (0.25 * rx * rx))
    local dx = 2*ry^2*x
    local dy = 2*rx^2*y
    local points = {}
    while dx < dy do
        table.insert(points,{x=x+xc,y=y+yc})
        table.insert(points,{x=-x+xc,y=y+yc})
        table.insert(points,{x=x+xc,y=-y+yc})
        table.insert(points,{x=-x+xc,y=-y+yc})
        if filled then
            for y=-y+yc+1,y+yc-1 do
                table.insert(points,{x=x+xc,y=y})
                table.insert(points,{x=-x+xc,y=y})
            end
        end
        if d1 < 0 then
            x = x + 1
            dx = dx + 2*ry^2
            d1 = d1 + dx + ry^2
        else
            x,y = x+1,y-1
            dx = dx + 2*ry^2
            dy = dy - 2*rx^2
            d1 = d1 + dx - dy + ry^2
        end
    end
    local d2 = (((ry * ry) * ((x + 0.5) * (x + 0.5))) + ((rx * rx) * ((y - 1) * (y - 1))) - (rx * rx * ry * ry))
    while y >= 0 do
        table.insert(points,{x=x+xc,y=y+yc})
        table.insert(points,{x=-x+xc,y=y+yc})
        table.insert(points,{x=x+xc,y=-y+yc})
        table.insert(points,{x=-x+xc,y=-y+yc})
        if filled then
            for y=-y+yc,y+yc do
                table.insert(points,{x=x+xc,y=y})
                table.insert(points,{x=-x+xc,y=y})
            end
        end
        if d2 > 0 then
            y = y - 1
            dy = dy - 2*rx^2
            d2 = d2 + rx^2 - dy
        else
            y = y - 1
            x = x + 1
            dy = dy - 2*rx^2
            dx = dx + 2*ry^2
            d2 = d2 + dx - dy + rx^2
        end
    end
    return points
end

local function drawFlatTopTriangle(points,vec1,vec2,vec3)
    local n = #points
    local m1 = (vec3.x - vec1.x) / (vec3.y - vec1.y)
    local m2 = (vec3.x - vec2.x) / (vec3.y - vec2.y)
    local yStart = CEIL(vec1.y - 0.5)
    local yEnd =   CEIL(vec3.y - 0.5)-1
    for y = yStart, yEnd do
        local px1 = m1 * (y + 0.5 - vec1.y) + vec1.x
        local px2 = m2 * (y + 0.5 - vec2.y) + vec2.x
        local xStart = CEIL(px1 - 0.5)
        local xEnd =   CEIL(px2 - 0.5)
        for x=xStart,xEnd do
            n = n + 1
            points[n] = {x=x,y=y}
        end
    end
end

local function drawFlatBottomTriangle(points,vec1,vec2,vec3)
    local n = #points
    local m1 = (vec2.x - vec1.x) / (vec2.y - vec1.y)
    local m2 = (vec3.x - vec1.x) / (vec3.y - vec1.y)
    local yStart = CEIL(vec1.y-0.5)
    local yEnd =   CEIL(vec3.y-0.5)-1
    for y = yStart, yEnd do
        local px1 = m1 * (y + 0.5 - vec1.y) + vec1.x
        local px2 = m2 * (y + 0.5 - vec1.y) + vec1.x
        local xStart = CEIL(px1 - 0.5)
        local xEnd =   CEIL(px2 - 0.5)
        for x=xStart,xEnd do
            n = n + 1
            points[n] = {x=x,y=y}
        end
    end
end
function ALGO.get_triangle_points(pv1,pv2,pv3)
    local points = {}
    local n = 0
    if pv2.y < pv1.y then pv1,pv2 = pv2,pv1 end
    if pv3.y < pv2.y then pv2,pv3 = pv3,pv2 end
    if pv2.y < pv1.y then pv1,pv2 = pv2,pv1 end
    if pv1.y == pv2.y then
        if pv2.x < pv1.x then pv1,pv2 = pv2,pv1 end
        drawFlatTopTriangle(points,pv1,pv2,pv3)
    elseif pv2.y == pv3.y then
        if pv3.x < pv2.x then pv3,pv2 = pv2,pv3 end
        drawFlatBottomTriangle(points,pv1,pv2,pv3)
    else 
        local alphaSplit = (pv2.y-pv1.y)/(pv3.y-pv1.y)
        local vi ={ 
            x = pv1.x + ((pv3.x - pv1.x) * alphaSplit),      
            y = pv1.y + ((pv3.y - pv1.y) * alphaSplit), }
        if pv2.x < vi.x then
            drawFlatBottomTriangle(points,pv1,pv2,vi)
            drawFlatTopTriangle(points,pv2,vi,pv3)
        else
            drawFlatBottomTriangle(points,pv1,vi,pv2)
            drawFlatTopTriangle(points,vi,pv2,pv3)
        end
    end
    return points
end
function ALGO.get_line_points(startX, startY, endX, endY)
    local n = 1
    local points = {}
    startX,startY,endX,endY = FLOOR(startX),FLOOR(startY),FLOOR(endX),FLOOR(endY)
    if startX == endX and startY == endY then return {{x=startX,y=startY}} end
    local minX = MIN(startX, endX)
    local maxX, minY, maxY
    if minX == startX then minY,maxX,maxY = startY,endX,endY
    else minY,maxX,maxY = endY,startX,startY end
    local xDiff,yDiff = maxX - minX,maxY - minY
    if xDiff > ABS(yDiff) then
        local y = minY
        local dy = yDiff / xDiff
        for x = minX, maxX do
            n = n + 1
            points[n] = {x=x,y=FLOOR(y + 0.5)}
            y = y + dy
        end
    else
        local x,dx = minX,xDiff / yDiff
        if maxY >= minY then
            for y = minY, maxY do
                n = n + 1
                points[n] = {x=FLOOR(x + 0.5),y=y}
                x = x + dx
            end
        else
            for y = minY, maxY, -1 do
                n = n + 1
                points[n] = {x=FLOOR(x + 0.5),y=y}
                x = x - dx
            end
        end
    end
    return points
end
function ALGO.get_triangle_outline_points(v1,v2,v3)
    local final_points = {}
    local s1 = ALGO.get_line_points(v1.x,v1.y,v2.x,v2.y)
    local s2 = ALGO.get_line_points(v2.x,v2.y,v3.x,v3.y)
    local s3 = ALGO.get_line_points(v3.x,v3.y,v1.x,v1.y)
    return api.merge_tables(s1,s2,s3)
end
function api.createNDarray(n, tbl)
    tbl = tbl or {}
    if n == 0 then return tbl end
    setmetatable(tbl, {__index = function(t, k)
        local new = api.createNDarray(n - 1)
        t[k] = new
        return new
    end})
    return tbl
end
function api.create_blit_array(count)
    local out = {}
    for i=1,count do
        out[i] = {"","",""}
    end
    return out
end
function api.create_byte_array(count)
    local out = {}
    for i=1,count do
        out[i] = ""
    end
    return out
end
function api.merge_tables(...)
    local out = {}
    local n = 1
    for k,v in pairs({...}) do
        for _k,_v in pairs(v) do out[n] = _v n=n+1 end
    end
    return out
end
function api.get_closest_color(palette,c)
    local result = {}
    local n = 0
    for k,v in pairs(palette) do
        n=n+1
        result[n] = {
            dist=SQRT(
                (v[1]-c[1])^2 +
                (v[2]-c[2])^2 +
                (v[3]-c[3])^2
            ),  color=k
        }
    end
    table.sort(result,function(a,b) return a.dist < b.dist end)
    return result[1].color
end
function api.convert_color_255(r,g,b)
    return r*255,g*255,b*255
end
function api.hex_to_palette(hex)
    local r = (FLOOR(hex/0x10000)%256)/255
    local g = (FLOOR(hex/0x100)%256)/255
    local b = (hex%256)/255
    return r,g,b
end
function api.update_palette(updater,palette)
    for k,v in pairs(palette) do
        updater(k,table.unpack(v))
    end
end
function api.update(box)
    box:push_updates()
    box:draw()
end

local BUILDS = {}
local count_sort = function(a,b) return a.count > b.count end
function graphic.build_drawing_char(arr)
    local cols,fin,char,visited = {},{},{},{}
    local entries = 0
    local build_id = ""
    for k = 1, 6 do
        build_id = build_id .. ("%x"):format(graphic.logify[arr[k]])
        if cols[arr[k]] == nil then
            entries = entries + 1
            cols[arr[k]] = {count=1,c=arr[k]}
        else cols[arr[k]] = {count=cols[arr[k]].count+1,c=cols[arr[k]].c}
        end
    end
    if not BUILDS[build_id] then
        for k,v in pairs(cols) do
            if not visited[v.c] then
                visited[v.c] = true
                if entries == 1 then t_insert(fin,v) end
                t_insert(fin,v)
            end
        end
        t_sort(fin, count_sort)
        local swap = true
        for k=1,6 do
            if arr[k] == fin[1].c then char[k] = 1
            elseif arr[k] == fin[2].c then char[k] = 0
            else
                swap = not swap
                char[k] = swap and 1 or 0
            end
        end
        if char[6] == 1 then for i = 1, 5 do char[i] = 1-char[i] end end
        local n = 128
        for i = 0, 4 do n = n + char[i+1]*2^i end
        if char[6] == 1 then BUILDS[build_id] = {s_char(n), fin[2].c, fin[1].c}
        else BUILDS[build_id] = {s_char(n), fin[1].c, fin[2].c}
        end
    end
    return t_unpack(BUILDS[build_id])
end

return PIXELBOX
