--[=====[
MIT License
Copyright (c) 2022 Oliver Caha
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]=====]


local files={
  [ "modules/timer" ] = "local timer = {}\
local generic = require(\"common.generic\")\
local is_craftos = _HOST:find(\"CraftOS%-PC\")\
\
return function(BUS)\
    function timer.step()\
        BUS.timer.last_delta = BUS.timer.temp_delta\
        return BUS.timer.last_delta\
    end\
\
    function timer.getDelta()\
        return BUS.timer.last_delta\
    end\
\
    function timer.sleep(time_seconds)\
        if time_seconds > 0.05 then sleep(time_seconds)\
        else\
            generic.precise_sleep(time_seconds)\
        end\
    end\
\
    function timer.getTime()\
        if is_craftos then\
            return os.epoch(\"nano\")/1000000000\
        else\
            return os.epoch(\"utc\")/1000\
        end\
    end\
\
    function timer.getAverageDelta()\
        local total = 0\
        for k,v in ipairs(BUS.frames) do\
            total = total + v.ft\
        end\
        return (total/#BUS.frames)/1000\
    end\
\
    function timer.getFPS()\
        return #BUS.frames\
    end\
\
    return timer\
end",
  [ "common/table_util" ] = "local tbls = {}\
\
function tbls.get_table_len(tbl)\
    local realLen = 0\
    for k,v in pairs(tbl) do\
        realLen = realLen + 1\
    end\
    return realLen,#tbl\
end\
\
local function keys(tbl)\
    local keys = {}\
    for k,_ in pairs(tbl) do\
        table.insert(keys,k)\
    end\
    return keys\
end\
\
function tbls.iterate_order(tbl,reversed)\
    local indice = 0\
    local keys = keys(tbl)\
    table.sort(keys, function(a, b)\
        if reversed then return b<a\
        else return a<b end\
    end)\
    return function()\
        indice = indice + 1\
        if tbl[keys[indice]] then return keys[indice],tbl[keys[indice]]\
        else return end\
    end\
end\
\
function tbls.merge_tables(...)\
    local out = {}\
    local n = 0\
    for k,v in pairs({...}) do\
        for _k,_v in pairs(v) do\
            n = n + 1\
            out[n] = _v\
        end\
    end\
    return out\
end\
\
function tbls.createNDarray(n, tbl)\
    tbl = tbl or {}\
    if n == 0 then return tbl end\
    setmetatable(tbl, {__index = function(t, k)\
        local new = tbls.createNDarray(n - 1)\
        t[k] = new\
        return new\
    end})\
    return tbl\
end\
\
function tbls.deepcopy(tbl)\
    local instance_seen = {}\
    local function copy(tbl)\
        local out = {}\
        instance_seen[tbl] = out\
        for k,v in pairs(tbl) do\
            local t = type(v) == \"table\"\
            if type(k) == \"table\" then k = tbls.deepcopy(k) end\
            if t and not instance_seen[v] then\
                local new_instance = copy(v)\
                instance_seen[v] = new_instance\
                out[k] = new_instance\
            elseif t and instance_seen[v] then\
                out[k] = instance_seen[v]\
            else out[k] = v end\
        end\
        return out\
    end\
    return copy(tbl)\
end\
\
function tbls.map_iterator(w,h)\
    return coroutine.wrap(function()\
        for y=1,h do\
            for x=1,w do\
                coroutine.yield(x,y)\
            end\
        end\
    end)\
end\
\
function tbls.reverse_table(tbl)\
    local sol = {}\
    for k,v in pairs(tbl) do\
        sol[#tbl-k+1] = v\
    end\
    return sol\
end\
\
return tbls",
  [ "core/callbacks/mousemoved" ] = "return {ev=\"mouse_move\",run=function(BUS,caller,ev,_,x,y)\
    if x ~= nil then\
        local change_x = x - (BUS.mouse.last_x or 0)\
        local change_y = y - (BUS.mouse.last_y or 0)\
        BUS.events[#BUS.events+1] = {\"mousemoved\",x*2,y*3,change_x,change_y,false}\
        BUS.mouse.last_x,BUS.mouse.last_y = x,y\
        if type(caller.mousemoved) == \"function\" then\
            caller.mousemoved(x*2,y*3,change_x,change_y,false)\
        end\
    end\
end,check_change=function(self,BUS,caller,x,y)\
    if x ~= BUS.mouse.last_x or y ~= BUS.mouse.last_y then\
        self.run(BUS,caller,\"mouse_move\",_,x,y)\
    end\
end}",
  [ "core/loaders/image/ppm" ] = "",
  [ "lib/logger" ] = "local path = fs.getDir(select(2,...)):match(\"(.+)%/.+$\")\
local typeList = {\
    {colors.red},\
    {colors.yellow},\
    {colors.white,colors.red},\
    {colors.white,colors.lime},\
    {colors.white,colors.lime},\
    {colors.white},\
    {colors.green},\
    {colors.gray},\
}\
local index = {\
    error=1,\
    warn=2,\
    fatal=3,\
    success=4,\
    message=6,\
    update=7,\
    info=8\
}\
local type_space = 15\
local revIndex = {}\
for k,v in pairs(index) do\
    revIndex[v] = k\
end\
local function remove_time(str)\
    local str = str:gsub(\"^%[%d-%:%d-% %a-]\",\"\")\
    return str\
end\
function index:dump()\
    local lastLog = \"\"\
    local nstr = 1\
    local outputInternal = {}\
    local str = \"\"\
    for k,v in ipairs(self.history) do\
        if lastLog == remove_time(v.str)..v.type then\
            nstr = nstr + 1\
            table.remove(outputInternal,#outputInternal)\
        else\
            nstr = 1\
        end\
        outputInternal[#outputInternal+1] = v.str\
        lastLog = remove_time(v.str)..v.type\
    end\
    for k,v in ipairs(outputInternal) do\
        str = str .. v .. \"\\n\"\
    end\
    local file = fs.open(path..\"/GuiH.log\",\"w\")\
    file.write(str)\
    file.close()\
    return str\
end\
local function write_to_log_internal(self,str,type)\
    local width,height = math.huge,math.huge\
    local str = tostring(str)\
    type = type or \"info\"\
    if self.lastLog == str..type then\
        self.nstr = self.nstr + 1\
    else\
        self.nstr = 1\
    end\
    self.lastLog = str..type\
    local timeStr = tostring(table.getn(self.history))..\": [\"..(os.date(\"%T\", os.epoch \"local\" / 1000) .. (\".%03d\"):format(os.epoch \"local\" % 1000)):gsub(\"%.\",\" \")..\"] \"\
    local lFg,lBg = unpack(typeList[type] or {})\
    local type_str = \"[\"..(revIndex[type] or \"info\")..\"]\"\
    local base = timeStr..type_str..(\" \"):rep(type_space-#type_str-#tostring(#self.history)-1)..\"\\127\"..str\
    local strWrt = base..(\" \"):rep(math.max(100-(#base),3))\
    table.insert(self.history,{\
        str=strWrt,\
        type=type\
    })\
end\
local function createLogInternal(title,titlesym,auto_dump,file)\
    titlesym = titlesym or \"-\"\
    local log = setmetatable({\
        lastLog=\"\",\
        nstr=1,\
        maxln=1,\
        history={},\
        title = title,\
        tsym=(#titlesym < 4) and titlesym or \"-\",\
        auto_dump=auto_dump\
    },{\
        __index=index,\
        __call=write_to_log_internal\
    })\
    log.lastLog = nil\
    return log\
end\
\
return {create_log=createLogInternal}",
  [ "core/threads/key_thread" ] = "return {make=function(ENV,BUS)\
    return coroutine.create(function()\
        while true do\
            while true do\
                local name,key,held = os.pullEvent()\
                if name == \"key\" then BUS.keyboard.pressed_keys[key] = {true,held} end\
                if name == \"key_up\" then BUS.keyboard.pressed_keys[key] = nil end\
                if name == \"mouse_click\" then BUS.mouse.held[key] = true end\
                if name == \"mouse_up\" then BUS.mouse.held[key] = nil end\
            end\
        end\
    end)\
end}",
  [ "modules/cc" ] = "local cc = {}\
\
local CEIL = math.ceil\
\
return function(BUS)\
\
    function cc.get_bus()\
        return BUS\
    end\
\
    function cc.quantize(enable)\
        BUS.cc.quantize = enable\
    end\
\
    function cc.dither(enable)\
        BUS.cc.dither = enable\
    end\
\
    function cc.dither_factor(factor)\
        BUS.cc.dither_factor = factor\
    end\
\
    function cc.fps_limit(limit)\
        BUS.cc.frame_time_min = 1/limit\
    end\
\
    function cc.clamp_color(color,limit)\
        return CEIL(color*limit)/limit\
    end\
\
    function cc.reserve_color(r,g,b)\
        local res = BUS.cc.reserved_colors\
        res[#res+1] = {r,g,b}\
    end\
\
    function cc.pop_reserved_color()\
        local res = BUS.cc.reserved_colors\
        res[#res] = nil\
    end\
\
    function cc.get_reserved_colors()\
        return BUS.cc.reserved_colors\
    end\
\
    function cc.remove_reserved_colors()\
        BUS.cc.reserved_colors = {}\
    end\
\
    function cc.reserve_spot(n,r,g,b)\
        local sp = BUS.cc.reserved_spots\
        sp[#sp+1] = {2^n,{r,g,b}}\
    end\
\
    function cc.pop_reserved_spot()\
        local sp = BUS.cc.reserved_spots\
        sp[#sp] = nil\
    end\
\
    function cc.remove_reserved_spots()\
        BUS.cc.reserved_spots = {}\
    end\
\
    return cc\
end",
  [ "common/window_util" ] = "local wUtil = {}\
\
function wUtil.get_parent_info(term_object)\
    local event_offset_x,event_offset_y,deepest = 0,0,term_object\
    pcall(function()\
        local function get_ev_offset(terminal)\
            local x,y = terminal.getPosition()\
            event_offset_x = event_offset_x + (x-1)\
            event_offset_y = event_offset_y + (y-1)\
            local _,parent = debug.getupvalue(terminal.reposition,5)\
            if parent.reposition and parent ~= term.current() then\
                deepest = parent\
                get_ev_offset(parent)\
            elseif parent ~= nil then\
                deepest = parent\
            end\
        end\
        get_ev_offset(term_object)\
    end)\
    return deepest,event_offset_x,event_offset_y\
end\
\
return wUtil",
  [ "core/callbacks/mousepressed" ] = "local generic = require(\"common.generic\")\
local tbl = require(\"common.table_util\")\
\
local mouse_moved = require(\"core.callbacks.mousemoved\")\
\
local click_time_frame = 400\
local clicks = {}\
\
return {ev=\"mouse_click\",run=function(BUS,caller,ev,btn,x,y)\
    mouse_moved:check_change(BUS,caller,x,y)\
\
    local c_time = os.epoch(\"utc\")\
\
    clicks[generic.uuid4()] = {c_time,btn,x,y}\
    local registered = tbl.createNDarray(2)\
    for k,v in pairs(clicks) do\
        if c_time-v[1] < click_time_frame then\
            local loc = registered[v[3]][v[4]]\
            if loc[v[2]] then\
                loc[v[2]] = loc[v[2]] + 1\
                clicks[k] = {c_time,v[2],v[3],v[4]}\
            else loc[v[2]] = 1 end\
        end\
    end\
\
    BUS.events[#BUS.events+1] = {\"mousepressed\",x*2,y*3,btn,false,registered[x][y][btn]}\
    if type(caller.mousepressed) == \"function\" then\
        caller.mousepressed(x*2,y*3,btn,false,registered[x][y][btn])\
    end\
end}",
  [ "lib/luappm" ] = "local function read_characters(file,start,en)\
    local out = {}\
    for i=start,en do\
        file.seek(\"set\",i)\
        table.insert(out,file.read())\
    end\
    return string.char(table.unpack(out))\
end\
\
local function get_meta(file,on)\
    local sekt = on\
    local out = {}\
\
    for i=1,3 do\
        local full = {}\
        local data = \"\"\
        while not (data == 0x20 or data == 0x0A) do\
            file.seek(\"set\",sekt)\
            data = file.read()\
            table.insert(full,data)\
            sekt = sekt + 1\
        end\
        table.insert(out,tonumber(string.char(table.unpack(full))))\
    end\
    return out,sekt\
end\
\
local function get_image_data(file,on,meta)\
    local sekt = on\
    local out = {}\
    local pixels = 0\
    file.seek(\"set\",on)\
    while file.read() do pixels = pixels + 1 end\
    file.seek(\"set\",sekt)\
    for i=1,math.floor(pixels/3) do\
        local data = \"\"\
        for i=1,3 do\
            local running = 0\
            local full = {}\
            while data and running < 3 do\
                file.seek(\"set\",sekt)\
                data = file.read()\
                if data ~= nil then data = data/meta[3] end\
                table.insert(full,data)\
                sekt = sekt + 1\
                running = running + 1\
            end\
            if not next(full) then break end\
            table.insert(out,{r=full[1],g=full[2],b=full[3]})\
        end\
    end\
    return out,pixels/3\
end\
local function process_to_2d_array(list,width,tp)\
    local out = {}\
    for k,v in pairs(list) do\
        local x = math.floor((k-1)%width+1)\
        local y = math.ceil(k/width)\
        if not out[tp and x or y] then out[tp and x or y] = {} end\
        out[tp and x or y][tp and y or x] = v\
    end\
    return out\
end\
local function decode(_file)\
    local file = fs.open(_file,\"rb\")\
    if not file then error(\"File: \"..(_file or \"\")..\" doesnt exist\",3) end\
    if read_characters(file,0,2) == \"P6\\x0A\" then\
        local seek_offset = -math.huge\
        while true do\
            local data = file.read()\
            if string.char(data) == \"#\" then\
                while true do\
                    local cmt_part = file.read()\
                    if cmt_part == 0x0A then break end\
                    seek_offset = file.seek(\"cur\")+1\
                end\
            else\
                local meta,seek_offset = get_meta(file,seek_offset)\
                local _temp,pixels = get_image_data(file,seek_offset,meta)\
                local data = process_to_2d_array(_temp,meta[1],true)\
                local file_data = file.readAll()\
                file.close()\
\
                return {\
                    data=file_data,\
                    meta=meta,\
                    pixels=data,\
                    pixel_count=pixels,\
                    width=meta[1],\
                    height=meta[2],\
                    color_type=meta[3],\
                    get_pixel=function(x,y)\
                        local y_list = data[math.floor(x+0.5)]\
                        if y_list then\
                            return y_list[math.floor(y+0.5)]\
                        end\
                    end,\
                    get_palette=function()\
                        local cols = {}\
                        local palette_cols = 0\
                        local out = {}\
                        local final = {}\
                        for k,v in pairs(_temp) do\
                            local hex = colors.packRGB(v.r,v.g,v.b)\
                            if not cols[hex] then\
                                palette_cols = palette_cols + 1\
                                cols[hex] = {c=hex,count=0}\
                            end\
                            cols[hex].count = cols[hex].count + 1\
                        end\
                        for k,v in pairs(cols) do\
                            table.insert(out,v)\
                        end\
                        table.sort(out,function(a,b) return a.count > b.count end)\
                        for k,v in ipairs(out) do\
                            local r,g,b = colors.unpackRGB(v.c)\
                            table.insert(final,{r=r,g=g,b=b,c=v.count})\
                        end\
                        return final,palette_cols\
                    end\
                }\
            end\
        end\
    else\
        file.close()\
        error(\"File is unsupported format: \"..read_characters(file,0,1),2)\
    end\
end\
\
return decode",
  [ "modules/event" ] = "local event = {}\
\
return function(BUS)\
\
    local function grab_event_queue()\
        return table.remove(BUS.events,1)\
    end\
    local function add_event_queue(...)\
        BUS.events[#BUS.events+1] = table.pack(...)\
    end\
\
    function event.clear()\
        BUS.events = {}\
    end\
\
    function event.poll()\
        return coroutine.wrap(function()\
            for i=1,#BUS.events do\
                local ev = grab_event_queue()\
                coroutine.yield(table.unpack(ev,1,ev.n))\
            end\
        end)\
    end\
\
    function event.pump() end\
\
    function event.push(...)\
        add_event_queue(...)\
    end\
\
    function event.quit(exit_status)\
        add_event_queue(\"quit\",exit_status)\
    end\
\
    function event.wait()\
        while #BUS.events < 1 do\
            os.queueEvent(\"yield\")\
            os.pullEvent(\"yield\")\
        end\
        return grab_event_queue()\
    end\
\
    return event\
end",
  [ "core/graphics/quantize" ] = "local tbutil = require(\"common.table_util\")\
\
local MAX = math.max\
local MIN = math.min\
\
return {build=function(BUS)\
    local graphics = BUS.graphics\
\
    local function get_most_channel(max,min)\
        local diffs = {}\
        for i=1,3 do\
            diffs[i] = {val=max[i]-min[i],ind=i}\
        end\
        table.sort(diffs,function(a,b) return a.val > b.val end)\
        return diffs[1].ind\
    end\
\
    local function add_color(c1,c2)\
        return {\
            c1[1] + c2[1],\
            c1[2] + c2[2],\
            c1[3] + c2[3],\
        }\
    end\
\
    local function get_avg(total,count)\
        return {\
            total[1] / count,\
            total[2] / count,\
            total[3] / count\
        }\
    end\
\
    return {quantize=function()\
        local clrs = {}\
        local clut = tbutil.createNDarray(2)\
        for x,y in tbutil.map_iterator(graphics.w,graphics.h) do\
            local c = graphics.buffer[y][x]\
            if not clut[c[1]][c[2]][c[3]] then\
                clrs[#clrs+1] = graphics.buffer[y][x]\
                clut[c[1]][c[2]][c[3]] = true\
            end\
        end\
\
        local function median_cut(tbl,parts,splited)\
            if splited < 4 then\
                local max = {\
                    -math.huge,\
                    -math.huge,\
                    -math.huge,\
                }\
                local min = {\
                    math.huge,\
                    math.huge,\
                    math.huge\
                }\
                local diffirences = tbutil.createNDarray(1)\
                for k,v in pairs(tbl) do\
                    for i=1,3 do\
                        max[i] = MAX(max[i],v[i])\
                        min[i] = MIN(min[i],v[i])\
                        diffirences[k][i] = v[i]\
                    end\
                end\
                local mchan = get_most_channel(max,min)\
                table.sort(tbl,function(a,b)\
                    return a[mchan] > b[mchan]\
                end)\
\
                local split = {{},{}}\
\
                for i=1,#tbl do\
                    local index = math.ceil((i*2)/#tbl)\
                    local t = split[index]\
                    t[#t+1] = tbl[i]\
                end\
                median_cut(split[1],parts,splited+1)\
                median_cut(split[2],parts,splited+1)\
            else\
                local count = 0\
                local total = {0,0,0}\
                for k,v in pairs(tbl) do\
                    total = add_color(v,total)\
                    count = count + 1\
                end\
                parts[#parts+1] = get_avg(total,count)\
            end\
            return parts\
        end\
\
        if #clrs > 16 then\
            local cut = median_cut(clrs,{},0)\
            local res = BUS.cc.reserved_colors\
            for i=1,#res do\
                cut[#cut-i+1] = res[i]\
            end\
            return cut\
        else return clrs end\
    end}\
end}",
  [ "core/callbacks/mousereleased" ] = "local generic = require(\"common.generic\")\
local tbl = require(\"common.table_util\")\
\
local mouse_moved = require(\"core.callbacks.mousemoved\")\
\
local click_time_frame = 400\
local clicks = {}\
\
\
return {ev=\"mouse_up\",run=function(BUS,caller,ev,btn,x,y)\
    mouse_moved:check_change(BUS,caller,x,y)\
\
    local c_time = os.epoch(\"utc\")\
\
    clicks[generic.uuid4()] = {c_time,btn,x,y}\
    local registered = tbl.createNDarray(2)\
    for k,v in pairs(clicks) do\
        if c_time-v[1] < click_time_frame then\
            local loc = registered[v[3]][v[4]]\
            if loc[v[2]] then\
                loc[v[2]] = loc[v[2]] + 1\
                clicks[k] = {c_time,v[2],v[3],v[4]}\
            else loc[v[2]] = 1 end\
        end\
    end\
\
    BUS.events[#BUS.events+1] = {\"mousereleased\",x*2,y*3,btn,false,registered[x][y][btn]}\
    if type(caller.mousereleased) == \"function\" then\
        caller.mousereleased(x*2,y*3,btn,false,registered[x][y][btn])\
    end\
end}",
  [ "resources/font.bdf" ] = "STARTFONT 2.1\
COMMENT\
COMMENT  Copyright (c) 2022, Sammy L. Koch (sammykoch2004@gmail.com),\
COMMENT  with Reserved Font Name: \"Times9k\". Version 1.1.\
COMMENT  \
COMMENT  This Font Software is licensed under the SIL Open Font License, Version 1.1.\
FONT Times9k\
SIZE 7 72 72\
FONTBOUNDINGBOX 5 9 0 -2\
STARTPROPERTIES 11\
FOUNDRY \"Fine\"\
FAMILY_NAME \"Times9k\"\
WEIGHT_NAME \"Book\"\
SLANT \"R\"\
SETWIDTH_NAME \"Book\"\
SPACING \"c\"\
CHARSET_REGISTRY \"ISO-8859\"\
CHARSET_ENCODING \"1\"\
COPYRIGHT \"Copyright (c) 2022, Sammy L. Koch\"\
FONT_ASCENT  7\
FONT_DESCENT 2\
ENDPROPERTIES\
CHARS 256\
STARTCHAR C000\
ENCODING 0\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 0 0 0 0\
BITMAP\
ENDCHAR\
STARTCHAR C001\
ENCODING 1\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 5 1 0\
BITMAP\
a0\
a0\
00\
e0\
40\
ENDCHAR\
STARTCHAR C002\
ENCODING 2\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
f8\
f8\
a8\
a8\
f8\
88\
d8\
f8\
f8\
ENDCHAR\
STARTCHAR C003\
ENCODING 3\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 5 1 0\
BITMAP\
a0\
e0\
e0\
e0\
40\
ENDCHAR\
STARTCHAR C004\
ENCODING 4\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 1\
BITMAP\
60\
f0\
f0\
60\
ENDCHAR\
STARTCHAR C005\
ENCODING 5\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
60\
f0\
60\
f0\
f0\
60\
f0\
ENDCHAR\
STARTCHAR C006\
ENCODING 6\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 5 0 0\
BITMAP\
60\
f0\
f0\
60\
f0\
ENDCHAR\
STARTCHAR C007\
ENCODING 7\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 2 1 2\
BITMAP\
c0\
c0\
ENDCHAR\
STARTCHAR C010\
ENCODING 8\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
f8\
f8\
f8\
98\
98\
f8\
f8\
f8\
f8\
ENDCHAR\
STARTCHAR C011\
ENCODING 9\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 0 0 0 0\
BITMAP\
ENDCHAR\
STARTCHAR C012\
ENCODING 10\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 0 0 0 0\
BITMAP\
ENDCHAR\
STARTCHAR C013\
ENCODING 11\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
70\
30\
20\
60\
90\
60\
ENDCHAR\
STARTCHAR C014\
ENCODING 12\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
60\
20\
70\
20\
ENDCHAR\
STARTCHAR C015\
ENCODING 13\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 0 0 0 0\
BITMAP\
ENDCHAR\
STARTCHAR C016\
ENCODING 14\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
70\
50\
70\
40\
c0\
c0\
ENDCHAR\
STARTCHAR C017\
ENCODING 15\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
70\
50\
70\
50\
d0\
d0\
ENDCHAR\
STARTCHAR C020\
ENCODING 16\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
80\
c0\
e0\
f0\
e0\
c0\
80\
ENDCHAR\
STARTCHAR C021\
ENCODING 17\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
10\
30\
70\
f0\
70\
30\
10\
ENDCHAR\
STARTCHAR C022\
ENCODING 18\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 5 0 1\
BITMAP\
40\
e0\
40\
e0\
40\
ENDCHAR\
STARTCHAR C023\
ENCODING 19\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 1 0\
BITMAP\
a0\
a0\
a0\
a0\
00\
a0\
ENDCHAR\
STARTCHAR C024\
ENCODING 20\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 -1\
BITMAP\
f0\
d0\
d0\
d0\
50\
50\
50\
ENDCHAR\
STARTCHAR C025\
ENCODING 21\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
70\
c0\
a0\
50\
30\
e0\
ENDCHAR\
STARTCHAR C026\
ENCODING 22\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 2 0 0\
BITMAP\
f0\
f0\
ENDCHAR\
STARTCHAR C027\
ENCODING 23\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 1 0\
BITMAP\
40\
e0\
40\
e0\
40\
e0\
ENDCHAR\
STARTCHAR C030\
ENCODING 24\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 5 1 1\
BITMAP\
40\
e0\
40\
40\
40\
ENDCHAR\
STARTCHAR C031\
ENCODING 25\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 5 1 1\
BITMAP\
40\
40\
40\
e0\
40\
ENDCHAR\
STARTCHAR C032\
ENCODING 26\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 3 0 1\
BITMAP\
20\
f0\
20\
ENDCHAR\
STARTCHAR C033\
ENCODING 27\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 3 0 1\
BITMAP\
40\
f0\
40\
ENDCHAR\
STARTCHAR C034\
ENCODING 28\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 2 0 0\
BITMAP\
80\
f0\
ENDCHAR\
STARTCHAR C035\
ENCODING 29\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 3 0 1\
BITMAP\
50\
f0\
50\
ENDCHAR\
STARTCHAR C036\
ENCODING 30\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
60\
60\
f0\
f0\
f0\
ENDCHAR\
STARTCHAR C037\
ENCODING 31\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
f0\
f0\
f0\
60\
60\
60\
ENDCHAR\
STARTCHAR C040\
ENCODING 32\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 0 0 0 0\
BITMAP\
ENDCHAR\
STARTCHAR C041\
ENCODING 33\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 6 1 0\
BITMAP\
c0\
c0\
c0\
c0\
00\
c0\
ENDCHAR\
STARTCHAR C042\
ENCODING 34\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 3 0 3\
BITMAP\
50\
50\
a0\
ENDCHAR\
STARTCHAR C043\
ENCODING 35\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
50\
f0\
50\
50\
f0\
50\
ENDCHAR\
STARTCHAR C044\
ENCODING 36\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 8 0 -1\
BITMAP\
20\
70\
a0\
60\
20\
30\
e0\
20\
ENDCHAR\
STARTCHAR C045\
ENCODING 37\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 5 0 0\
BITMAP\
90\
30\
60\
c0\
90\
ENDCHAR\
STARTCHAR C046\
ENCODING 38\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
20\
50\
20\
60\
b0\
90\
60\
ENDCHAR\
STARTCHAR C047\
ENCODING 39\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 3 1 3\
BITMAP\
40\
40\
80\
ENDCHAR\
STARTCHAR C050\
ENCODING 40\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 6 2 0\
BITMAP\
40\
80\
80\
80\
80\
40\
ENDCHAR\
STARTCHAR C051\
ENCODING 41\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 6 0 0\
BITMAP\
80\
40\
40\
40\
40\
80\
ENDCHAR\
STARTCHAR C052\
ENCODING 42\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 3 1 3\
BITMAP\
a0\
40\
a0\
ENDCHAR\
STARTCHAR C053\
ENCODING 43\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 3 1 2\
BITMAP\
40\
e0\
40\
ENDCHAR\
STARTCHAR C054\
ENCODING 44\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 3 1 -1\
BITMAP\
c0\
c0\
80\
ENDCHAR\
STARTCHAR C055\
ENCODING 45\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 1 1 3\
BITMAP\
e0\
ENDCHAR\
STARTCHAR C056\
ENCODING 46\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 2 1 0\
BITMAP\
c0\
c0\
ENDCHAR\
STARTCHAR C057\
ENCODING 47\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
10\
10\
20\
40\
80\
80\
ENDCHAR\
STARTCHAR C060\
ENCODING 48\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
b0\
d0\
90\
60\
ENDCHAR\
STARTCHAR C061\
ENCODING 49\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 1 0\
BITMAP\
40\
c0\
40\
40\
40\
e0\
ENDCHAR\
STARTCHAR C062\
ENCODING 50\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
20\
40\
80\
f0\
ENDCHAR\
STARTCHAR C063\
ENCODING 51\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
20\
10\
90\
60\
ENDCHAR\
STARTCHAR C064\
ENCODING 52\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
60\
a0\
a0\
f0\
20\
ENDCHAR\
STARTCHAR C065\
ENCODING 53\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
f0\
80\
e0\
10\
90\
60\
ENDCHAR\
STARTCHAR C066\
ENCODING 54\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
80\
e0\
90\
90\
60\
ENDCHAR\
STARTCHAR C067\
ENCODING 55\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
f0\
10\
20\
40\
40\
40\
ENDCHAR\
STARTCHAR C070\
ENCODING 56\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
60\
90\
90\
60\
ENDCHAR\
STARTCHAR C071\
ENCODING 57\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
90\
70\
10\
60\
ENDCHAR\
STARTCHAR C072\
ENCODING 58\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 5 1 0\
BITMAP\
c0\
c0\
00\
c0\
c0\
ENDCHAR\
STARTCHAR C073\
ENCODING 59\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 5 0 -1\
BITMAP\
60\
00\
60\
60\
c0\
ENDCHAR\
STARTCHAR C074\
ENCODING 60\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 5 0 0\
BITMAP\
30\
60\
c0\
60\
30\
ENDCHAR\
STARTCHAR C075\
ENCODING 61\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 3 0 1\
BITMAP\
f0\
00\
f0\
ENDCHAR\
STARTCHAR C076\
ENCODING 62\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 5 0 0\
BITMAP\
c0\
60\
30\
60\
c0\
ENDCHAR\
STARTCHAR C077\
ENCODING 63\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
10\
60\
00\
40\
ENDCHAR\
STARTCHAR C100\
ENCODING 64\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
b0\
b0\
80\
60\
ENDCHAR\
STARTCHAR C101\
ENCODING 65\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
f0\
90\
90\
90\
ENDCHAR\
STARTCHAR C102\
ENCODING 66\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
e0\
90\
e0\
90\
90\
e0\
ENDCHAR\
STARTCHAR C103\
ENCODING 67\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
80\
80\
90\
60\
ENDCHAR\
STARTCHAR C104\
ENCODING 68\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
e0\
90\
90\
90\
90\
e0\
ENDCHAR\
STARTCHAR C105\
ENCODING 69\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
f0\
80\
e0\
80\
80\
f0\
ENDCHAR\
STARTCHAR C106\
ENCODING 70\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
f0\
80\
e0\
80\
80\
80\
ENDCHAR\
STARTCHAR C107\
ENCODING 71\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
70\
80\
b0\
90\
90\
60\
ENDCHAR\
STARTCHAR C110\
ENCODING 72\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
90\
90\
f0\
90\
90\
90\
ENDCHAR\
STARTCHAR C111\
ENCODING 73\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 1 0\
BITMAP\
e0\
40\
40\
40\
40\
e0\
ENDCHAR\
STARTCHAR C112\
ENCODING 74\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
30\
10\
10\
10\
90\
60\
ENDCHAR\
STARTCHAR C113\
ENCODING 75\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
90\
90\
e0\
90\
90\
90\
ENDCHAR\
STARTCHAR C114\
ENCODING 76\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
80\
80\
80\
80\
80\
f0\
ENDCHAR\
STARTCHAR C115\
ENCODING 77\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
90\
f0\
f0\
90\
90\
90\
ENDCHAR\
STARTCHAR C116\
ENCODING 78\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
90\
d0\
f0\
f0\
b0\
90\
ENDCHAR\
STARTCHAR C117\
ENCODING 79\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C120\
ENCODING 80\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
e0\
90\
e0\
80\
80\
80\
ENDCHAR\
STARTCHAR C121\
ENCODING 81\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 -1\
BITMAP\
60\
90\
90\
90\
b0\
60\
10\
ENDCHAR\
STARTCHAR C122\
ENCODING 82\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
e0\
90\
e0\
90\
90\
90\
ENDCHAR\
STARTCHAR C123\
ENCODING 83\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
40\
20\
90\
60\
ENDCHAR\
STARTCHAR C124\
ENCODING 84\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 1 0\
BITMAP\
e0\
40\
40\
40\
40\
40\
ENDCHAR\
STARTCHAR C125\
ENCODING 85\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
90\
90\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C126\
ENCODING 86\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
90\
90\
90\
f0\
60\
60\
ENDCHAR\
STARTCHAR C127\
ENCODING 87\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
90\
90\
90\
f0\
f0\
90\
ENDCHAR\
STARTCHAR C130\
ENCODING 88\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
90\
90\
60\
60\
90\
90\
ENDCHAR\
STARTCHAR C131\
ENCODING 89\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
90\
90\
70\
10\
90\
60\
ENDCHAR\
STARTCHAR C132\
ENCODING 90\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
f0\
10\
20\
40\
80\
f0\
ENDCHAR\
STARTCHAR C133\
ENCODING 91\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 6 2 0\
BITMAP\
c0\
80\
80\
80\
80\
c0\
ENDCHAR\
STARTCHAR C134\
ENCODING 92\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
80\
80\
40\
20\
10\
10\
ENDCHAR\
STARTCHAR C135\
ENCODING 93\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 6 0 0\
BITMAP\
c0\
40\
40\
40\
40\
c0\
ENDCHAR\
STARTCHAR C136\
ENCODING 94\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 2 1 4\
BITMAP\
40\
a0\
ENDCHAR\
STARTCHAR C137\
ENCODING 95\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 1 0 -1\
BITMAP\
f0\
ENDCHAR\
STARTCHAR C140\
ENCODING 96\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 3 1 3\
BITMAP\
80\
80\
40\
ENDCHAR\
STARTCHAR C141\
ENCODING 97\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
60\
10\
f0\
70\
ENDCHAR\
STARTCHAR C142\
ENCODING 98\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
80\
80\
e0\
90\
90\
e0\
ENDCHAR\
STARTCHAR C143\
ENCODING 99\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 4 0 0\
BITMAP\
60\
80\
80\
60\
ENDCHAR\
STARTCHAR C144\
ENCODING 100\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
10\
10\
70\
90\
90\
70\
ENDCHAR\
STARTCHAR C145\
ENCODING 101\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
60\
f0\
80\
60\
ENDCHAR\
STARTCHAR C146\
ENCODING 102\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
30\
40\
e0\
40\
40\
40\
ENDCHAR\
STARTCHAR C147\
ENCODING 103\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 -2\
BITMAP\
60\
90\
90\
70\
10\
e0\
ENDCHAR\
STARTCHAR C150\
ENCODING 104\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
80\
80\
e0\
90\
90\
90\
ENDCHAR\
STARTCHAR C151\
ENCODING 105\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 1 0\
BITMAP\
40\
00\
c0\
40\
40\
e0\
ENDCHAR\
STARTCHAR C152\
ENCODING 106\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 0 0\
BITMAP\
20\
00\
60\
20\
a0\
40\
ENDCHAR\
STARTCHAR C153\
ENCODING 107\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
80\
80\
90\
e0\
a0\
90\
ENDCHAR\
STARTCHAR C154\
ENCODING 108\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 1 0\
BITMAP\
80\
80\
80\
80\
a0\
40\
ENDCHAR\
STARTCHAR C155\
ENCODING 109\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
60\
f0\
f0\
90\
ENDCHAR\
STARTCHAR C156\
ENCODING 110\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
60\
90\
90\
90\
ENDCHAR\
STARTCHAR C157\
ENCODING 111\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
60\
90\
90\
60\
ENDCHAR\
STARTCHAR C160\
ENCODING 112\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 -2\
BITMAP\
60\
90\
90\
e0\
80\
80\
ENDCHAR\
STARTCHAR C161\
ENCODING 113\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 -2\
BITMAP\
60\
90\
90\
70\
10\
10\
ENDCHAR\
STARTCHAR C162\
ENCODING 114\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
b0\
c0\
80\
80\
ENDCHAR\
STARTCHAR C163\
ENCODING 115\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
70\
c0\
30\
e0\
ENDCHAR\
STARTCHAR C164\
ENCODING 116\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 1 0\
BITMAP\
40\
40\
e0\
40\
40\
20\
ENDCHAR\
STARTCHAR C165\
ENCODING 117\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C166\
ENCODING 118\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
90\
90\
60\
60\
ENDCHAR\
STARTCHAR C167\
ENCODING 119\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
90\
90\
f0\
f0\
ENDCHAR\
STARTCHAR C170\
ENCODING 120\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
90\
60\
60\
90\
ENDCHAR\
STARTCHAR C171\
ENCODING 121\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 -2\
BITMAP\
90\
90\
90\
70\
10\
e0\
ENDCHAR\
STARTCHAR C172\
ENCODING 122\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
f0\
30\
c0\
f0\
ENDCHAR\
STARTCHAR C173\
ENCODING 123\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 7 1 0\
BITMAP\
20\
40\
40\
80\
40\
40\
20\
ENDCHAR\
STARTCHAR C174\
ENCODING 124\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 1 7 2 0\
BITMAP\
80\
80\
80\
00\
80\
80\
80\
ENDCHAR\
STARTCHAR C175\
ENCODING 125\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 7 1 0\
BITMAP\
80\
40\
40\
20\
40\
40\
80\
ENDCHAR\
STARTCHAR C176\
ENCODING 126\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 2 0 3\
BITMAP\
50\
a0\
ENDCHAR\
STARTCHAR C177\
ENCODING 127\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
60\
88\
10\
60\
88\
10\
60\
88\
10\
ENDCHAR\
STARTCHAR C200\
ENCODING 128\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 0 0 0 0\
BITMAP\
ENDCHAR\
STARTCHAR C201\
ENCODING 129\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 3 0 4\
BITMAP\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C202\
ENCODING 130\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 3 2 4\
BITMAP\
e0\
e0\
e0\
ENDCHAR\
STARTCHAR C203\
ENCODING 131\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 3 0 4\
BITMAP\
f8\
f8\
f8\
ENDCHAR\
STARTCHAR C204\
ENCODING 132\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 3 0 1\
BITMAP\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C205\
ENCODING 133\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 6 0 1\
BITMAP\
c0\
c0\
c0\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C206\
ENCODING 134\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 6 0 1\
BITMAP\
38\
38\
38\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C207\
ENCODING 135\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 6 0 1\
BITMAP\
f8\
f8\
f8\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C210\
ENCODING 136\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 3 2 1\
BITMAP\
e0\
e0\
e0\
ENDCHAR\
STARTCHAR C211\
ENCODING 137\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 6 0 1\
BITMAP\
c0\
c0\
c0\
38\
38\
38\
ENDCHAR\
STARTCHAR C212\
ENCODING 138\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 2 1\
BITMAP\
e0\
e0\
e0\
e0\
e0\
e0\
ENDCHAR\
STARTCHAR C213\
ENCODING 139\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 6 0 1\
BITMAP\
f8\
f8\
f8\
38\
38\
38\
ENDCHAR\
STARTCHAR C214\
ENCODING 140\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 3 0 1\
BITMAP\
f8\
f8\
f8\
ENDCHAR\
STARTCHAR C215\
ENCODING 141\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 6 0 1\
BITMAP\
c0\
c0\
c0\
f8\
f8\
f8\
ENDCHAR\
STARTCHAR C216\
ENCODING 142\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 6 0 1\
BITMAP\
38\
38\
38\
f8\
f8\
f8\
ENDCHAR\
STARTCHAR C217\
ENCODING 143\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 6 0 1\
BITMAP\
f8\
f8\
f8\
f8\
f8\
f8\
ENDCHAR\
STARTCHAR C220\
ENCODING 144\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 3 0 -2\
BITMAP\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C221\
ENCODING 145\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 9 0 -2\
BITMAP\
c0\
c0\
c0\
00\
00\
00\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C222\
ENCODING 146\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
38\
38\
38\
00\
00\
00\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C223\
ENCODING 147\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
f8\
f8\
f8\
00\
00\
00\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C224\
ENCODING 148\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 6 0 -2\
BITMAP\
c0\
c0\
c0\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C225\
ENCODING 149\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 9 0 -2\
BITMAP\
c0\
c0\
c0\
c0\
c0\
c0\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C226\
ENCODING 150\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
38\
38\
38\
c0\
c0\
c0\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C227\
ENCODING 151\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
f8\
f8\
f8\
c0\
c0\
c0\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C230\
ENCODING 152\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 6 0 -2\
BITMAP\
38\
38\
38\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C231\
ENCODING 153\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
c0\
c0\
c0\
38\
38\
38\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C232\
ENCODING 154\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
38\
38\
38\
38\
38\
38\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C233\
ENCODING 155\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
f8\
f8\
f8\
38\
38\
38\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C234\
ENCODING 156\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 6 0 -2\
BITMAP\
f8\
f8\
f8\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C235\
ENCODING 157\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
c0\
c0\
c0\
f8\
f8\
f8\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C236\
ENCODING 158\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
38\
38\
38\
f8\
f8\
f8\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C237\
ENCODING 159\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 5 9 0 -2\
BITMAP\
f8\
f8\
f8\
f8\
f8\
f8\
c0\
c0\
c0\
ENDCHAR\
STARTCHAR C240\
ENCODING 160\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 0 0 0 0\
BITMAP\
ENDCHAR\
STARTCHAR C241\
ENCODING 161\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 1 0\
BITMAP\
40\
00\
c0\
40\
40\
e0\
ENDCHAR\
STARTCHAR C242\
ENCODING 162\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
20\
70\
80\
80\
70\
20\
ENDCHAR\
STARTCHAR C243\
ENCODING 163\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
20\
50\
40\
e0\
40\
f0\
ENDCHAR\
STARTCHAR C244\
ENCODING 164\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 9 0 -2\
BITMAP\
90\
90\
60\
90\
90\
60\
90\
90\
60\
ENDCHAR\
STARTCHAR C245\
ENCODING 165\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 7 1 0\
BITMAP\
a0\
a0\
40\
e0\
40\
e0\
40\
ENDCHAR\
STARTCHAR C246\
ENCODING 166\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 1 5 1 0\
BITMAP\
80\
80\
00\
80\
80\
ENDCHAR\
STARTCHAR C247\
ENCODING 167\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
70\
c0\
a0\
50\
30\
e0\
ENDCHAR\
STARTCHAR C250\
ENCODING 168\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 1 0 5\
BITMAP\
a0\
ENDCHAR\
STARTCHAR C251\
ENCODING 169\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 5 0 0\
BITMAP\
60\
d0\
b0\
d0\
60\
ENDCHAR\
STARTCHAR C252\
ENCODING 170\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 1\
BITMAP\
60\
10\
70\
90\
90\
70\
ENDCHAR\
STARTCHAR C253\
ENCODING 171\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 3 0 1\
BITMAP\
50\
a0\
50\
ENDCHAR\
STARTCHAR C254\
ENCODING 172\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 2 0 1\
BITMAP\
f0\
10\
ENDCHAR\
STARTCHAR C255\
ENCODING 173\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 1 0 2\
BITMAP\
f0\
ENDCHAR\
STARTCHAR C256\
ENCODING 174\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 5 0 0\
BITMAP\
60\
d0\
b0\
b0\
60\
ENDCHAR\
STARTCHAR C257\
ENCODING 175\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 1 0 5\
BITMAP\
f0\
ENDCHAR\
STARTCHAR C260\
ENCODING 176\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 3 1 3\
BITMAP\
40\
a0\
40\
ENDCHAR\
STARTCHAR C261\
ENCODING 177\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 5 1 0\
BITMAP\
40\
e0\
40\
00\
e0\
ENDCHAR\
STARTCHAR C262\
ENCODING 178\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 4 1 3\
BITMAP\
80\
40\
80\
c0\
ENDCHAR\
STARTCHAR C263\
ENCODING 179\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 5 1 2\
BITMAP\
80\
40\
80\
40\
80\
ENDCHAR\
STARTCHAR C264\
ENCODING 180\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 3 1 3\
BITMAP\
40\
80\
80\
ENDCHAR\
STARTCHAR C265\
ENCODING 181\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 -2\
BITMAP\
90\
90\
90\
e0\
80\
80\
ENDCHAR\
STARTCHAR C266\
ENCODING 182\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 -1\
BITMAP\
f0\
d0\
d0\
d0\
50\
50\
50\
ENDCHAR\
STARTCHAR C267\
ENCODING 183\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 2 1 2\
BITMAP\
c0\
c0\
ENDCHAR\
STARTCHAR C270\
ENCODING 184\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 3 1 -1\
BITMAP\
c0\
40\
80\
ENDCHAR\
STARTCHAR C271\
ENCODING 185\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 2 4 1 3\
BITMAP\
40\
c0\
40\
40\
ENDCHAR\
STARTCHAR C272\
ENCODING 186\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 1\
BITMAP\
60\
90\
90\
60\
ENDCHAR\
STARTCHAR C273\
ENCODING 187\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 3 0 1\
BITMAP\
a0\
50\
a0\
ENDCHAR\
STARTCHAR C274\
ENCODING 188\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 5 0 0\
BITMAP\
90\
30\
60\
c0\
90\
ENDCHAR\
STARTCHAR C275\
ENCODING 189\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 5 0 0\
BITMAP\
90\
30\
60\
c0\
90\
ENDCHAR\
STARTCHAR C276\
ENCODING 190\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 5 0 0\
BITMAP\
90\
30\
60\
c0\
90\
ENDCHAR\
STARTCHAR C277\
ENCODING 191\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
40\
00\
60\
10\
90\
60\
ENDCHAR\
STARTCHAR C300\
ENCODING 192\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
c0\
00\
60\
90\
f0\
90\
90\
ENDCHAR\
STARTCHAR C301\
ENCODING 193\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
30\
00\
60\
90\
f0\
90\
90\
ENDCHAR\
STARTCHAR C302\
ENCODING 194\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
60\
90\
60\
90\
f0\
90\
90\
ENDCHAR\
STARTCHAR C303\
ENCODING 195\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
50\
a0\
60\
90\
f0\
90\
90\
ENDCHAR\
STARTCHAR C304\
ENCODING 196\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
90\
00\
60\
90\
f0\
90\
90\
ENDCHAR\
STARTCHAR C305\
ENCODING 197\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
60\
00\
60\
90\
f0\
90\
90\
ENDCHAR\
STARTCHAR C306\
ENCODING 198\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
70\
a0\
f0\
a0\
a0\
b0\
ENDCHAR\
STARTCHAR C307\
ENCODING 199\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 8 0 -2\
BITMAP\
60\
90\
80\
80\
90\
60\
20\
40\
ENDCHAR\
STARTCHAR C310\
ENCODING 200\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
c0\
00\
f0\
80\
e0\
80\
f0\
ENDCHAR\
STARTCHAR C311\
ENCODING 201\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
30\
00\
f0\
80\
e0\
80\
f0\
ENDCHAR\
STARTCHAR C312\
ENCODING 202\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
50\
a0\
f0\
80\
e0\
80\
f0\
ENDCHAR\
STARTCHAR C313\
ENCODING 203\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
90\
00\
f0\
80\
e0\
80\
f0\
ENDCHAR\
STARTCHAR C314\
ENCODING 204\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 7 1 0\
BITMAP\
80\
40\
00\
e0\
40\
40\
e0\
ENDCHAR\
STARTCHAR C315\
ENCODING 205\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 7 1 0\
BITMAP\
20\
40\
00\
e0\
40\
40\
e0\
ENDCHAR\
STARTCHAR C316\
ENCODING 206\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 7 1 0\
BITMAP\
40\
a0\
00\
e0\
40\
40\
e0\
ENDCHAR\
STARTCHAR C317\
ENCODING 207\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 1 0\
BITMAP\
a0\
00\
e0\
40\
40\
e0\
ENDCHAR\
STARTCHAR C320\
ENCODING 208\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
e0\
90\
d0\
90\
90\
e0\
ENDCHAR\
STARTCHAR C321\
ENCODING 209\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
50\
a0\
90\
d0\
f0\
b0\
90\
ENDCHAR\
STARTCHAR C322\
ENCODING 210\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
40\
20\
60\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C323\
ENCODING 211\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
20\
40\
60\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C324\
ENCODING 212\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
60\
90\
60\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C325\
ENCODING 213\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
50\
a0\
60\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C326\
ENCODING 214\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
90\
00\
60\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C327\
ENCODING 215\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 1\
BITMAP\
90\
60\
60\
90\
ENDCHAR\
STARTCHAR C330\
ENCODING 216\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
60\
90\
a0\
50\
90\
60\
ENDCHAR\
STARTCHAR C331\
ENCODING 217\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
80\
40\
90\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C332\
ENCODING 218\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
10\
20\
90\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C333\
ENCODING 219\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
60\
00\
90\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C334\
ENCODING 220\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
90\
00\
90\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C335\
ENCODING 221\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
10\
20\
90\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C336\
ENCODING 222\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
80\
e0\
90\
e0\
80\
80\
ENDCHAR\
STARTCHAR C337\
ENCODING 223\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 -1\
BITMAP\
60\
90\
a0\
90\
90\
a0\
80\
ENDCHAR\
STARTCHAR C340\
ENCODING 224\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
40\
20\
00\
60\
10\
f0\
70\
ENDCHAR\
STARTCHAR C341\
ENCODING 225\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
20\
40\
00\
60\
10\
f0\
70\
ENDCHAR\
STARTCHAR C342\
ENCODING 226\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
20\
50\
00\
60\
10\
f0\
70\
ENDCHAR\
STARTCHAR C343\
ENCODING 227\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
50\
a0\
00\
60\
10\
f0\
70\
ENDCHAR\
STARTCHAR C344\
ENCODING 228\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
50\
00\
60\
10\
f0\
70\
ENDCHAR\
STARTCHAR C345\
ENCODING 229\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
20\
50\
20\
60\
10\
f0\
70\
ENDCHAR\
STARTCHAR C346\
ENCODING 230\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
70\
b0\
a0\
70\
ENDCHAR\
STARTCHAR C347\
ENCODING 231\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 0 -2\
BITMAP\
60\
80\
80\
60\
40\
80\
ENDCHAR\
STARTCHAR C350\
ENCODING 232\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
40\
20\
00\
60\
f0\
80\
60\
ENDCHAR\
STARTCHAR C351\
ENCODING 233\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
20\
40\
00\
60\
f0\
80\
60\
ENDCHAR\
STARTCHAR C352\
ENCODING 234\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
20\
50\
00\
60\
f0\
80\
60\
ENDCHAR\
STARTCHAR C353\
ENCODING 235\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
50\
00\
60\
f0\
80\
60\
ENDCHAR\
STARTCHAR C354\
ENCODING 236\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 7 1 0\
BITMAP\
80\
40\
00\
c0\
40\
40\
e0\
ENDCHAR\
STARTCHAR C355\
ENCODING 237\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 7 1 0\
BITMAP\
20\
40\
00\
c0\
40\
40\
e0\
ENDCHAR\
STARTCHAR C356\
ENCODING 238\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 7 1 0\
BITMAP\
40\
a0\
00\
c0\
40\
40\
e0\
ENDCHAR\
STARTCHAR C357\
ENCODING 239\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 3 6 1 0\
BITMAP\
a0\
00\
c0\
40\
40\
e0\
ENDCHAR\
STARTCHAR C360\
ENCODING 240\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
40\
20\
10\
70\
90\
90\
60\
ENDCHAR\
STARTCHAR C361\
ENCODING 241\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
50\
a0\
00\
60\
90\
90\
90\
ENDCHAR\
STARTCHAR C362\
ENCODING 242\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
40\
20\
00\
60\
90\
90\
60\
ENDCHAR\
STARTCHAR C363\
ENCODING 243\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
20\
40\
00\
60\
90\
90\
60\
ENDCHAR\
STARTCHAR C364\
ENCODING 244\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
60\
90\
00\
60\
90\
90\
60\
ENDCHAR\
STARTCHAR C365\
ENCODING 245\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
50\
a0\
00\
60\
90\
90\
60\
ENDCHAR\
STARTCHAR C366\
ENCODING 246\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
90\
00\
60\
90\
90\
60\
ENDCHAR\
STARTCHAR C367\
ENCODING 247\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 5 0 1\
BITMAP\
40\
00\
f0\
00\
20\
ENDCHAR\
STARTCHAR C370\
ENCODING 248\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 4 0 0\
BITMAP\
60\
b0\
d0\
60\
ENDCHAR\
STARTCHAR C371\
ENCODING 249\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
40\
20\
00\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C372\
ENCODING 250\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
20\
40\
00\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C373\
ENCODING 251\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 7 0 0\
BITMAP\
60\
90\
00\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C374\
ENCODING 252\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
90\
00\
90\
90\
90\
60\
ENDCHAR\
STARTCHAR C375\
ENCODING 253\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 9 0 -2\
BITMAP\
20\
40\
00\
90\
90\
90\
70\
10\
e0\
ENDCHAR\
STARTCHAR C376\
ENCODING 254\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 6 0 0\
BITMAP\
80\
e0\
90\
90\
e0\
80\
ENDCHAR\
STARTCHAR C377\
ENCODING 255\
SWIDTH 714 0\
DWIDTH 5 0\
BBX 4 8 0 -2\
BITMAP\
90\
00\
90\
90\
90\
70\
10\
e0\
ENDCHAR\
ENDFONT\
",
  [ "lib/matrix" ] = "local matrice = {}\
\
local function matrix_multiply(a, b)\
    local m = {}\
    m.matrix_height = a.matrix_height\
    m.matrix_width = b.matrix_width\
    for y=0,a.matrix_height-1 do\
        for x=0,b.matrix_width-1 do\
            local sum = 0\
            for i=0,a.matrix_width-1 do\
                sum = sum + a[y*a.matrix_width+i+1]*b[i*b.matrix_width+x+1]\
            end\
            m[y*b.matrix_width+x+1] = sum\
        end\
    end\
    return m\
end\
\
local function attacher(self,matrice)\
    return setmetatable(matrix_multiply(self,matrice),{\
        __mul=attacher,\
    })\
end\
\
function matrice.new(N, M, ...)\
    local m = { ... }\
    m.matrix_width = N\
    m.matrix_height = M\
    return setmetatable(m,{__mul = attacher})\
end\
\
function matrice.vector(...)\
    local m = { ... }\
    return matrice.new(#m, 1, ...)\
end\
\
return matrice",
  [ "common/color_util" ] = "local tbls = require(\"common.table_util\")\
\
local cUtil = {blend={\
    alpha={},\
    add={},\
    subtract={},\
    replace={},\
    multiply={},\
    lighten={},\
    darken={},\
    screen={}\
}}\
\
local palette = {}\
local color_cache = tbls.createNDarray(2)\
\
local SQRT,MAX,MIN = math.sqrt,math.max,math.min\
\
function cUtil.update_palette(terminal)\
    color_cache = tbls.createNDarray(2)\
    for i=0,15 do\
        local r,g,b = terminal.getPaletteColor(2^i)\
        palette[2^i] = {r,g,b}\
    end\
end\
\
function cUtil.set_palette(BUS,pal)\
    color_cache = tbls.createNDarray(2)\
    for index,v in ipairs(pal) do\
        local i = 2^(index-1)\
        palette[i] = {v[1],v[2],v[3]}\
        for k,v in pairs(BUS.cc.reserved_spots) do\
            if v[1] == i then\
                palette[i] = v[2]\
            end\
        end\
    end\
    return {push=function(to)\
        for k,v in pairs(palette) do\
            to.setPaletteColor(k,v[1],v[2],v[3])\
        end\
    end}\
end\
\
function cUtil.find_closest_color(r,g,b)\
    local n,result = 0,color_cache[r][g][b] or {}\
    if not next(result) then\
        for k,v in pairs(palette) do\
            n=n+1\
            result[n] = {\
                dist=SQRT(\
                    (v[1]-r)^2 +\
                    (v[2]-g)^2 +\
                    (v[3]-b)^2\
                ),  color=k\
            }\
        end\
        table.sort(result,function(a,b) return a.dist < b.dist end)\
        color_cache[r][g][b] = result\
    end\
    return result[1].color,result\
end\
\
function cUtil.get_palette()\
    return palette\
end\
\
function cUtil.blend.alpha.alphamultiply(dst,src)\
    return {\
        dst[1] * (1 - src[4]) + src[1] * src[4],\
        dst[2] * (1 - src[4]) + src[2] * src[4],\
        dst[3] * (1 - src[4]) + src[3] * src[4],\
        dst[4] * (1 - src[4]) + src[4]\
    }\
end\
\
function cUtil.blend.alpha.premultiplied(dst,src)\
    return {\
        dst[1] * (1 - src[4]) + src[1],\
        dst[2] * (1 - src[4]) + src[2],\
        dst[3] * (1 - src[4]) + src[3],\
        dst[4] * (1 - src[4]) + src[4]\
\
    }\
end\
\
function cUtil.blend.add.alphamultiply(dst,src)\
    return {\
        dst[1] + (src[1] * src[4]),\
        dst[2] + (src[2] * src[4]),\
        dst[3] + (src[3] * src[4]),\
        dst[4]\
    }\
end\
\
function cUtil.blend.add.premultiplied(dst,src)\
    return {\
        dst[1] + src[1],\
        dst[2] + src[2],\
        dst[3] + src[3],\
        dst[4]\
    }\
end\
\
function cUtil.blend.subtract.alphamultiply(dst,src)\
    return {\
        dst[1] - (src[1] * src[4]),\
        dst[2] - (src[2] * src[4]),\
        dst[3] - (src[3] * src[4]),\
        dst[4]\
    }\
end\
\
function cUtil.blend.subtract.premultiplied(dst,src)\
    return {\
        dst[1] - src[1],\
        dst[2] - src[2],\
        dst[3] - src[3],\
        dst[4]\
    }\
end\
\
function cUtil.blend.replace.alphamultiply(dst,src)\
    return {\
        src[1] * src[4],\
        src[2] * src[4],\
        src[3] * src[4]\
    }\
end\
\
function cUtil.blend.replace.premultiplied(dst,src)\
    return {src[1],src[2],src[3]}\
end\
\
function cUtil.blend.multiply.alphamultiply(dst,src)\
    return {\
        src[1]*dst[1],\
        src[2]*dst[2],\
        src[3]*dst[3],\
        src[4]*dst[4]\
    }\
end\
\
function cUtil.blend.lighten.alphamultiply(dst,src)\
    return {\
        MAX(src[1],dst[1]),\
        MAX(src[2],dst[2]),\
        MAX(src[3],dst[3]),\
        MAX(src[4],dst[4])\
    }\
end\
\
function cUtil.blend.darken.alphamultiply(dst,src)\
    return {\
        MIN(src[1],dst[1]),\
        MIN(src[2],dst[2]),\
        MIN(src[3],dst[3]),\
        MIN(src[4],dst[4])\
    }\
end\
\
function cUtil.blend.screen.alphamultiply(dst,src)\
    return {\
        dst[1] * (1 - src[1]) + (src[1] * src[4]),\
        dst[2] * (1 - src[2]) + (src[2] * src[4]),\
        dst[3] * (1 - src[3]) + (src[3] * src[4]),\
        dst[4] * (1 - src[4]) + src[4]\
    }\
end\
\
function cUtil.blend.screen.premultiplied(dst,src)\
    return {\
        dst[1] * (1 - src[1]) + src[1],\
        dst[2] * (1 - src[2]) + src[2],\
        dst[3] * (1 - src[3]) + src[3],\
        dst[4] * (1 - src[4]) + src[4]\
    }\
end\
\
cUtil.blend.multiply.premultiplied = cUtil.blend.multiply.alphamultiply\
cUtil.blend.lighten.premultiplied = cUtil.blend.lighten.alphamultiply\
cUtil.blend.darken.premultiplied = cUtil.blend.darken.alphamultiply\
\
return cUtil",
  [ "core/graphics/shape" ] = "local shapes = {}\
local CEIL = math.ceil\
local FLOOR = math.floor\
local ABS = math.abs\
local MIN = math.min\
\
local function draw_flat_top_triangle(v0,v1,v2,caller)\
    local v0x,v0y = v0.x,v0.y\
    local v1x,v1y = v1.x,v1.y\
    local v2x,v2y = v2.x,v2.y\
    local m0 = (v2x - v0x) / (v2y - v0y)\
    local m1 = (v2x - v1x) / (v2y - v1y)\
    local y_start = CEIL(v0y - 0.5)\
    local y_end   = CEIL(v2y - 0.5) - 1\
    for y=y_start,y_end do \
        local px0 = m0 * (y + 0.5 - v0y) + v0x\
        local px1 = m1 * (y + 0.5 - v1y) + v1x\
        local x_start = CEIL(px0 - 0.5)\
        local x_end   = CEIL(px1 - 0.5)\
        for x=x_start,x_end do\
            caller(x,y)\
        end\
    end\
end\
\
local function draw_flat_bottom_triangle(v0,v1,v2,caller)\
    local v0x,v0y = v0.x,v0.y\
    local v1x,v1y = v1.x,v1.y\
    local v2x,v2y = v2.x,v2.y\
    local m0 = (v1x - v0x) / (v1y - v0y)\
    local m1 = (v2x - v0x) / (v2y - v0y)\
    local y_start = CEIL(v0y - 0.5)\
    local y_end   = CEIL(v2y - 0.5) - 1\
    for y=y_start,y_end do \
        local px0 = m0 * (y + 0.5 - v0y) + v0x\
        local px1 = m1 * (y + 0.5 - v0y) + v0x\
        local x_start = CEIL(px0 - 0.5)\
        local x_end   = CEIL(px1 - 0.5)\
        for x=x_start,x_end do\
            caller(x,y)\
        end\
    end\
end\
\
function shapes.get_triangle_points(vector0,vector1,vector2,caller)\
    if vector1.y < vector0.y then vector0,vector1 = vector1,vector0 end\
    if vector2.y < vector1.y then vector1,vector2 = vector2,vector1 end\
    if vector1.y < vector0.y then vector0,vector1 = vector1,vector0 end\
    if vector0.y == vector1.y then\
        if vector1.x < vector0.x then vector0,vector1 = vector1,vector0 end\
        draw_flat_top_triangle(vector0,vector1,vector2,caller)\
    elseif vector1.y == vector2.y then\
        if vector2.x < vector1.x then vector1,vector2 = vector2,vector1 end\
        draw_flat_bottom_triangle(vector0,vector1,vector2,caller)\
    else\
        local alpha_split = (vector1.y-vector0.y) / (vector2.y-vector0.y)\
        local split_vertex = { \
            x = vector0.x + ((vector2.x - vector0.x) * alpha_split),      \
            y = vector0.y + ((vector2.y - vector0.y) * alpha_split),\
        }\
        if vector1.x < split_vertex.x then\
            draw_flat_bottom_triangle(vector0,vector1,split_vertex,caller)\
            draw_flat_top_triangle   (vector1,split_vertex,vector2,caller)\
        else\
            draw_flat_bottom_triangle(vector0,split_vertex,vector1,caller)\
            draw_flat_top_triangle   (split_vertex,vector1,vector2,caller)\
        end\
    end\
end\
\
function shapes.get_elipse_points(radius_x,radius_y,xc,yc,filled,caller)\
    local rx,ry = CEIL(FLOOR(radius_x-0.5)/2),CEIL(FLOOR(radius_y-0.5)/2)\
    local x,y=0,ry\
    local d1 = ((ry * ry) - (rx * rx * ry) + (0.25 * rx * rx))\
    local dx = 2*ry^2*x\
    local dy = 2*rx^2*y\
    while dx < dy do\
        caller(x+xc,y+yc)\
        caller(-x+xc,y+yc)\
        caller(x+xc,-y+yc)\
        caller(-x+xc,-y+yc)\
        if filled then\
            for y=-y+yc+1,y+yc-1 do\
                caller(x+xc,y)\
                caller(-x+xc,y)\
            end\
        end\
        if d1 < 0 then\
            x = x + 1\
            dx = dx + 2*ry^2\
            d1 = d1 + dx + ry^2\
        else\
            x,y = x+1,y-1\
            dx = dx + 2*ry^2\
            dy = dy - 2*rx^2\
            d1 = d1 + dx - dy + ry^2\
        end\
    end\
    local d2 = (((ry * ry) * ((x + 0.5) * (x + 0.5))) + ((rx * rx) * ((y - 1) * (y - 1))) - (rx * rx * ry * ry))\
    while y >= 0 do\
        caller(x+xc,y+yc)\
        caller(-x+xc,y+yc)\
        caller(x+xc,-y+yc)\
        caller(-x+xc,-y+yc)\
        if filled then\
            for y=-y+yc,y+yc do\
                caller(x+xc,y)\
                caller(-x+xc,y)\
            end\
        end\
        if d2 > 0 then\
            y = y - 1\
            dy = dy - 2*rx^2\
            d2 = d2 + rx^2 - dy\
        else\
            y = y - 1\
            x = x + 1\
            dy = dy - 2*rx^2\
            dx = dx + 2*ry^2\
            d2 = d2 + dx - dy + rx^2\
        end\
    end\
end\
\
function shapes.get_line_points(startX,startY,endX,endY,caller)\
    startX,startY,endX,endY = FLOOR(startX),FLOOR(startY),FLOOR(endX),FLOOR(endY)\
    if startX == endX and startY == endY then return {{x=startX,y=startY}} end\
    local minX = MIN(startX, endX)\
    local maxX, minY, maxY\
    if minX == startX then minY,maxX,maxY = startY,endX,endY\
    else minY,maxX,maxY = endY,startX,startY end\
    local xDiff,yDiff = maxX - minX,maxY - minY\
    if xDiff > ABS(yDiff) then\
        local y = minY\
        local dy = yDiff / xDiff\
        for x = minX, maxX do\
            caller(x,FLOOR(y + 0.5))\
            y = y + dy\
        end\
    else\
        local x,dx = minX,xDiff / yDiff\
        if maxY >= minY then\
            for y = minY, maxY do\
                caller(FLOOR(x + 0.5),y)\
                x = x + dx\
            end\
        else\
            for y = minY, maxY, -1 do\
                caller(FLOOR(x + 0.5),y)\
                x = x - dx\
            end\
        end\
    end\
end\
\
return shapes",
  [ "core/callbacks/textinput" ] = "return {ev=\"char\",run=function(BUS,caller,ev,char)\
    if BUS.keyboard.textinput then\
        BUS.events[#BUS.events+1] = {\"textinput\",char}\
\
        if type(caller.textinput) == \"function\" then\
            caller.textinput(char)\
        end\
    end\
end}",
  [ "modules/graphics" ] = "local graphics = {}\
\
local tbl   = require(\"common.table_util\")\
local clr   = require(\"common.color_util\")\
local shape = require(\"core.graphics.shape\")\
local quantize = require(\"core.graphics.quantize\")\
local dither = require(\"core.graphics.dither\")\
\
local UNPACK = table.unpack\
local CEIL = math.ceil\
\
return function(BUS)\
\
    local quantizer = quantize.build(BUS)\
    local ditherer  = dither  .build(BUS)\
\
    BUS.clr_instance = clr\
\
    local stack = BUS.graphics.stack\
\
    local function get_stack()\
        return stack[stack.current_pos]\
    end\
\
    local function apply_transfomations(x,y)\
        local stck = get_stack()\
        return\
            x + stck.translate[1],\
            y + stck.translate[2]\
    end\
\
    local function blend_colors(existing,additional)\
        local blend = stack[stack.current_pos].blending\
        return clr.blend[blend.mode][blend.alphamode](existing,additional)\
    end\
\
    local function add_color_xy(x,y,c)\
        local x,y = apply_transfomations(x,y)\
        x = CEIL(x-0.5)\
        y = CEIL(y-0.5)\
        if x>0 and y>0 and x<BUS.graphics.w and y<BUS.graphics.h then\
            local bpos = BUS.graphics.buffer[y]\
            bpos[x] = blend_colors(bpos[x],c)\
        end\
    end\
\
    function graphics.isActive() return BUS.window.active end\
    function graphics.origin()\
        local stck = get_stack()\
        stck.translate = tbl.deepcopy(stack.default.translate)\
\
        --love.graphics.scale\
        --love.graphics.rotate\
        --love.graphics.shrear\
    end\
\
    function graphics.makeDefault()\
        stack[stack.current_pos] = tbl.deepcopy(stack.default)\
    end\
\
    function graphics.getBackgroundColor()\
        return UNPACK(stack[stack.current_pos].background_color)\
    end\
\
    function graphics.clear(r,g,b,a)\
        for x,y in tbl.map_iterator(BUS.graphics.w,BUS.graphics.h) do\
            BUS.graphics.buffer[y][x] = {r,g,b,a or 1}\
        end\
    end\
    function graphics.present()\
        local pal\
        if BUS.cc.quantize then\
            pal = clr.set_palette(BUS,quantizer.quantize())\
        else\
            clr.update_palette(BUS.graphics.display_source)\
        end\
        if BUS.cc.dither then ditherer.dither() end\
        for x,y in tbl.map_iterator(BUS.graphics.w,BUS.graphics.h) do\
            local rgb = BUS.graphics.buffer[y][x]\
            local c = clr.find_closest_color(rgb[1],rgb[2],rgb[3])\
            BUS.graphics.display:set_pixel_raw(x,y,c)\
        end\
        BUS.graphics.display:push_updates()\
        if pal then pal.push(BUS.graphics.display_source) end\
        BUS.graphics.display:draw()\
    end\
\
    function graphics.setColor(red,green,blue,alpha)\
        local stck = get_stack()\
        stck.color = {red,green,blue,alpha or 1}\
    end\
    function graphics.getColor()\
        return tbl.deepcopy(get_stack().color)\
    end\
\
    function graphics.points(...)\
        local points = {...}\
        local stck = get_stack()\
        if type(points[1]) == \"table\" then points = points[1] end\
        local c = tbl.deepcopy(stck.color)\
        local p_offset = CEIL((stck.point_size-1)/2+0.5)\
        for i=1,#points,2 do\
            for a=1,stck.point_size do for b=1,stck.point_size do\
                add_color_xy(\
                    CEIL(points[i]-p_offset+a-0.5),\
                    CEIL(points[i+1]-p_offset+b-0.5)\
                ,c)\
            end end\
        end\
    end\
\
    function graphics.line(...)\
        local lines = {...}\
        local stck = get_stack()\
        if type(lines[1]) == \"table\" then lines = lines[1] end\
        local c = tbl.deepcopy(stck.color)\
        local p_offset = CEIL((stck.line_width-1)/2+0.5)\
        local found_lut = tbl.createNDarray(1)\
        for i=1,#lines,4 do\
            for a=1,stck.line_width do for b=1,stck.line_width do\
                shape.get_line_points(\
                    lines[i],\
                    lines[i+1],\
                    lines[i+2],\
                    lines[i+3],\
                    function(x,y)\
                        local x,y = CEIL(x-p_offset+a-0.5),CEIL(y-p_offset+b-0.5)\
                        if not found_lut[x][y] then\
                            add_color_xy(x,y,c)\
                            found_lut[x][y] = true\
                        end\
                    end\
                )\
            end end\
        end\
    end\
\
    function graphics.setBlendMode(mode,alphamode)\
        local stck = get_stack()\
        stck.blending.mode = mode or \"alpha\"\
        stck.blending.alphamode = alphamode or \"alphamultiply\"\
    end\
    function graphics.getBlendMode()\
        local stck = get_stack()\
        return stck.blending.mode,stck.blending.alphamode\
    end\
\
    function graphics.setPointSize(size)\
        local stck = get_stack()\
        stck.point_size = size\
    end\
    function graphics.getPointSize()\
        local stck = get_stack()\
        return stck.point_size\
    end\
    function graphics.getLineWidth()\
        local stck = get_stack()\
        return stck.line_width\
    end\
    function graphics.setLineWidth(size)\
        local stck = get_stack()\
        stck.line_width = size\
    end\
\
    function graphics.translate(dx,dy)\
        local stck = get_stack()\
        stck.translate = {dx,dy}\
    end\
\
    function graphics.push()\
        local pos = stack.current_pos\
        stack.current_pos = pos + 1\
        stack[pos+1] = tbl.deepcopy(stack[pos])\
    end\
    function graphics.pop()\
        local pos = stack.current_pos\
        stack[pos] = nil\
        stack.current_pos = pos - 1\
    end\
    function graphics.getStackDepth()\
        return #stack\
    end\
\
    function graphics.getDimensions()\
        return BUS.graphics.w,BUS.graphics.h\
    end\
\
    function graphics.newFont(path)\
        return BUS.object.font.new(path)\
    end\
    function graphics.setFont(font)\
        local stck = get_stack()\
        stck.font = font\
    end\
    function graphics.getFont()\
        return tbl.deepcopy(get_stack().font)\
    end\
\
    function graphics.print(text,x,y)\
        local stck = get_stack()\
\
        local x,y = x or 1,y or 1\
        local color = stck.color\
\
        local font = stck.font\
        local height = font.meta.bounds.height\
        for c in tostring(text):gmatch(\".\") do\
            x = x + 1\
\
            local char = font[c]\
            for sx,sy in tbl.map_iterator(char.bounds.width,char.bounds.height) do\
                local cy = sy\
                if char.bounds.height < height then\
                    cy = sy + (height-char.bounds.height) - char.bounds.y\
                end\
                local px = x + sx - 2\
                local py = y + cy - 4\
                if char[sy][sx] then\
                    add_color_xy(px,py,color)\
                end\
            end\
\
            x = x + char.bounds.width\
        end\
    end\
\
    return graphics\
end",
  [ "core/objects/font" ] = "local object = require(\"core.object\")\
\
local font_object = {\
    __index = object.new{\
        getAscent   = function(this) return this.meta.ascent end,\
        getDescent  = function(this) return this.meta.descent end,\
        getBaseline = function(this) return this.meta.baseline or 0 end,\
        getDPIScale = function(this) return this.meta.DPI_scale or 1 end,\
        getFilter   = function(this)\
            return this.meta.filter.min,\
                this.meta.filter.mag,\
                this.meta.filter.anisotropy\
        end,\
        getHeight     = function(this) return this.size.height end,\
        getKerning    = function() return 1 end,\
        getLineHeight = function(this) return this.line_height end,\
        getWidth      = function(this,text)\
            local width = 0\
            for c in text:gmatch(\".\") do\
                width = width + this[c].bounds.width + 1\
            end\
            return width\
        end,\
        getWrap      = function() error(\"Font:getWrap is not implemented yet\") end,\
        hasGlyphs    = function() return false end,\
        setFallbacks = function() error(\"Font:setFallbacks is not implemented yet\") end,\
        setFilter    = function(this,min,mag,anisotropy)\
            this.meta.filter.min = min or \"nearest\"\
            this.meta.filter.mag = mag or \"nearest\"\
            this.meta.filter.anisotropy = anisotropy or 0\
        end,\
        setLineHeight = function(this,height)\
            this.line_height = height or 1\
        end\
    },\
    __tostring = function() return \"Font\" end\
}\
\
return {add=function(BUS)\
    return {new=function(path,internal)\
        local extension = path:match(\"^.+(%..+)$\")\
\
        local font_path = fs.combine(BUS.instance.libdir,path)\
        if not internal then\
            font_path = fs.combine(BUS.instance.gamedir,path)\
        end\
\
        local parser = require(\"core.loaders.font\" .. extension)\
\
        local font_data = parser.read(font_path)\
\
        return setmetatable(font_data,font_object):__build()\
    end}\
end}",
  [ "modules/window" ] = "local tbl = require(\"common.table_util\")\
\
local window = {}\
\
return function(BUS)\
    function window.close() end\
    function window.fromPixels(x,y) return x,y end\
    function window.getDPIScale() return 1 end\
    function window.getDesktopDimensions()\
        local w,h = BUS.graphics.display_source.getSize()\
        return w*2,h*3\
    end\
    function window.getDisplayCount() return 1 end\
    function window.getDisplayName() return BUS.graphics.monitor end\
    function window.getDisplayOrientation(display_index)\
        local w,h = BUS.graphics.display:get().getSize()\
        if w > h then\
            return \"landscape\"\
        elseif h > w then\
            return \"portrait\"\
        end\
        return \"unknown\"\
    end\
    function window.getFullscreen() return \"exclusive\" end\
    function window.getFullscreenModes(display_index)\
        local w,h = BUS.graphics.display:get().getSize()\
        return {{width=w*2,height=h*3}}\
    end\
    function window.getIcon() error(\"love.window.getIcon is not implemented yet\") end\
    function window.getMode()\
        local w,h = BUS.graphics.display:get().getSize()\
        return w,h,tbl.deepcopy(BUS.window)\
    end\
    function window.getPosition() return 1,1,1 end\
    function window.getSafeArea()\
        return 1,1,BUS.graphics.display:get().getSize()\
    end\
    function window.getTitle()\
        if _ENV.multishell then\
            return multishell.getTitle(multishell.getCurrent())\
        else return \"\" end\
    end\
    function window.getVSync() return BUS.window.vsync end\
    function window.hasFocus() return true end\
    function window.hasMouseFocus() return BUS.window.active end\
    function window.isDisplaySleepEnabled() return BUS.window.allow_sleep end\
    function window.isMaximized() return BUS.window.maximized end\
    function window.isMinimized() return not BUS.window.maximized end\
    function window.isOpen() return true end\
    function window.isVisible() return BUS.window.active end\
    function window.maximize() BUS.window.maximized = true  end\
    function window.minimize() BUS.window.maximized = false end\
    function window.requestAttention() end\
    function window.restore() BUS.window.maximized = true end\
    function window.setDisplaySleepEnabled(enable) BUS.window.allow_sleep = enable end\
    function window.setFullscreen(fullscreen,tp)\
        BUS.window.fullscreen = fullscreen\
        BUS.window.fs_type = tp\
        return true\
    end\
    function window.setIcon(imagedata) error(\"love.window.setIcon is not implemented yet\") end\
    function window.setMode(width,height,flags)\
        BUS.graphics.display:get().reposition(1,1,width,height)\
        BUS.graphics.display:resize(width,height)\
        BUS.graphics.w = width*2\
        BUS.graphics.h = height*3\
        BUS.window = flags\
        return true\
    end\
    function window.setPosition(x,y) end\
    function window.setTitle(title)\
        if _ENV.multishell then\
            multishell.setTitle(multishell.getCurrent(),title)\
            return true\
        else return false end\
    end\
    function window.setVSync(vsync) BUS.window.vsync = vsync end\
    function window.toPixels(x,y) return x,y end\
    function window.updateMode(width,height,settings)\
        BUS.graphics.display:get().reposition(1,1,width,height)\
        BUS.graphics.display:resize(width,height)\
        BUS.graphics.w = width*2\
        BUS.graphics.h = height*3\
        for k,v in pairs(settings) do\
            BUS.window[k] = v\
        end\
        return true\
    end\
\
    return window\
end",
  [ "modules/thread" ] = "local generic = require(\"common.generic\")\
\
local object = require(\"core.object\")\
\
local thread = {}\
\
local function is_code(input)\
    local _,newlines   = input:gsub(\"\\n\",\"\\n\")\
    local _,semicolons = input:gsub(\";\",\";\")\
    local _,spaces     = input:gsub(\" \",\" \")\
    if newlines > 1 or semicolons > 1 or spaces > 1 or #input > 1024 then\
        return true\
    else return false end\
end\
\
return function(BUS)\
    local objects = {\
        thread={__index=object.new{\
            getError  = function(this) return this.error end,\
            isRunning = function(this) return coroutine.status(this.c) == \"running\" end,\
            start     = function(this,...)\
                if not this.started then\
                    coroutine.resume(this.c,...)\
                    this.started = true\
                end\
            end,\
            wait = function(this)\
                while coroutine.status(this.c) ~= \"dead\" do\
                    generic.precise_sleep(0.01)\
                end\
            end\
        },__tostring=function() return \"LoveCC_Thread\" end},\
        channel={__index=object.new{\
            clear  = function(this) this.queue = {} end,\
            demand = function(this,timeout)\
                local timed_out = math.huge\
                if timeout then timed_out = os.epoch(\"utc\") + timeout end\
\
                while #this.queue < 1 or os.epoch(\"utc\") > timed_out do\
                    os.queueEvent(\"wait\")\
                    os.pullEvent(\"wait\")\
                end\
\
                local received = table.remove(this.queue,1)\
                this.push_ids[received.id] = true\
                return received.value\
\
            end,\
            getCount = function(this) return #this.queue end,\
            hasRead  = function(this,id) return not not this.pushed_ids[id] end,\
            peek     = function(this)\
                local v = this.queue[1]\
                if v then return v.value end\
                return nil\
            end,\
            performAtomic = function(this,func,...) return func(...) end,\
            pop           = function(this)\
                local received = table.remove(this.queue,1)\
                if received then\
                    this.push_ids[received.id] = true\
                    return received.value\
                end\
                return nil\
            end,\
            push   = function(this,value)\
                local id = generic.uuid4()\
                this.queue[#this.queue+1] = {value=value,id=id}\
                return id\
            end,\
            supply = function(this,value,timeout)\
                local id = generic.uuid4()\
                this.queue[#this.queue+1] = {value=value,id=id}\
\
                local timed_out = math.huge\
                if timeout then timed_out = os.epoch(\"utc\") + timeout end\
\
                while not this.push_ids[id] or os.epoch(\"utc\") > timed_out do\
                    os.queueEvent(\"wait\")\
                    os.pullEvent(\"wait\")\
                end\
                return not (os.epoch(\"utc\") > timed_out)\
            end\
        },__tostring=function() return \"LoveCC_Chanel\" end}\
    }\
\
    function thread.newThread(code)\
        local id = generic.uuid4()\
\
        if not is_code(code) then\
            local selected_path = fs.combine(BUS.instance.gamedir,code)\
            local file,reason = fs.open(selected_path,\"r\")\
            if file then\
                code = file.readAll()\
            else return false,reason end\
        end\
\
        local func,msg = load(code or \"\",\"Thread error\",\"t\",BUS.ENV)\
\
        if func then\
\
            BUS.thread.coro[id] = setmetatable({\
                c = coroutine.create(function(...)\
                    coroutine.yield()\
                    func(...)\
                end),\
                started=false,\
\
                obj_type=\"Thread\",\
                stored_in=BUS.thread.coro,\
                under=id,\
                object=BUS.thread.coro[id]\
            },objects.thread):__build()\
\
            return BUS.thread.coro[id]\
        else return false,msg end\
    end\
\
    local function GET_CHANNEL(name)\
        if BUS.thread.channel[name] then\
            return BUS.thread.channel[name]\
        else\
            BUS.thread.channel[name] = setmetatable({\
                queue={},\
                push_ids={},\
\
                obj_type = \"Channel\",\
                stored_in = BUS.thread.channel,\
                under = name,\
                object = BUS.thread.channel[name]\
\
            },objects.channel):__build()\
            return BUS.thread.channel[name]\
        end\
    end\
\
    function thread.newChannel()\
        local id = generic.uuid4()\
        return GET_CHANNEL(id)\
    end\
\
    function thread.getChannel(name)\
        return GET_CHANNEL(name)\
    end\
\
    return thread\
end",
  [ "core/handlers" ] = "return {attach=function(ENV)\
    ENV.love.handlers = setmetatable({},\
        {__index=function()\
            return function()\
        end\
    end})\
end}",
  [ "core/bus" ] = "return {register_bus=function(ENV)\
    return {\
        timer={last_delta=0,temp_delta=0},\
        love=ENV.love,\
        ENV=ENV,\
        frames={},\
        events={},\
        running=true,\
        graphics={\
            buffer=ENV.utils.table.createNDarray(1),\
            stack = {\
                current_pos=1,\
                default={\
                    background_color={0,0,0,1},\
                    color={1,1,1,1},\
                    blending={mode=\"alpha\",alphamode=\"alphamultiply\"},\
                    point_size=1,\
                    translate={0,0},\
                    line_width=1,\
                }\
            }\
        },\
        mouse={\
            last_x=0,\
            last_y=0,\
            relative_mode=false,\
            grabbed=false,\
            visible=true,\
            held={}\
        },\
        window={\
            fullscreen=true,\
            vsync=false,\
            msaa=0,\
            resizable=true,\
            borderless=true,\
            centered=false,\
            display=1,\
            min_width=0,\
            min_height=0,\
            allow_sleep=false,\
            maximized=true,\
            fs_type=\"desktop\",\
\
            active=true\
        },\
        keyboard={\
            key_reapeat=false,\
            pressed_keys={},\
            textinput=true\
        },\
        thread={\
            channel={},\
            coro={}\
        },\
        instance={},\
        object={},\
        cc={\
            quantize=false,\
            dither=false,\
            dither_factor=15,\
            frame_time_min=1/13,\
            reserved_colors={},\
            reserved_spots={}\
        }\
    }\
end}",
  [ "modules/keyboard" ] = "local keyboard = {}\
\
return function(BUS)\
    function keyboard.getKeyFromScancode(scancode)\
        return scancode\
    end\
    function keyboard.getScancodeFromkey(key)\
        return key\
    end\
\
    function keyboard.getKeyRepeat()\
        return BUS.keyboard.key_reapeat\
    end\
    function keyboard.setKeyRepeat(enable)\
        BUS.keyboard.key_reapeat = enable\
    end\
\
    function keyboard.hasScreenKeyboard()\
        return false\
    end\
\
    function keyboard.hasTextInput()\
        return BUS.keyboard.textinput\
    end\
    function keyboard.setTextInput(enable)\
        BUS.keyboard.setinput = enable\
    end\
\
    function keyboard.isDown(...)\
        local key_list = {...}\
        for k,key in pairs(key_list) do\
            local held = BUS.keyboard.pressed_keys[keys[key]]\
            if not (held and held[1]) then\
                return false\
            end\
        end\
        return true\
    end\
\
    keyboard.isScancodeDown = keyboard.isDown\
\
    return keyboard\
end",
  [ "lib/blbfor" ] = "--[[\
    * BLBFOR - BLIT BYTE FORMAT\
    * a format used for storing blit data\
    * in a compact way\
    * 1 pixel == 2 bytes\
]]\
\
local EXPECT = require(\"cc.expect\").expect\
\
local SEPARATION_CHAR = 0x0A\
local INT_BYTE_OFFSET = 0x30\
local BLBFOR = {INTERNAL={STRING={}}}\
local BLBFOR_WRITE_HANDLE = {}\
local BLBFOR_READ_HANDLE = {}\
\
function BLBFOR.INTERNAL.STRING.FORMAT_BLIT(n)\
    return (\"%x\"):format(n)\
end\
\
function BLBFOR.INTERNAL.STRING.TO_BLIT(c,mode)\
    local res = (not mode) and (BLBFOR.INTERNAL.STRING.FORMAT_BLIT(select(2, math.frexp(c))-1)) or (select(2, math.frexp(c))-1)\
    return res\
end\
\
function BLBFOR.INTERNAL.STRING.FROM_HEX(hex)\
    return tonumber(hex,16)\
end\
\
function BLBFOR.INTERNAL.READ_BYTES_STREAM(stream,start,byte_count)\
    local bytes = {}\
    stream.seek(\"set\",start)\
    for i=start,start+byte_count-1 do\
        local read = stream.read()\
        table.insert(bytes,read)\
    end\
    return table.unpack(bytes)\
end\
\
function BLBFOR.INTERNAL.STRING_TO_BYTES(str)\
    local bytes = {}\
    for i=1,#str do\
        bytes[i] = str:byte(i)\
    end\
    return table.unpack(bytes)\
end\
\
function BLBFOR.INTERNAL.WRITE_BYTES_STREAM(stream,pos,...)\
    local bytes = {...}\
    for i=1,#bytes do\
        stream.seek(\"set\",pos+i-1)\
        stream.write(bytes[i])\
    end\
end\
\
function BLBFOR.INTERNAL.READ_STRING_UNTIL_SEP(stream,pos)\
    local str = \"\"\
    stream.seek(\"set\",pos)\
    local byte = stream.read()\
    if not byte then return false end\
    while byte ~= SEPARATION_CHAR do\
        str = str .. string.char(byte)\
        byte = stream.read()\
    end\
    return str\
end\
\
function BLBFOR.INTERNAL.READ_INT(stream,pos)\
    local num = 0\
    stream.seek(\"set\",pos)\
    local byte = stream.read()\
    while byte ~= SEPARATION_CHAR do\
        num = num * 10 + (byte-INT_BYTE_OFFSET)\
        byte = stream.read()\
    end\
    return num\
end\
\
function BLBFOR.INTERNAL.COLORS_TO_BYTE(fg,bg)\
    local log_fg = select(2, math.frexp(fg))-1\
    local log_bg = select(2, math.frexp(bg))-1\
    return log_fg*16 + log_bg\
end\
\
function BLBFOR.INTERNAL.BYTE_TO_COLORS(byte)\
    return bit32.rshift(bit32.band(0xF0,byte),4),bit32.band(0x0F,byte)\
end\
\
function BLBFOR.INTERNAL.WRITE_HEADER(image)\
    image.stream.seek(\"set\",0)\
    local meta = textutils.serialiseJSON(image.meta):gsub(\"\\n\",\"NEWLINE\")\
    BLBFOR.INTERNAL.WRITE_BYTES_STREAM(\
        image.stream,0,\
        BLBFOR.INTERNAL.STRING_TO_BYTES(\
            (\"BLBFOR1\\n%d\\n%d\\n%d\\n%d\\n%s\\n\"):format(\
                image.width,image.height,image.layers,\
                os.epoch(\"utc\"),meta\
            )\
        )\
    )\
end\
\
function BLBFOR.INTERNAL.STRING.PART(str,part_size)\
    local parts = {}\
    for i = 1, #str, part_size do\
        parts[#parts+1] = str:sub(i, i+part_size-1)\
    end\
    return parts\
end\
\
function BLBFOR.INTERNAL.EMULATE_FS_BINARY_HANDLE(web)\
    local raw = web.readAll()\
    web.close()\
\
    local parts = BLBFOR.INTERNAL.STRING.PART(raw,5000)\
    local byte_arrays = {}\
\
    for part,bytes in ipairs(parts) do\
        byte_arrays[part] = {bytes:byte(1,-1)}\
    end\
\
    local stream = {}\
\
    local _CURSOR = 1\
    function stream.seek(mode, arg)\
        if mode == \"cur\" then return _CURSOR - 1\
        elseif mode == \"set\" then _CURSOR = arg + 1; return arg + 1 end\
    end\
    function stream.read()\
        local part = math.ceil(_CURSOR/5000)\
        local byte = byte_arrays[part][(_CURSOR-1)%5000+1]\
        _CURSOR = _CURSOR + 1\
        return byte\
    end\
    function stream.close() end\
    return stream,raw\
end\
\
function BLBFOR.INTERNAL.ASSERT(bool,msg)\
    if not bool then error(msg,3)\
    else return bool end\
end\
\
function BLBFOR.INTERNAL.createNDarray(n, tbl)\
    tbl = tbl or {}\
    if n == 0 then return tbl end\
    setmetatable(tbl, {__index = function(t, k)\
        local new =  BLBFOR.INTERNAL.createNDarray(n - 1)\
        t[k] = new\
        return new\
    end})\
    return tbl\
end\
\
function BLBFOR.INTERNAL.ENCODE(self)\
    BLBFOR.INTERNAL.WRITE_HEADER(self)\
    for layer_index,layer in ipairs(self.data) do\
        for y,xlist in ipairs(layer) do\
            local bytes = {}\
            for x,pixel in ipairs(xlist) do\
                table.insert(bytes,pixel[1])\
                table.insert(bytes,BLBFOR.INTERNAL.COLORS_TO_BYTE(2^pixel[2],2^pixel[3]))\
            end\
            BLBFOR.INTERNAL.WRITE_BYTES_STREAM(\
                self.stream,\
                self.stream.seek(\"cur\"),\
                table.unpack(bytes)\
            )\
        end\
    end\
end\
\
function BLBFOR.INTERNAL.DECODE(image)\
    image.stream.seek(\"set\",0)\
    local header = BLBFOR.INTERNAL.READ_STRING_UNTIL_SEP(image.stream,0)\
    local lines = BLBFOR.INTERNAL.createNDarray(2)\
    BLBFOR.INTERNAL.ASSERT(header == \"BLBFOR1\", \"Invalid header\")\
    local width =  BLBFOR.INTERNAL.READ_INT(image.stream,image.stream.seek(\"cur\"))\
    local height = BLBFOR.INTERNAL.READ_INT(image.stream,image.stream.seek(\"cur\"))\
    local layers = BLBFOR.INTERNAL.READ_INT(image.stream,image.stream.seek(\"cur\"))\
    local flushed = BLBFOR.INTERNAL.READ_INT(image.stream,image.stream.seek(\"cur\"))\
    local meta = textutils.unserializeJSON(BLBFOR.INTERNAL.READ_STRING_UNTIL_SEP(image.stream,image.stream.seek(\"cur\")))\
    image.width = width\
    image.height = height\
    image.layers = layers\
    image.meta = meta\
    image.last_flushed = flushed\
    image.data = BLBFOR.INTERNAL.createNDarray(3,image.data)\
    for layer=1,image.layers do\
        for y=1,height do\
            if not next(lines[layer][y]) then lines[layer][y] = {\"\",\"\",\"\"} end\
            local xlist = {}\
            for x=1,width do\
                local pixel = {}\
                local char,color =  BLBFOR.INTERNAL.READ_BYTES_STREAM(image.stream,image.stream.seek(\"cur\"),2)\
                pixel[1] = char\
                pixel[2],pixel[3] = BLBFOR.INTERNAL.BYTE_TO_COLORS(color)\
                xlist[x] = pixel\
                lines[layer][y] = {\
                    lines[layer][y][1]..string.char(pixel[1]),\
                    lines[layer][y][2]..BLBFOR.INTERNAL.STRING.FORMAT_BLIT(pixel[2]),\
                    lines[layer][y][3]..BLBFOR.INTERNAL.STRING.FORMAT_BLIT(pixel[3])\
                }\
            end\
            image.data[layer][y] = xlist\
        end\
        os.queueEvent(\"yield\")\
        os.pullEvent()\
    end\
    image.lines = lines\
end\
\
function BLBFOR_WRITE_HANDLE:set_pixel(layer,x,y,char,fg,bg)\
    BLBFOR.INTERNAL.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    BLBFOR.INTERNAL.ASSERT(not self.closed,\"Image handle closed\")\
    EXPECT(1,layer,\"number\")\
    EXPECT(2,x,\"number\")\
    EXPECT(3,y,\"number\")\
    EXPECT(4,char,\"string\")\
    EXPECT(5,fg,\"number\")\
    EXPECT(6,bg,\"number\")\
    BLBFOR.INTERNAL.ASSERT(not (x<1 or y<1 or x>self.width or y>self.height),\"pixel out of range\")\
    self.data[layer][y][x] = {\
        char:byte(),\
        BLBFOR.INTERNAL.STRING.TO_BLIT(fg,true),\
        BLBFOR.INTERNAL.STRING.TO_BLIT(bg,true)\
    }\
end\
\
function BLBFOR_READ_HANDLE:get_pixel(layer,x,y,return_blit)\
    BLBFOR.INTERNAL.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    EXPECT(1,layer,\"number\")\
    EXPECT(2,x,\"number\")\
    EXPECT(3,y,\"number\")\
    EXPECT(4,return_blit,\"boolean\",\"nil\")\
    BLBFOR.INTERNAL.ASSERT(not (x<1 or y<1 or x>self.width or y>self.height),\"pixel out of range\")\
    local pixel = self.data[layer][y][x]\
    local standard = {\
        string.char(pixel[1]),\
        2^pixel[2],\
        2^pixel[3]\
    }\
    local blit = {\
        string.char(pixel[1]),\
        BLBFOR.INTERNAL.STRING.FORMAT_BLIT(pixel[2]),\
        BLBFOR.INTERNAL.STRING.FORMAT_BLIT(pixel[3])\
    }\
    return table.unpack(return_blit and blit or standard)\
end\
\
function BLBFOR_READ_HANDLE:get_line(layer,y)\
    BLBFOR.INTERNAL.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    EXPECT(1,layer,\"number\")\
    EXPECT(2,y,\"number\")\
    BLBFOR.INTERNAL.ASSERT(not (y<1 or y>self.height),\"line out of range\")\
    return self.lines[layer][y][1],\
        self.lines[layer][y][2],\
        self.lines[layer][y][3]\
end\
\
function BLBFOR_WRITE_HANDLE:set_line(layer,y,char,fg,bg)\
    BLBFOR.INTERNAL.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    BLBFOR.INTERNAL.ASSERT(not self.closed,\"Image handle closed\")\
    EXPECT(1,layer,\"number\")\
    EXPECT(2,y,\"number\")\
    EXPECT(3,char,\"string\")\
    EXPECT(4,fg,\"string\")\
    EXPECT(5,bg,\"string\")\
    BLBFOR.INTERNAL.ASSERT(#fg == #char and #bg == #char,\"line length mismatch\")\
    BLBFOR.INTERNAL.ASSERT(#char <= self.width,\"line too long\")\
    BLBFOR.INTERNAL.ASSERT(y <= self.height and y > 0,\"line out of range\")\
    for x=1,#char do\
        self:set_pixel(\
            layer,x,y,\
            char:sub(x,x),\
            2^BLBFOR.INTERNAL.STRING.FROM_HEX(fg:sub(x,x)),\
            2^BLBFOR.INTERNAL.STRING.FROM_HEX(bg:sub(x,x))\
        )\
    end\
end\
\
function BLBFOR_WRITE_HANDLE:close()\
    BLBFOR.INTERNAL.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    BLBFOR.INTERNAL.ASSERT(not self.closed,\"Image handle closed\")\
    BLBFOR.INTERNAL.ENCODE(self)\
    self.stream.close()\
    self.closed = true\
end\
\
function BLBFOR_WRITE_HANDLE:flush()\
    BLBFOR.INTERNAL.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    BLBFOR.INTERNAL.ASSERT(not self.closed,\"Image handle closed\")\
    BLBFOR.INTERNAL.ENCODE(self)\
    self.stream.flush()\
end\
\
BLBFOR_WRITE_HANDLE.write_pixel = BLBFOR_WRITE_HANDLE.set_pixel\
BLBFOR_WRITE_HANDLE.write_line = BLBFOR_WRITE_HANDLE.set_line\
BLBFOR_READ_HANDLE.read_pixel = BLBFOR_READ_HANDLE.get_pixel\
BLBFOR_READ_HANDLE.read_line = BLBFOR_READ_HANDLE.get_line\
\
function BLBFOR.open(file, mode, width, height, layers, FG, BG, SYM, meta)\
    EXPECT(1,file,\"string\")\
    EXPECT(2,mode,\"string\")\
    local EXT = file:match(\"%.%a+$\")\
    BLBFOR.INTERNAL.ASSERT(EXT==\".bbf\",\"file must be a .bbf file\")\
    local image = {}\
    if mode:sub(1,1):lower() == \"w\" then\
        EXPECT(3,width,\"number\")\
        EXPECT(4,height,\"number\")\
        EXPECT(5,layers,\"number\",\"nil\")\
        EXPECT(6,FG,\"string\",\"nil\")\
        EXPECT(7,BG,\"string\",\"nil\")\
        EXPECT(8,SYM,\"string\",\"nil\")\
        EXPECT(9,meta,\"table\",\"nil\")\
        layers = layers or 1\
        local stream = fs.open(file,\"wb\")\
        if not stream then error(\"Could not open file\",2) end\
        image.meta = meta or {}\
        image.width = width\
        image.height = height\
        image.layers = layers\
        image.data = BLBFOR.INTERNAL.createNDarray(3)\
        image.stream = stream\
        for layer_index=1,layers do\
            for x=1,width do\
                for y=1,height do\
                    image.data[layer_index][y][x] = {\
                        (SYM or string.char(0)):byte(),\
                        BLBFOR.INTERNAL.STRING.TO_BLIT(FG or colors.black,true),\
                        BLBFOR.INTERNAL.STRING.TO_BLIT(BG or colors.black,true)\
                    }\
                end\
            end\
        end\
        return setmetatable(image,{__index=BLBFOR_WRITE_HANDLE})\
    elseif mode:sub(1,1):lower() == \"r\" then\
        local stream = fs.open(file,\"rb\")\
        if not stream then error(\"Could not open file\",2) end\
        local pos = stream.seek(\"cur\")\
        image.raw = stream.readAll()\
        stream.seek(\"set\",pos)\
        image.stream = stream\
        BLBFOR.INTERNAL.DECODE(image)\
        image.closed = true\
        stream.close()\
        return setmetatable(image,{__index=BLBFOR_READ_HANDLE})\
    else\
        error(\"invalid mode. please use \\\"w\\\" or \\\"r\\\" (Write/Read)\",2)\
    end\
end\
\
function BLBFOR.open_url(url)\
    EXPECT(1, url, \"string\")\
    local web_handle,err_reason = http.get(url, nil, true)\
    if not web_handle then error(\"Could not get image. \" .. err_reason, 2) end\
    local image = {}\
    image.stream,image.raw = BLBFOR.INTERNAL.EMULATE_FS_BINARY_HANDLE(web_handle)\
    BLBFOR.INTERNAL.DECODE(image)\
    image.stream.close()\
    image.closed = true\
    return setmetatable(image, { __index = BLBFOR_READ_HANDLE })\
end\
\
return BLBFOR",
  [ "core/objects/image" ] = "",
  init = "local selfDir = fs.getDir(shell.getRunningProgram())\
\
local utils = {\
    colors=require(\"common.color_util\"),\
    draw=require(\"common.draw_util\"),\
    generic=require(\"common.generic\"),\
    math=require(\"common.math_util\"),\
    string=require(\"common.string_util\"),\
    table=require(\"common.table_util\"),\
    window=require(\"common.window_util\"),\
    parse=require(\"common.parser_util\")\
}\
\
local runtime_env = setmetatable({\
    love={},\
    utils=utils\
},{__index=_ENV})\
\
local ok,err = pcall(require(\"main\"),runtime_env,selfDir,...)\
\
return {init_ok=ok,env=err,util=utils}\
",
  [ "core/threads/resize_thread" ] = "local pixelbox = require(\"lib.pixelbox\").new\
\
return {make=function(ENV,BUS,terminal)\
    local last_x,last_y = terminal.getSize()\
    return coroutine.create(function()\
        while true do\
            local cx,cy = terminal.getSize()\
            if cx ~= last_x or cy ~= last_y \
                and BUS.window.resizable\
                and cx >= BUS.window.min_width\
                and cy >= BUS.window.min_height\
            then\
                BUS.graphics.display:get().reposition(1,1,cx,cy)\
                BUS.graphics.display:resize(cx,cy)\
                BUS.graphics.w = cx*2\
                BUS.graphics.h = cy*3\
                last_x,last_y = cx,cy\
            end\
            sleep(0.1)\
        end\
    end)\
end}",
  [ "core/threads/update_thread" ] = "local run = require(\"core.default_run\")\
local generic = require(\"common.generic\")\
\
return {make=function(ENV,BUS,args)\
    return coroutine.create(function()\
        run(ENV.love,args)\
        local runner = ENV.love.run()\
\
        while true do\
            local frame_start = os.epoch(\"utc\")\
            runner()\
            local current_time = os.epoch(\"utc\")\
            local frame_time = current_time-frame_start\
            BUS.timer.temp_delta = frame_time\
\
            BUS.frames[#BUS.frames+1] = {ft=frame_time,begin=frame_start}\
\
            for k,v in ipairs(BUS.frames) do\
                local t_diff = current_time-v.begin\
                if t_diff > 1000 then\
                    table.remove(BUS.frames,1)\
                else break end\
            end\
            generic.precise_sleep(BUS.cc.frame_time_min)\
        end\
    end)\
end}",
  [ "common/generic" ] = "local generic = {}\
function generic.uuid4()\
    local random = math.random\
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'\
    return string.gsub(template, '[xy]', function (c)\
        return string.format('%x', c == 'x' and random(0, 0xf) or random(8, 0xb))\
    end)\
end\
\
function generic.precise_sleep(t)\
    local ftime = os.epoch(\"utc\")+t*1000\
    while os.epoch(\"utc\") < ftime do\
        os.queueEvent(\"waiting\")\
        os.pullEvent(\"waiting\")\
    end\
end\
\
function generic.piece_string(str)\
    local out = {}\
    local n = 0\
    str:gsub(\".\",function(c)\
        n = n + 1\
        out[n] = c\
    end)\
    return out\
end\
\
generic.events_with_cords = {\
    monitor_touch=true,\
    mouse_click=true,\
    mouse_drag=true,\
    mouse_scroll=true,\
    mouse_up=true,\
    mouse_move=true\
}\
\
return generic",
  [ "modules/love" ] = "return function(BUS)\
end",
  love = "local args = {...}\
\
local terminal = window.create(term.current(),1,1,term.getSize())\
\
local ok,LoveCCData = pcall(require,\"LoveCC\")\
if not ok then error(\"LoveCC could not be loaded \\n\"..LoveCCData,0) end\
\
local init_win,ox,oy = LoveCCData.util.window.get_parent_info(terminal)\
local advice_api = \"https://api.adviceslip.com/advice\"\
\
local function error_screen(err,is_lovecc)\
    local trace = debug.traceback()\
    local tid = os.startTimer(0.1)\
    local last = {init_win.getSize()}\
    while true do\
        local ev = table.pack(os.pullEvent())\
        if ev[1] == \"timer\" and tid == ev[2] then\
\
            terminal.setVisible(false)\
\
            tid = os.startTimer(0.1)\
            local w,h = init_win.getSize()\
\
            if last[1] ~= w or last[2] ~= h then\
                terminal.reposition(1,1,w,h)\
            end\
\
            terminal.setBackgroundColor(colors.blue)\
            terminal.clear()\
            terminal.setCursorPos(3,3)\
            terminal.setBackgroundColor(colors.red)\
            terminal.write(LoveCCData.util.string.ensure_size(\"Error\",w-4))\
\
            terminal.setBackgroundColor(colors.blue)\
            if is_lovecc then terminal.setBackgroundColor(colors.red) end\
            terminal.setCursorPos(3,5)\
            local err_line_taking = LoveCCData.util.draw.respect_newlines(terminal,\
                LoveCCData.util.string.wrap(err,w-4)\
            )\
\
            terminal.setBackgroundColor(colors.gray)\
            terminal.setCursorPos(3,6+err_line_taking)\
            LoveCCData.util.draw.respect_newlines(terminal,\
                LoveCCData.util.string.ensure_line_size(\
                    LoveCCData.util.string.wrap_lines(\
                        LoveCCData.util.parse.stack_trace(trace),\
                        w-4\
                    ),\
                w-4)\
            )\
\
            terminal.setBackgroundColor(colors.blue)\
            terminal.setCursorPos(3,h-1)\
            terminal.write(\"Press \\\"C\\\" to cry.\")\
\
            terminal.setVisible(true)\
        elseif ev[1] == \"key\" and ev[2] == keys.c then\
            init_win.setBackgroundColor(colors.black)\
            init_win.clear()\
            init_win.setCursorPos(1,1)\
            break\
        end\
    end\
end\
\
local function no_game_screen()\
    local web = http.get(advice_api)\
    local advice = \"Try out GuiH !\"\
    if web then\
        advice = textutils.unserializeJSON(web.readAll()).slip.advice\
    end\
    local tid = os.startTimer(0.1)\
    local last = {init_win.getSize()}\
    while true do\
        local ev = table.pack(os.pullEvent())\
        if ev[1] == \"timer\" and tid == ev[2] then\
\
            terminal.setVisible(false)\
            terminal.setBackgroundColor(colors.blue)\
            terminal.clear()\
            \
\
            tid = os.startTimer(0.1)\
            local w,h = init_win.getSize()\
\
            if last[1] ~= w or last[2] ~= h then\
                terminal.reposition(1,1,w,h)\
            end\
\
            terminal.setBackgroundColor(colors.red)\
            terminal.setCursorPos(3,3)\
            local lines = LoveCCData.util.draw.respect_newlines(terminal,\
                LoveCCData.util.string.ensure_line_size(\
                    LoveCCData.util.string.wrap(\"No game.\",w-4),\
                w-4)\
            )\
\
            terminal.setBackgroundColor(colors.black)\
            terminal.setCursorPos(3,4+lines)\
            LoveCCData.util.draw.respect_newlines(terminal,\
                LoveCCData.util.string.ensure_line_size(\
                    LoveCCData.util.string.wrap(\"\\\"\"..advice..\"\\\"\",w-4),\
                w-4)\
            )\
            terminal.setBackgroundColor(colors.blue)\
\
            terminal.setCursorPos(3,h-1)\
            LoveCCData.util.draw.respect_newlines(terminal,\
                LoveCCData.util.string.wrap(\"Press enter to exit\",w-4)\
            )\
\
            terminal.setVisible(true)\
\
        elseif ev[1] == \"key\" and ev[2] == keys.enter then\
            init_win.setBackgroundColor(colors.black)\
            init_win.clear()\
            init_win.setCursorPos(1,1)\
            break\
        end\
    end\
end\
\
if not LoveCCData.init_ok then error_screen(\"Internal error: \" .. tostring(LoveCCData.env),true) end\
\
local errored = true\
\
local ok,err = pcall(function()\
    if not next(args) then\
        no_game_screen()\
        errored = true\
    elseif not fs.exists(args[1]) or not fs.isDir(args[1]) then\
        error_screen(\"Loading error: folder does not exist\")\
        errored = true\
    elseif fs.exists(args[1]) and not fs.isDir(args[1]) then\
        error_screen(\"Loading error: must be ran on a folder\")\
        errored = true\
    elseif fs.exists(args[1]) and fs.isDir(args[1]) then\
        local full_path = fs.combine(args[1],\"main.lua\")\
        if fs.exists(full_path) then\
            local fl = fs.open(full_path,\"r\")\
            local data = fl.readAll()\
            fl.close()\
            local ok,err = pcall(LoveCCData.env,{loadfile(full_path)},full_path,terminal,init_win,ox,oy)\
            if not ok then error_screen(\"Runtime error: \" .. tostring(err)) end\
        else\
            error_screen(\"Loading error: No code to run\\nmake sure you have a main.lua file on the top level of the folder\")\
        end\
    else errored = false end\
end)\
\
if not ok and not errored then\
    error_screen(\"Runtime error: \" .. err)\
elseif not ok then\
    init_win.setBackgroundColor(colors.black)\
    init_win.clear()\
    init_win.setCursorPos(1,1)\
end\
",
  [ "core/objects/transform" ] = "",
  [ "lib/readBDFFont" ] = "-- MIT License\
--\
-- Copyright (c) 2019 JackMacWindows\
--\
-- Permission is hereby granted, free of charge, to any person obtaining a copy\
-- of this software and associated documentation files (the \"Software\"), to deal\
-- in the Software without restriction, including without limitation the rights\
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\
-- copies of the Software, and to permit persons to whom the Software is\
-- furnished to do so, subject to the following conditions:\
--\
-- The above copyright notice and this permission notice shall be included in all\
-- copies or substantial portions of the Software.\
--\
-- THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\
-- SOFTWARE.\
\
-- require() this file, returns function to load from string\
-- characters will be located at font.chars[ch] in output\
-- bitmap rows may not be as wide as the entire character,\
--  but the bitmap will be the same height as the character\
\
local function string_split_word(text)\
    local spat, epat, buf, quoted = [=[^(['\"])]=], [=[(['\"])$]=]\
    local retval = {}\
    for str in text:gmatch(\"%S+\") do\
        local squoted = str:match(spat)\
        local equoted = str:match(epat)\
        local escaped = str:match([=[(\\*)['\"]$]=])\
        if squoted and not quoted and not equoted then\
            buf, quoted = str, squoted\
        elseif buf and equoted == quoted and #escaped % 2 == 0 then\
            str, buf, quoted = buf .. ' ' .. str, nil, nil\
        elseif buf then\
            buf = buf .. ' ' .. str\
        end\
        if not buf then table.insert(retval, (str:gsub(spat,\"\"):gsub(epat,\"\"))) end\
    end\
    return retval\
end\
\
local function foreach(func, ...)\
    local retval = {}\
    for k,v in pairs({...}) do retval[k] = func(v) end\
    return table.unpack(retval)\
end\
\
local function parseValue(str) \
    local ok, res = pcall(loadstring(\"return \" .. string.gsub(str, \"`\", \"\")))\
    if not ok then return str else return res end\
end\
\
local function parseLine(str)\
    local tok = string_split_word(str)\
    return table.remove(tok, 1), foreach(parseValue, table.unpack(tok))\
end\
\
local propertymap = {\
    FOUNDRY = \"foundry\",\
    FAMILY_NAME = \"family\",\
    WEIGHT_NAME = \"weight\",\
    SLANT = \"slant\",\
    SETWIDTH_NAME = \"weight_name\",\
    ADD_STYLE_NAME = \"add_style_name\",\
    PIXEL_SIZE = \"pixels\",\
    POINT_SIZE = \"points\",\
    SPACING = \"spacing\",\
    AVERAGE_WIDTH = \"average_width\",\
    FONT_NAME = \"name\",\
    FACE_NAME = \"face_name\",\
    COPYRIGHT = \"copyright\",\
    FONT_VERSION = \"version\",\
    FONT_ASCENT = \"ascent\",\
    FONT_DESCENT = \"descent\",\
    UNDERLINE_POSITION = \"underline_position\",\
    UNDERLINE_THICKNESS = \"underline_thickness\",\
    X_HEIGHT = \"height_x\",\
    CAP_HEIGHT = \"height_cap\",\
    RAW_ASCENT = \"raw_ascent\",\
    RAW_DESCENT = \"raw_descent\",\
    NORM_SPACE = \"normal_space\",\
    RELATIVE_WEIGHT = \"relative_weight\",\
    RELATIVE_SETWIDTH = \"relative_setwidth\",\
    FIGURE_WIDTH = \"figure_width\",\
    AVG_LOWERCASE_WIDTH = \"average_lower_width\",\
    AVG_UPPERCASE_WIDTH = \"average_upper_width\"\
}\
\
local function ffs(value)\
    if value == 0 then return 0 end\
    local pos = 0;\
    while bit32.band(value, 1) == 0 do\
        value = bit32.rshift(value, 1);\
        pos = pos + 1\
    end\
    return pos\
end\
\
local function readBDFFont(str)\
    local retval = {comments = {}, resolution = {}, superscript = {}, subscript = {}, charset = {}, chars = {}}\
    local mode = 0\
    local ch\
    local charname\
    local chl = 1\
    for line in str:gmatch(\"[^\\n]+\") do\
        local values = {parseLine(line)}\
        local key = table.remove(values, 1)\
        if mode == 0 then\
            if (key ~= \"STARTFONT\" or values[1] ~= 2.1) then\
                error(\"Attempted to load invalid BDF font\", 2)\
            else mode = 1 end\
        elseif mode == 1 then\
            if key == \"FONT\" then retval.id = values[1]\
            elseif key == \"SIZE\" then retval.size = {px = values[1], x_dpi = values[2], y_dpi = values[3]}\
            elseif key == \"FONTBOUNDINGBOX\" then retval.bounds = {x = values[3], y = values[4], width = values[1], height = values[2]}\
            elseif key == \"COMMENT\" then table.insert(retval.comments, values[1])\
            elseif key == \"ENDFONT\" then return retval\
            elseif key == \"STARTCHAR\" then \
                mode = 3\
                charname = values[1]\
            elseif key == \"STARTPROPERTIES\" then mode = 2 end\
        elseif mode == 2 then\
            if propertymap[key] ~= nil then retval[propertymap[key]] = values[1]\
            elseif key == \"RESOLUTION_X\" then retval.resolution.x = values[1]\
            elseif key == \"RESOLUTION_Y\" then retval.resolution.y = values[1]\
            elseif key == \"CHARSET_REGISTRY\" then retval.charset.registry = values[1]\
            elseif key == \"CHARSET_ENCODING\" then retval.charset.encoding = values[1]\
            elseif key == \"FONTNAME_REGISTRY\" then retval.charset.fontname_registry = values[1]\
            elseif key == \"CHARSET_COLLECTIONS\" then retval.charset.collections = string_split_word(values[1])\
            elseif key == \"SUPERSCRIPT_X\" then retval.superscript.x = values[1]\
            elseif key == \"SUPERSCRIPT_Y\" then retval.superscript.y = values[1]\
            elseif key == \"SUPERSCRIPT_SIZE\" then retval.superscript.size = values[1]\
            elseif key == \"SUBSCRIPT_X\" then retval.subscript.x = values[1]\
            elseif key == \"SUBSCRIPT_Y\" then retval.subscript.y = values[1]\
            elseif key == \"SUBSCRIPT_SIZE\" then retval.subscript.size = values[1]\
            elseif key == \"ENDPROPERTIES\" then mode = 1 end\
        elseif mode == 3 then\
            if ch ~= nil then\
                if charname ~= nil then\
                    retval.chars[ch].name = charname\
                    charname = nil\
                end\
                if key == \"SWIDTH\" then retval.chars[ch].scalable_width = {x = values[1], y = values[2]}\
                elseif key == \"DWIDTH\" then retval.chars[ch].device_width = {x = values[1], y = values[2]}\
                elseif key == \"BBX\" then \
                    retval.chars[ch].bounds = {x = values[3], y = values[4], width = values[1], height = values[2]}\
                    retval.chars[ch].bitmap = {}\
                    for y = 1, values[2] do retval.chars[ch].bitmap[y] = {} end\
                elseif key == \"BITMAP\" then \
                    mode = 4 \
                end\
            elseif key == \"ENCODING\" then \
                ch = values[1] <= 255 and string.char(values[1]) or values[1]\
                retval.chars[ch] = {}\
            end\
        elseif mode == 4 then\
            if key == \"ENDCHAR\" then \
                ch = nil\
                chl = 1\
                mode = 1 \
            else\
                local num = tonumber(\"0x\" .. key)\
                --if type(num) ~= \"number\" then print(\"Bad number: 0x\" .. num) end\
                local l = {}\
                local w = math.ceil(math.floor(math.log(num) / math.log(2)) / 8) * 8\
                for i = ffs(num) or 0, w do l[w-i+1] = bit32.band(bit32.rshift(num, i-1), 1) == 1 end\
                retval.chars[ch].bitmap[chl] = l\
                chl = chl + 1\
            end\
        end\
    end\
    return retval\
end\
\
return readBDFFont",
  [ "core/cmgr" ] = "local lib_cmgr = {}\
local newline = \"\\n\"\
\
function lib_cmgr.add_thread_pointer(threads,f)\
    local t = {coro=coroutine.create(f)}\
    threads[t] = t\
end\
\
local function unpack_ev(e)\
    return table.unpack(e,1,e.n)\
end\
\
function lib_cmgr.start(ENV,toggle,thread_pointer,main_thread,...)\
    local static_threads = {...}\
    local static_thread_filters = {}\
    local main_filter\
    local e\
    while coroutine.status(main_thread) ~= \"dead\" and type(e) == \"nil\" and toggle() do\
        local ev = table.pack(os.pullEventRaw())\
        if ev[1] == \"terminate\" then\
            if type(ENV.love.quit)  == \"function\" then\
                if not ENV.love.quit() then\
                    e = \"Terminated\"\
                end\
            else e = \"Terminated\" end\
        else\
            if ev[1] == main_filter or not main_filter then\
                local ok,ret = coroutine.resume(main_thread,unpack_ev(ev))\
                if ok then main_filter = ret end\
                if not ok and coroutine.status(main_thread) == \"dead\" then\
                    e = \"Error in main thread\"..newline..tostring(ret)\
                end\
            end\
            for k,v in pairs(static_threads) do\
                local f = static_thread_filters[k]\
                if ev[1] == f or not f then\
                    if coroutine.status(v) ~= \"dead\" then\
                        local ok,ret = coroutine.resume(v,unpack_ev(ev))\
                        if ok then static_thread_filters[k] = ret end\
                        if not ok and coroutine.status(v) == \"dead\" then\
                            e = ret\
                        end\
                    else static_threads[k] = nil end\
                end\
            end\
            for k,v in pairs(thread_pointer) do\
                local filter = v.filter\
                if ev[1] == filter or not filter then\
                    if coroutine.status(v) ~= \"dead\" then\
                        local ok,ret = coroutine.resume(v.coro,unpack_ev(ev))\
                        if ok then thread_pointer[k].filter = ret end\
                        if not ok and coroutine.status(v.coro) == \"dead\" then\
                            e = ret\
                        end\
                    else thread_pointer[k] = nil end\
                end\
            end\
        end\
    end\
\
    local disp =  ENV.love.cc.get_bus().graphics.display_source\
\
    for i=0,15 do\
        local c = 2^i\
        disp.setPaletteColor(c,term.nativePaletteColor(c))\
    end\
\
    if toggle() then return false,e end\
    return true\
end\
\
return lib_cmgr",
  [ "lib/pixelbox" ] = "--[[\
    * api for easy interaction with drawing characters\
    * single file implementation of GuiH pixelbox api\
]]\
\
local EXPECT = require(\"cc.expect\").expect\
\
local PIXELBOX = {}\
local OBJECT = {}\
local api = {}\
local ALGO = {}\
local graphic = {}\
\
local CEIL  = math.ceil\
local FLOOR = math.floor\
local SQRT  = math.sqrt\
local MIN   = math.min\
local ABS   = math.abs\
local t_insert, t_unpack, t_sort, s_char, pairs = table.insert, table.unpack, table.sort, string.char, pairs\
\
local chars = \"0123456789abcdef\"\
graphic.to_blit = {}\
graphic.logify  = {}\
for i = 0, 15 do\
    graphic.to_blit[2^i] = chars:sub(i + 1, i + 1)\
    graphic.logify [2^i] = i\
end\
\
function PIXELBOX.INDEX_SYMBOL_CORDINATION(tbl,x,y,val)\
    tbl[x+y*2-2] = val\
    return tbl\
end\
\
function OBJECT:within(x,y)\
    return x > 0\
        and y > 0\
        and x <= self.width*2\
        and y <= self.height*3\
end\
\
function PIXELBOX.RESTORE(BOX,color)\
    BOX.CANVAS = api.createNDarray(1)\
    BOX.UPDATES = api.createNDarray(1)\
    BOX.CHARS = api.createNDarray(1)\
    for y=1,BOX.height*3 do\
        for x=1,BOX.width*2 do\
            BOX.CANVAS[y][x] = color\
        end\
    end\
    for y=1,BOX.height do\
        for x=1,BOX.width do\
            BOX.CHARS[y][x] = {symbol=\" \",background=graphic.to_blit[color],fg=\"f\"}\
        end\
    end\
    getmetatable(BOX.CANVAS).__tostring = function() return \"PixelBOX_SCREEN_BUFFER\" end\
end\
\
function OBJECT:push_updates()\
    PIXELBOX.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    self.symbols = api.createNDarray(2)\
    self.lines = api.create_blit_array(self.height)\
    self.pixels = api.createNDarray(1)\
    getmetatable(self.symbols).__tostring=function() return \"PixelBOX.SYMBOL_BUFFER\" end\
    setmetatable(self.lines,{__tostring=function() return \"PixelBOX.LINE_BUFFER\" end})\
    for y=1,self.height*3,3 do\
        local layer_1 = self.CANVAS[y]\
        local layer_2 = self.CANVAS[y+1]\
        local layer_3 = self.CANVAS[y+2]\
        for x=1,self.width*2,2 do\
            local block_color = {\
                layer_1[x],layer_1[x+1],\
                layer_2[x],layer_2[x+1],\
                layer_3[x],layer_3[x+1]\
            }\
            local B1 = layer_1[x]\
            local SCREEN_X = CEIL(x/2)\
            local SCREEN_Y = CEIL(y/3)\
            local LINES_Y = self.lines[SCREEN_Y]\
            local terminal_data = self.terminal_map[SCREEN_Y][SCREEN_X]\
            if (self.UPDATES[SCREEN_Y][SCREEN_X] or not self.prev_data) and (terminal_data and terminal_data.clear) then\
                local char,fg,bg = \" \",colors.black,B1\
                if not (block_color[2] == B1\
                    and block_color[3] == B1\
                    and block_color[4] == B1\
                    and block_color[5] == B1\
                    and block_color[6] == B1) then\
                    char,fg,bg = graphic.build_drawing_char(block_color)\
                    self.CHARS[y][x] = {symbol=char, background=graphic.to_blit[bg], fg=graphic.to_blit[fg]}\
                end\
                self.lines[SCREEN_Y] = {\
                    LINES_Y[1]..char,\
                    LINES_Y[2]..graphic.to_blit[fg],\
                    LINES_Y[3]..graphic.to_blit[bg]\
                }\
            elseif terminal_data and not terminal_data.clear then\
                self.lines[SCREEN_Y] = {\
                    LINES_Y[1]..terminal_data[1],\
                    LINES_Y[2]..graphic.to_blit[terminal_data[2]],\
                    LINES_Y[3]..graphic.to_blit[terminal_data[3]]\
                }\
            else\
                local prev_data = self.CHARS[y][x]\
                self.lines[SCREEN_Y] = {\
                    LINES_Y[1]..prev_data.symbol,\
                    LINES_Y[2]..prev_data.fg,\
                    LINES_Y[3]..prev_data.background\
                }\
            end\
            self.pixels[y][x]     = block_color[1]\
            self.pixels[y][x+1]   = block_color[2]\
            self.pixels[y+1][x]   = block_color[3]\
            self.pixels[y+1][x+1] = block_color[4]\
            self.pixels[y+2][x]   = block_color[5]\
            self.pixels[y+2][x+1] = block_color[5]\
        end\
    end\
    self.UPDATES = api.createNDarray(1)\
end\
\
function OBJECT:get_pixel(x,y)\
    PIXELBOX.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    EXPECT(1,x,\"number\")\
    EXPECT(2,y,\"number\")\
    assert(self.CANVAS[y] and self.CANVAS[y][x],\"Out of range\")\
    return self.CANVAS[y][x]\
end\
\
function OBJECT:clear(color)\
    PIXELBOX.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    EXPECT(1,color,\"number\")\
    PIXELBOX.RESTORE(self,color)\
end\
\
function OBJECT:draw()\
    PIXELBOX.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    if not self.lines then error(\"You must push_updates in order to draw\",2) end\
    for y,line in ipairs(self.lines) do\
        self.term.setCursorPos(1,y)\
        self.term.blit(\
            table.unpack(line)\
        )\
    end\
end\
\
function OBJECT:set_pixel(x,y,color,thiccness,base)\
    if not base then\
        PIXELBOX.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
        EXPECT(1,x,\"number\")\
        EXPECT(2,y,\"number\")\
        EXPECT(3,color,\"number\")\
        PIXELBOX.ASSERT(x>0 and x<=self.width*2,\"Out of range\")\
        PIXELBOX.ASSERT(y>0 and y<=self.height*3,\"Out of range\")\
        thiccness = thiccness or 1\
        local t_ratio = (thiccness-1)/2\
        self:set_box(\
            CEIL(x-t_ratio),\
            CEIL(y-t_ratio),\
            x+thiccness-1,y+thiccness-1,color,true\
        )\
    else\
        local RELATIVE_X = CEIL(x/2)\
        local RELATIVE_Y = CEIL(y/3)\
        self.UPDATES[RELATIVE_Y][RELATIVE_X] = true\
        self.CANVAS[y][x] = color\
    end\
end\
\
function OBJECT:set_pixel_raw(x,y,color)\
    local RELATIVE_X = CEIL(x/2)\
    local RELATIVE_Y = CEIL(y/3)\
    if not self.pixels or self.pixels[y][x] ~= color then\
        self.UPDATES[RELATIVE_Y][RELATIVE_X] = true\
    end\
    self.CANVAS[y][x] = color\
end\
\
function OBJECT:set_box(sx,sy,ex,ey,color,check)\
    if not check then\
        PIXELBOX.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
        EXPECT(1,sx,\"number\")\
        EXPECT(2,sy,\"number\")\
        EXPECT(3,ex,\"number\")\
        EXPECT(4,ey,\"number\")\
        EXPECT(5,color,\"number\")\
    end\
    for y=sy,ey do\
        for x=sx,ex do\
            if self:within(x,y) then\
                local RELATIVE_X = CEIL(x/2)\
                local RELATIVE_Y = CEIL(y/3)\
                self.UPDATES[RELATIVE_Y][RELATIVE_X] = true\
                self.CANVAS[y][x] = color\
            end\
        end\
    end\
end\
\
function PIXELBOX.CREATE_TERM(pixelbox)\
    local object = {}\
    pixelbox.terminal_map = api.createNDarray(1)\
    local map = pixelbox.terminal_map\
    pixelbox.show_clears        = false\
\
    local current_fg        = pixelbox.term.getTextColor()\
    local current_bg        = pixelbox.term.getBackgroundColor()\
    local cursor_x,cursor_y = pixelbox.term.getCursorPos()\
\
    local function create_line(w,y,first)\
        local line = {}\
        for i=1,w do\
            if not first then\
                if not map[y][i].clear then\
                    pixelbox.UPDATES[y][i] = true\
                end\
            end\
            line[i] = {\
                \" \",current_fg,current_bg,clear=not pixelbox.show_clears\
            }\
        end\
        return line\
    end\
\
    local function clear_object(object,first)\
        local w,h = pixelbox.term.getSize()\
        for y=1,h do\
            object[y] = create_line(w,y,first)\
        end\
    end\
\
    clear_object(map,true)\
\
    function object.blit(chars,fg,bg)\
        chars,fg,bg = chars:lower(),fg:lower(),bg:lower()\
        local len = #chars\
        if #bg == len and #fg == len then\
            for i=1,#chars do\
                local char  = chars:sub(i,i)\
                local fgbit = 2^tonumber(fg:sub(i,i),16)\
                local bgbit = 2^tonumber(bg:sub(i,i),16)\
                map[cursor_y][cursor_x+i-1] = {char,fgbit,bgbit,clear=false}\
            end\
        else\
            error(\"Arguments must be the same lenght\",2)\
        end\
    end\
\
    function object.write(chars)\
        for i=1,#tostring(chars) do\
            local char  = chars:sub(i,i)\
            map[cursor_y][cursor_x+i-1] = {char,current_fg,current_bg,clear=false}\
        end\
    end\
\
    function object.clear()\
        clear_object(map)\
    end\
\
    function object.getLine(y)\
        local char,bg,fg = \"\",\"\",\"\"\
        local w = pixelbox.term.getSize()\
        for x=1,w do\
            local point = map[y][x]\
            if not point.clear then\
                char = char .. point[1]\
                bg   = bg   .. point[2]\
                fg   = fg   .. point[3]\
            else\
                char = char .. \" \"\
                fg   = fg   .. graphic.to_blit[current_fg]\
                bg   = bg   .. graphic.to_blit[current_bg]\
            end\
        end\
        return char,bg,fg\
    end\
\
    function object.clearLine()\
        local w = pixelbox.term.getSize()\
        map[cursor_y] = create_line(w,cursor_y)\
    end\
\
    function object.scroll(y)\
        local w,h = pixelbox.term.getSize()\
        if y ~= 0 then\
            local temp = api.createNDarray(1)\
            clear_object(temp)\
            for cy=1,h do\
                if cy-y > h then break end\
                temp[cy-y] = map[cy]\
            end\
            pixelbox.terminal_map = temp\
            map = temp\
        end\
    end\
\
    function object.setBackgroundColor (bg)  current_bg = bg end\
    function object.setBackgroundColour(bg)  current_bg = bg end\
    function object.setTextColor (fg)        current_fg = fg end\
    function object.setTextColour(fg)        current_fg = fg end\
    function object.setCursorPos(x,y)        cursor_x,cursor_y = x,y end\
    function object.setCursorBlink(...)      pixelbox.term.setCursorBlink(...) end\
    function object.restoreCursor()          pixelbox.term.setCursorPos(cursor_x,cursor_y) end\
    function object.setPaletteColor (...)    pixelbox.term.setPaletteColor(...) end\
    function object.setPaletteColour(...)    pixelbox.term.setPaletteColor(...) end\
    function object.getBackgroundColor ()    return current_bg end\
    function object.getBackgroundColour()    return current_bg end\
    function object.getCursorBlink()         return pixelbox.term.getCursorBlink() end\
    function object.getCursorPos()           return cursor_x,cursor_y end\
    function object.getPaletteColor (...)    return pixelbox.term.getPaletteColor(...) end\
    function object.getPaletteColour(...)    return pixelbox.term.getPaletteColor(...) end\
    function object.getSize(...)             return pixelbox.term.getSize(...) end\
    function object.getTextColor()           return current_fg end\
    function object.getTextColour()          return current_fg end\
    function object.isColor()                return pixelbox.term.isColor() end\
    function object.isColour()               return pixelbox.term.isColor() end\
\
    object.drawPixels      = pixelbox.term.drawPixels\
    object.getVisible      = pixelbox.term.getVisible\
    object.getPixel        = pixelbox.term.getPixel\
    object.getPixels       = pixelbox.term.getPixels\
    object.getPosition     = pixelbox.term.getPosition\
    object.isVisible       = pixelbox.term.isVisible\
    object.redraw          = pixelbox.term.redraw\
    object.reposition      = pixelbox.term.reposition\
    object.setVisible      = pixelbox.term.setVisible\
    object.showMouse       = pixelbox.term.showMouse\
\
    function object.clear_visibility(state) pixelbox.show_clears = state end\
\
    return object\
end\
\
function PIXELBOX.ASSERT(condition,message)\
    if not condition then error(message,3) end\
    return condition\
end\
\
function OBJECT:resize(w,h)\
    self.width,self.height = w,h\
    PIXELBOX.RESTORE(self,colors.black)\
    self.emu = PIXELBOX.CREATE_TERM(self)\
end\
\
function OBJECT:get()\
    return self.term\
end\
\
function PIXELBOX.new(terminal,bg)\
    EXPECT(1,terminal,\"table\")\
    EXPECT(2,bg,\"number\",\"nil\")\
    local bg = bg or terminal.getBackgroundColor() or colors.black\
    local BOX = {}\
    local w,h = terminal.getSize()\
    BOX.term = terminal\
    setmetatable(BOX,{__index = OBJECT})\
    BOX.width  = w\
    BOX.height = h\
    PIXELBOX.RESTORE(BOX,bg)\
    BOX.emu = PIXELBOX.CREATE_TERM(BOX)\
    return BOX\
end\
\
function api.createNDarray(n, tbl)\
    tbl = tbl or {}\
    if n == 0 then return tbl end\
    setmetatable(tbl, {__index = function(t, k)\
        local new = api.createNDarray(n - 1)\
        t[k] = new\
        return new\
    end})\
    return tbl\
end\
function api.create_blit_array(count)\
    local out = {}\
    for i=1,count do\
        out[i] = {\"\",\"\",\"\"}\
    end\
    return out\
end\
function api.create_byte_array(count)\
    local out = {}\
    for i=1,count do\
        out[i] = \"\"\
    end\
    return out\
end\
function api.merge_tables(...)\
    local out = {}\
    local n = 1\
    for k,v in pairs({...}) do\
        for _k,_v in pairs(v) do out[n] = _v n=n+1 end\
    end\
    return out\
end\
function api.get_closest_color(palette,c)\
    local result = {}\
    local n = 0\
    for k,v in pairs(palette) do\
        n=n+1\
        result[n] = {\
            dist=SQRT(\
                (v[1]-c[1])^2 +\
                (v[2]-c[2])^2 +\
                (v[3]-c[3])^2\
            ),  color=k\
        }\
    end\
    table.sort(result,function(a,b) return a.dist < b.dist end)\
    return result[1].color\
end\
function api.convert_color_255(r,g,b)\
    return r*255,g*255,b*255\
end\
function api.hex_to_palette(hex)\
    local r = (FLOOR(hex/0x10000)%256)/255\
    local g = (FLOOR(hex/0x100)%256)/255\
    local b = (hex%256)/255\
    return r,g,b\
end\
function api.update_palette(updater,palette)\
    for k,v in pairs(palette) do\
        updater(k,table.unpack(v))\
    end\
end\
function api.update(box)\
    box:push_updates()\
    box:draw()\
end\
\
local BUILDS = {}\
local count_sort = function(a,b) return a.count > b.count end\
function graphic.build_drawing_char(arr)\
    local cols,fin,char,visited = {},{},{},{}\
    local entries = 0\
    local build_id = \"\"\
    for k = 1, 6 do\
        build_id = build_id .. (\"%x\"):format(graphic.logify[arr[k]])\
        if cols[arr[k]] == nil then\
            entries = entries + 1\
            cols[arr[k]] = {count=1,c=arr[k]}\
        else cols[arr[k]] = {count=cols[arr[k]].count+1,c=cols[arr[k]].c}\
        end\
    end\
    if not BUILDS[build_id] then\
        for k,v in pairs(cols) do\
            if not visited[v.c] then\
                visited[v.c] = true\
                if entries == 1 then t_insert(fin,v) end\
                t_insert(fin,v)\
            end\
        end\
        t_sort(fin, count_sort)\
        local swap = true\
        for k=1,6 do\
            if arr[k] == fin[1].c then char[k] = 1\
            elseif arr[k] == fin[2].c then char[k] = 0\
            else\
                swap = not swap\
                char[k] = swap and 1 or 0\
            end\
        end\
        if char[6] == 1 then for i = 1, 5 do char[i] = 1-char[i] end end\
        local n = 128\
        for i = 0, 4 do n = n + char[i+1]*2^i end\
        if char[6] == 1 then BUILDS[build_id] = {s_char(n), fin[2].c, fin[1].c}\
        else BUILDS[build_id] = {s_char(n), fin[1].c, fin[2].c}\
        end\
    end\
    return t_unpack(BUILDS[build_id])\
end\
\
return PIXELBOX",
  [ "common/math_util" ] = "local mat = require(\"lib.matrix\")\
\
local maths = {matrice={}}\
local matrice = maths.matrice\
\
return maths",
  [ "modules/mouse" ] = "local mouse = {}\
\
return function(BUS)\
    function mouse.getCursor() end\
    function mouse.getPosition()\
        return BUS.mouse.last_x*2, BUS.mouse.last_y*3\
    end\
    function mouse.getRelativeMode()\
        return BUS.mouse.relative_mode\
    end\
    function mouse.getX() return BUS.mouse.last_x*2 end\
    function mouse.getY() return BUS.mouse.last_y*3 end\
    function mouse.isCursorSupported() return false end\
    function mouse.isDown(...)\
        local btn_list = {...}\
        for k,key in pairs(btn_list) do\
            local held = BUS.mouse.held[key]\
            if not held then return false end\
        end\
        return true\
    end\
    function mouse.isGrabbed() return BUS.mouse.grabbed end\
    function mouse.isVisible() return BUS.mouse.visible end\
    function mouse.newCursor() return nil end\
    function mouse.setCursor(cursor) end\
    function mouse.setGrabbed(grab) BUS.mouse.grabbed = grab end\
    function mouse.setPosition(x,y)\
        BUS.mouse.last_x = x\
        BUS.mouse.last_y = y\
    end\
    function mouse.setRelativeMode(enable)\
        BUS.mouse.relative_mode = enable\
    end\
    function mouse.setVisible(visible) BUS.mouse.visible = visible end\
    function mouse.setX(x) BUS.mouse.last_x = x end\
    function mouse.setY(y) BUS.mouse.last_y = y end\
    return mouse\
end",
  LICENSE = "MIT License\
\
Copyright (c) 2022 Oliver Caha\
\
Permission is hereby granted, free of charge, to any person obtaining a copy\
of this software and associated documentation files (the \"Software\"), to deal\
in the Software without restriction, including without limitation the rights\
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\
copies of the Software, and to permit persons to whom the Software is\
furnished to do so, subject to the following conditions:\
\
The above copyright notice and this permission notice shall be included in all\
copies or substantial portions of the Software.\
\
THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\
SOFTWARE.\
",
  [ "core/threads/tupd_thread" ] = "return {make=function(ENV,BUS)\
    return coroutine.create(function()\
        while true do\
            local ev = table.pack(os.pullEventRaw())\
            local has_thread_error_handle = type(ENV.love.threaderror) == \"function\"\
            for k,v in pairs(BUS.thread.coro) do\
                if not v.filter or v.filter == ev[1] and v.c and v.started then\
                    local ok,ret = coroutine.resume(v.c,table.unpack(ev,1,ev.n))\
                    local dead = coroutine.status(v.c) == \"dead\"\
                    if ok then BUS.thread.coro[k].filter = ret end\
                    if not ok or dead then BUS.thread.coro[k] = nil end\
                    if not ok and dead then\
                        v.error = ret\
                        if has_thread_error_handle then\
                            ENV.love.threaderror(v.object,ret)\
                        end\
                    end\
                end\
            end\
        end\
    end)\
end}",
  main = "local pixelbox = require(\"lib.pixelbox\")\
\
local cmgr     = require(\"core.cmgr\")\
local bus      = require(\"core.bus\")\
local handlers = require(\"core.handlers\")\
\
local update_thread = require(\"core.threads.update_thread\")\
local event_thread  = require(\"core.threads.event_thread\")\
local resize_thread = require(\"core.threads.resize_thread\")\
local key_thread    = require(\"core.threads.key_thread\")\
local tudp_thread   = require(\"core.threads.tupd_thread\")\
\
return function(ENV,libdir,...)\
    local args = table.pack(...)\
    local BUS = bus.register_bus(ENV)\
    handlers.attach(ENV)\
    BUS.instance.libdir = libdir\
\
    local function start_execution(program,path,terminal,parent,ox,oy)\
\
        local w,h = terminal.getSize()\
        local ok = pcall(function()\
            BUS.graphics.monitor = peripheral.getName(parent)\
        end)\
        if not ok then BUS.graphics.monitor = \"term_object\" end\
        BUS.graphics.w,BUS.graphics.h = w*2,h*3\
        BUS.graphics.display = pixelbox.new(terminal)\
        BUS.graphics.display_source = terminal\
        BUS.graphics.event_offset = vector.new(ox,oy)\
        BUS.clr_instance.update_palette(terminal)\
        BUS.instance.gamedir = fs.getDir(path) or \"\"\
        for x,y in ENV.utils.table.map_iterator(BUS.graphics.w,BUS.graphics.h) do\
            BUS.graphics.buffer[y][x] = {0,0,0,1}\
        end\
        if type(program[1]) == \"function\" then\
            local old_path = package.path\
            ENV.package.path = string.format(\
                \"/%s/modules/required/?.lua;/%s/?.lua;/rom/modules/main/?.lua\",\
                libdir,BUS.instance.gamedir\
            )\
            setfenv(program[1],ENV)(table.unpack(args,1,args.n))\
            ENV.package.path = old_path\
        else\
            error(program[2],0)\
        end\
\
        local main   = update_thread.make(ENV,BUS,args)\
        local event  = event_thread .make(ENV,BUS,args)\
        local resize = resize_thread.make(ENV,BUS,parent)\
        local key_h  = key_thread   .make(ENV,BUS)\
        local tudp   = tudp_thread  .make(ENV,BUS)\
\
        local ok,err = cmgr.start(BUS,function()\
            return BUS.running\
        end,{},main,event,resize,key_h,tudp)\
\
        if not ok and ENV.love.errorhandler then\
            if ENV.love.errorhandler(err) then\
                error(err,2)\
            end\
        elseif not ok then\
            error(err,2)\
        end\
    end\
\
    BUS.object.font = require(\"core.objects.font\").add(BUS)\
\
    BUS.graphics.stack.default.font = BUS.object.font.new(\"resources/font.bdf\",true)\
\
    BUS.graphics.stack[BUS.graphics.stack.current_pos] = \
        ENV.utils.table.deepcopy(BUS.graphics.stack.default)\
\
    ENV.love.timer    = require(\"modules.timer\")   (BUS)\
    ENV.love.event    = require(\"modules.event\")   (BUS)\
    ENV.love.graphics = require(\"modules.graphics\")(BUS)\
    ENV.love.keyboard = require(\"modules.keyboard\")(BUS)\
    ENV.love.thread   = require(\"modules.thread\")  (BUS)\
    ENV.love.window   = require(\"modules.window\")  (BUS)\
    ENV.love.mouse    = require(\"modules.mouse\")   (BUS)\
    ENV.love.cc       = require(\"modules.cc\")      (BUS)\
\
    require(\"modules.love\")(BUS)\
\
    return start_execution\
end",
  [ "core/default_run" ] = "local function build_run(love,args)\
    if not love.run then\
        function love.run()\
            if love.load then love.load(table.unpack(args,1,args.n)) end\
            if love.timer then love.timer.step() end\
            local dt = 0\
            return function()\
                if love.event then\
                    love.event.pump()\
                    for name, a,b,c,d,e,f in love.event.poll() do\
                        if name == \"quit\" then\
                            if not love.quit or not love.quit() then\
                                return a or 0\
                            end\
                        end\
                        love.handlers[name](a,b,c,d,e,f)\
                    end\
                end\
                if love.timer then dt = love.timer.step() end\
                if love.update then love.update(dt) end\
                if love.graphics and love.graphics.isActive() then\
                    love.graphics.origin()\
                    love.graphics.clear(love.graphics.getBackgroundColor())\
                    if love.draw then love.draw() end\
                    love.graphics.present()\
                end\
                if love.timer then love.timer.sleep(0.001) end\
            end\
        end\
    end\
end\
\
return build_run",
  [ "common/draw_util" ] = "local draw = {}\
\
function draw.respect_newlines(term,text)\
    local sx,sy = term.getCursorPos()\
    local lines = 0\
    for c in text:gmatch(\"([^\\n]+)\") do\
        lines = lines + 1\
        term.setCursorPos(sx,sy)\
        term.write(c)\
        sy = sy + 1\
    end\
    return lines\
end\
\
return draw",
  [ "common/parser_util" ] = "local parse = {}\
\
function parse.stack_trace(trace)\
    local res = \"\"\
    for c in trace:gmatch(\"(%[C%]:.-)\\n\") do\
        res = res .. c .. \"\\n\"\
    end\
    return res\
end\
\
return parse",
  [ "core/callbacks/keypressed" ] = "return {ev=\"key\",run=function(BUS,caller,ev,key_code,is_held)\
    local code = keys.getName(key_code)\
    if not is_held or BUS.keyboard.key_reapeat then\
        BUS.events[#BUS.events+1] = {\"keypressed\",code,code,is_held}\
        if type(caller.keypressed) == \"function\" then\
            caller.keypressed(code,code,is_held)\
        end\
    end\
end}",
  [ "core/loaders/font/bdf" ] = "local read_font = require(\"lib.readBDFFont\")\
\
local tbl = require(\"common.table_util\")\
\
return {read=function(path)\
    local font_data = tbl.createNDarray(2)\
\
    local file = fs.open(path,\"r\")\
    local data = file.readAll()\
    file.close()\
\
    local font = read_font(data)\
\
    for k,v in pairs(font.chars) do\
        local size = v.bounds\
        local map = v.bitmap\
        for x,y in tbl.map_iterator(size.width,size.height) do\
            if type(map[y][x]) ~= \"nil\" then\
                font_data[k][y][x] = map[y][x]\
            else font_data[k][y][x] = false end\
        end\
        font_data[k].bounds = v.bounds\
    end\
\
    font_data.meta = {\
        ascent = font.ascent,\
        descent = font.descent,\
        filter={\
            min = \"nearest\",\
            mag = \"nearest\",\
            anisotropy = 0\
        },\
        size={\
            height=font.size.px+font.descent\
        },\
        line_height=1,\
        bounds = font.bounds\
    }\
\
    return font_data\
end}",
  [ "core/callbacks/wheelmoved" ] = "local mouse_moved = require(\"core.callbacks.mousemoved\")\
\
return {ev=\"mouse_scroll\",run=function(BUS,caller,ev,dir,x,y)\
    local k_list = BUS.keyboard.pressed_keys\
\
    mouse_moved:check_change(BUS,caller,x,y)\
\
    local shift_held = k_list[keys.leftShift] or k_list[keys.rightShift]\
\
    BUS.events[#BUS.events+1] = {\"wheelmoved\",\
        shift_held and 0-dir or 0,\
        shift_held and 0     or 0-dir\
    }\
\
    if type(caller.wheelmoved) == \"function\" then\
        caller.wheelmoved(\
            shift_held and 0-dir or 0,\
            shift_held and 0     or 0-dir\
        )\
    end\
end}",
  [ "core/object" ] = "local function make_methods(child)\
    return setmetatable({\
        __build=function(obj)\
            child = obj \
            return obj\
        end,\
        release = function()\
            child.stored_in[child.under] = nil\
        end,\
        type = function() return child.obj_type end,\
        typeOf = function(this,tp) return tp == child.obj_type end\
    },{__tostring=function() return \"object\" end})\
end\
\
return {new=function(child)\
    return setmetatable(child,{__index=make_methods(child)})\
end}",
  [ "core/graphics/dither" ] = "return {build=function(BUS)\
    local graphics = BUS.graphics\
    local buff = graphics.buffer\
\
    local CEIL = math.ceil\
    local CONST_1 = 7/16\
    local CONST_2 = 3/16\
    local CONST_3 = 5/16\
    local CONST_4 = 1/16\
\
    local function sub_color(c1,c2)\
        return {\
            c1[1] - c2[1],\
            c1[2] - c2[2],\
            c1[3] - c2[3],\
        }\
    end\
\
    return {dither=function()\
        local factor = BUS.cc.dither_factor\
        for y=1,graphics.h do\
            for x=1,graphics.w do\
\
                local b_cent = buff[y][x]\
                local old = {\
                    b_cent[1],b_cent[2],b_cent[3]\
                }\
                buff[y][x] = {\
                    CEIL(factor*b_cent[1]) * (1/factor),\
                    CEIL(factor*b_cent[2]) * (1/factor),\
                    CEIL(factor*b_cent[3]) * (1/factor)\
                }\
\
                local err = sub_color(old,b_cent)\
\
                local b_right = buff[y][x+1]\
                if b_right then buff[y][x+1] = {\
                    b_right[1] + err[1] * CONST_1,\
                    b_right[2] + err[2] * CONST_1,\
                    b_right[3] + err[3] * CONST_1\
                } end\
\
                local b_topleft = buff[y+1][x-1]\
                if b_topleft then buff[y+1][x-1] = {\
                    b_topleft[1] + err[1] * CONST_2,\
                    b_topleft[2] + err[2] * CONST_2,\
                    b_topleft[3] + err[3] * CONST_2\
                } end\
\
                local b_top = buff[y+1][x]\
                if b_top then buff[y+1][x] = {\
                    b_top[1] + err[1] * CONST_3,\
                    b_top[2] + err[2] * CONST_3,\
                    b_top[3] + err[3] * CONST_3\
                } end\
\
                local b_topright = buff[y+1][x+1]\
                if b_topright then buff[y+1][x+1] = {\
                    b_topright[1] + err[1] * CONST_4,\
                    b_topright[2] + err[2] * CONST_4,\
                    b_topright[3] + err[3] * CONST_4\
                } end\
            end\
        end\
    end}\
end}",
  [ "core/graphics/nearest_neighbour" ] = "",
  [ "common/string_util" ] = "local strings = {}\
\
local expect = require(\"cc.expect\").expect\
\
function strings.wrap(str,lenght,nnl)\
    expect(1,str,\"string\")\
    expect(2,lenght,\"number\")\
    local words,out,outstr = {},{},\"\"\
    for c in str:gmatch(\"[%w%p%a%d]+%s?\") do table.insert(words,c) end\
    if lenght == 0 then return \"\" end\
    while outstr < str and not (#words == 0) do\
        local line = \"\"\
        while words ~= 0 do\
            local word = words[1]\
            if not word then break end\
            if #word > lenght then\
                local espaces = word:match(\"% +$\") or \"\"\
                if not ((#word-#espaces) <= lenght) then\
                    local cur,rest = word:sub(1,lenght),word:sub(lenght+1)\
                    if #(line..cur) > lenght then words[1] = strings.wrap(cur..rest,lenght,true) break end\
                    line,words[1],word = line..cur,rest,rest\
                else word = word:sub(1,#word-(#word - lenght)) end\
            end\
            if #(line .. word) <= lenght then\
                line = line .. word\
                table.remove(words,1)\
            else break end\
        end\
        table.insert(out,line)\
    end\
    return table.concat(out,nnl and \"\" or \"\\n\")\
end\
\
function strings.cut_parts(str,part_size)\
    expect(1,str,\"string\")\
    expect(2,part_size,\"number\")\
    local parts = {}\
    for i = 1, #str, part_size do\
        parts[#parts+1] = str:sub(i, i+part_size-1)\
    end\
    return parts\
end\
\
function strings.ensure_size(str,width)\
    expect(1,str,\"string\")\
    expect(2,width,\"number\")\
    local f_line = str:sub(1, width)\
    if #f_line < width then\
        f_line = f_line .. (\" \"):rep(width-#f_line)\
    end\
    return f_line\
end\
\
function strings.newline(tbl)\
    expect(1,tbl,\"table\")\
    return table.concat(tbl,\"\\n\")\
end\
\
function strings.wrap_lines(str,lenght)\
    local result_str = \"\"\
    for c in str:gmatch(\"([^\\n]+)\") do\
        result_str = result_str .. strings.wrap(c,lenght) .. \"\\n\"\
    end\
    return result_str\
end\
\
function strings.ensure_line_size(str,width)\
    local result_str = \"\"\
    for c in str:gmatch(\"([^\\n]+)\") do\
        result_str = result_str .. strings.ensure_size(c,width) .. \"\\n\"\
    end\
    return result_str\
end\
\
return strings",
  [ "core/callbacks/keyreleased" ] = "return {ev=\"key_up\",run=function(BUS,caller,ev,key_code)\
    local code = keys.getName(key_code)\
    BUS.events[#BUS.events+1] = {\"keyreleased\",code,code}\
    if type(caller.keyreleased) == \"function\" then\
        caller.keyreleased(code,code)\
    end\
end}",
  [ "core/threads/event_thread" ] = "local generic = require(\"common.generic\")\
\
local keypressed  = require(\"core.callbacks.keypressed\")\
local keyreleased = require(\"core.callbacks.keyreleased\")\
local textinput   = require(\"core.callbacks.textinput\")\
\
local mousemoved    = require(\"core.callbacks.mousemoved\")\
local mousepressed  = require(\"core.callbacks.mousepressed\")\
local mousereleased = require(\"core.callbacks.mousereleased\")\
local wheelmoved    = require(\"core.callbacks.wheelmoved\")\
\
local function unpack_ev(ev)\
    return table.unpack(ev,1,ev.n)\
end\
\
return {make=function(ENV,BUS,args)\
    return coroutine.create(function()\
        while true do\
            local ev = table.pack(os.pullEventRaw())\
            if not BUS.window.active and ev[1] == \"mouse_move\" and ev[3] ~= nil then\
                BUS.window.active = true\
            end\
\
            if ev[1] == \"monitor_click\" and ev[2] == BUS.graphics.monitor then\
                ev[1] = \"mouse_click\"\
                ev[2] = 1\
            end\
            if generic.events_with_cords[ev[1]] and not (ev[1] == \"mouse_move\" and ev[3] == nil) then\
                ev[3] = ev[3] - BUS.graphics.event_offset.x\
                ev[4] = ev[4] - BUS.graphics.event_offset.y\
            elseif ev[1] == \"mouse_move\" and ev[3] == nil and BUS.window.allow_sleep then\
                BUS.window.active = false\
            end\
\
            if ev[1] == keypressed.ev then keypressed.run(BUS,ENV.love,unpack_ev(ev)) end\
            if ev[1] == keyreleased.ev then keyreleased.run(BUS,ENV.love,unpack_ev(ev)) end\
            if ev[1] == textinput.ev then textinput.run(BUS,ENV.love,unpack_ev(ev)) end\
\
            if ev[1] == mousemoved.ev then mousemoved.run(BUS,ENV.love,unpack_ev(ev)) end\
            if ev[1] == mousepressed.ev then mousepressed.run(BUS,ENV.love,unpack_ev(ev)) end\
            if ev[1] == mousereleased.ev then mousereleased.run(BUS,ENV.love,unpack_ev(ev)) end\
            if ev[1] == wheelmoved.ev then wheelmoved.run(BUS,ENV.love,unpack_ev(ev)) end\
\
            if ev[1] == \"mouse_drag\" then mousemoved:check_change(BUS,ENV.love,ev[3],ev[4]) end\
        end\
    end)\
end}",
}
local e local t local function a(o)local i=files[o]local n=load(i)return
setfenv(n,t())end function e(s)if s=="cc.expect"then return
require("cc.expect")end if s=="cc.pretty"then return require("cc.pretty")end
local h=a(s:gsub("%.","/"))return h()end function t()local
r={fs={exists=function(d)return not not files[d]end,isDir=function(l)return not
files[l]end,open=function(u,c)if c=="r"then local
m=files[u]return{readAll=function()return m end,close=function()end}else return
fs.open(u,c)end end,list=function(f)local w={}local y={}for p,v in
pairs(files)do local b=p:gsub("^"..f.."/","")if p:find("^"..f.."/")then
w[(b.."/"):match("^([^/]*)/")]=true end end for g,k in pairs(w)do
table.insert(y,g)end return y end}}for q,j in pairs(fs)do if not r.fs[q]then
r.fs[q]=j end end r=setmetatable(r,{__index=_ENV})r.require=e r.ORIGINAL=_ENV
return r end local x=a("init")
local e={...}local t=window.create(term.current(),1,1,term.getSize())local
a,o=pcall(x)if not a then error("LoveCC could not be loaded \n"..o,0)end local
i,n,s=o.util.window.get_parent_info(t)local
h="https://api.adviceslip.com/advice"local function r(d,l)local
u=debug.traceback()local c=os.startTimer(0.1)local m={i.getSize()}while true do
local f=table.pack(os.pullEvent())if f[1]=="timer"and c==f[2]then
t.setVisible(false)c=os.startTimer(0.1)local w,y=i.getSize()if m[1]~=w or
m[2]~=y then t.reposition(1,1,w,y)end
t.setBackgroundColor(colors.blue)t.clear()t.setCursorPos(3,3)t.setBackgroundColor(colors.red)t.write(o.util.string.ensure_size("Error",w-4))t.setBackgroundColor(colors.blue)if
l then t.setBackgroundColor(colors.red)end t.setCursorPos(3,5)local
p=o.util.draw.respect_newlines(t,o.util.string.wrap(d,w-4))t.setBackgroundColor(colors.gray)t.setCursorPos(3,6+p)o.util.draw.respect_newlines(t,o.util.string.ensure_line_size(o.util.string.wrap_lines(o.util.parse.stack_trace(u),w-4),w-4))t.setBackgroundColor(colors.blue)t.setCursorPos(3,y-1)t.write("Press \"C\" to cry.")t.setVisible(true)elseif
f[1]=="key"and f[2]==keys.c then
i.setBackgroundColor(colors.black)i.clear()i.setCursorPos(1,1)break end end end
local function v()local b=http.get(h)local g="Try out GuiH !"if b then
g=textutils.unserializeJSON(b.readAll()).slip.advice end local
k=os.startTimer(0.1)local q={i.getSize()}while true do local
j=table.pack(os.pullEvent())if j[1]=="timer"and k==j[2]then
t.setVisible(false)t.setBackgroundColor(colors.blue)t.clear()k=os.startTimer(0.1)local
z,E=i.getSize()if q[1]~=z or q[2]~=E then t.reposition(1,1,z,E)end
t.setBackgroundColor(colors.red)t.setCursorPos(3,3)local
T=o.util.draw.respect_newlines(t,o.util.string.ensure_line_size(o.util.string.wrap("No game.",z-4),z-4))t.setBackgroundColor(colors.black)t.setCursorPos(3,4+T)o.util.draw.respect_newlines(t,o.util.string.ensure_line_size(o.util.string.wrap("\""..g.."\"",z-4),z-4))t.setBackgroundColor(colors.blue)t.setCursorPos(3,E-1)o.util.draw.respect_newlines(t,o.util.string.wrap("Press enter to exit",z-4))t.setVisible(true)elseif
j[1]=="key"and j[2]==keys.enter then
i.setBackgroundColor(colors.black)i.clear()i.setCursorPos(1,1)break end end end
if not o.init_ok then r("Internal error: "..tostring(o.env),true)end local
A=true local a,O=pcall(function()if not next(e)then v()A=true elseif not
fs.exists(e[1])or not fs.isDir(e[1])then
r("Loading error: folder does not exist")A=true elseif fs.exists(e[1])and not
fs.isDir(e[1])then r("Loading error: must be ran on a folder")A=true elseif
fs.exists(e[1])and fs.isDir(e[1])then local I=fs.combine(e[1],"main.lua")if
fs.exists(I)then local N=fs.open(I,"r")local S=N.readAll()N.close()local
a,H=pcall(o.env,{loadfile(I)},I,t,i,n,s)if not a then
r("Runtime error: "..tostring(H))end else
r("Loading error: No code to run\nmake sure you have a main.lua file on the top level of the folder")end
else A=false end end)if not a and not A then r("Runtime error: "..O)elseif not
a then
i.setBackgroundColor(colors.black)i.clear()i.setCursorPos(1,1)end
