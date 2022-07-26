--[[
The MIT License (MIT)
Copyright © 2022 Oliver Caha (9551Dev)
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local files={
  [ "presets/tex/checker" ] = "--* builds a checkerboard texture with any amount of colors\
\
local api = require(\"api\")\
local graphic = require(\"graphic_handle\")\
\
return function(...)\
    local out = api.tables.createNDarray(2,{\
        offset = {5, 13, 11, 4}\
    })\
    local cols = {...}\
    local y = 1\
    for k,v in pairs(cols) do\
        local colors_collumn = {}\
        for i=1,table.getn(cols) do\
            local index = ((i+y)-2)%table.getn(cols)+1\
            colors_collumn[i] = cols[index]\
        end\
        for k,v in pairs(colors_collumn) do\
            out[k+4][y+8] = {s=\" \",t=\"f\",b=graphic.code.to_blit[v]}\
        end\
        y=y+1\
    end\
    return graphic.load_texture(out)\
end",
  [ "a-tools/gui_object" ] = "--[[\
    * this file is used to build the gui object itself\
    * when you do gui.new this function gets ran\
    * and returns a table with all the needed functions\
    * and values for your GUI to function\
]]\
\
--* loads the required modules\
local objects = require(\"object_loader\")\
local graphic = require(\"graphic_handle\")\
local update = require(\"a-tools.update\")\
local api = require(\"api\")\
\
_ENV = _ENV.ORIGINAL\
\
local function create_gui_object(term_object,orig,log,event_offset_x,event_offset_y)\
    local gui_objects = {}\
    --* checks if the term object is terminal or an monitor\
    --* uses pcall cause peripheral.getType(term) errors\
    local type = \"term_object\"\
    local deepest = orig\
    local function calibrate(gui_object)\
        event_offset_x,event_offset_y = 0,0\
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
        if gui_object then\
            gui_object.event_offset_x = event_offset_x\
            gui_object.event_offset_y = event_offset_y\
        end\
    end\
    if not event_offset_x or not event_offset_y then\
        calibrate()\
    end\
    pcall(function()\
        type = peripheral.getType(deepest)\
    end)\
    for k,v in pairs(objects.types) do gui_objects[v] = {} end\
\
    --* creates base of the gui object\
    local w,h = term_object.getSize()\
    local gui = {\
        term_object=term_object,\
        term=term_object,\
        gui=gui_objects,\
        update=update,\
        visible=true,\
        id=api.uuid4(),\
        task_schedule={},\
        update_delay=0.05,\
        held_keys={},\
        log=log,\
        task_routine={},\
        paused_task_routine={},\
        w=w,h=h,\
        width=w,height=h,\
        event_listeners={},\
        paused_listeners={},\
        background=term_object.getBackgroundColor(),\
        cls=false,\
        key={},\
        texture_cache={},\
        debug=false,\
        event_offset_x=event_offset_x,\
        event_offset_y=event_offset_y,\
    }\
\
    gui.inherit = function(from, group)\
        gui.api          = from.api\
        gui.preset       = from.preset\
        gui.async        = from.async\
        gui.schedule     = from.schedule\
        gui.add_listener = from.add_listener\
        gui.debug        = from.debug\
        gui.parent       = group\
    end\
\
    gui.elements = gui.gui\
\
    gui.calibrate = function()\
        calibrate(gui)\
    end\
    gui.getSize = function()\
        return gui.w,gui.h\
    end\
\
    log(\"set up updater\",log.update)\
\
    --* attaches a-tools/update.lua to the gui object\
    --* that function is used for low level updating\
    local function updater(timeout,visible,is_child,data,block_logic,block_graphic)\
        return update(gui,timeout,visible,is_child,data,block_logic,block_graphic)\
    end\
\
    local err\
    local running = false\
\
    --* a function used for adding new things to\
    --* the gui objects task queue\
    gui.schedule=function(fnc,t,errflag,debug)\
        local task_id = api.uuid4()\
        if debug or gui.debug then log(\"created new thread: \"..tostring(task_id), log.info) end\
        local errupvalue = {}\
        local routine = {c=coroutine.create(function()\
            --* wraps function into pcall to catch errors\
            local ok,erro = pcall(function()\
                if t then api.precise_sleep(t) end\
                fnc(gui,gui.term_object)\
            end)\
            if not ok then\
                if errflag == true then err = erro end\
                errupvalue.err = erro\
                if debug or gui.debug then\
                    log(\"error in thread: \"..tostring(task_id)..\"\\n\"..tostring(erro),log.error)\
                    log:dump()\
                end\
            end\
        end),dbug=debug}\
        gui.task_routine[task_id] = routine\
        local function step(...)\
            local task = gui.task_routine[task_id] or gui.paused_task_routine[task_id]\
            if task then\
                local ok,err = coroutine.resume(task.c,...)\
                if not ok then\
                    errupvalue.err = err\
                    if debug or gui.debug then\
                        log(\"task \"..tostring(task_id)..\" error: \"..tostring(err),log.error)\
                        log:dump()\
                    end\
                end\
                return true,ok,err\
            else\
                if debug or gui.debug then\
                    log(\"task \"..tostring(task_id)..\" not found\",log.error)\
                    log:dump()\
                end\
                return false\
            end\
        end\
        return setmetatable(routine,{__index={\
            kill=function()\
                gui.task_routine[task_id] = nil\
                gui.paused_task_routine[task_id] = nil\
                if debug or gui.debug then\
                    log(\"killed task: \"..tostring(task_id), log.info)\
                    log:dump()\
                end\
                return true\
            end,\
            alive=function()\
                local task = gui.task_routine[task_id] or gui.paused_task_routine[task_id]\
                if not task then return false end\
                return coroutine.status(task.c) ~= \"dead\"\
            end,\
            step=step,\
            update=step,\
            pause=function()\
                local task = gui.task_routine[task_id] or gui.paused_task_routine[task_id]\
                if task then\
                    gui.paused_task_routine[task_id] = task\
                    gui.task_routine[task_id] = nil\
                    if debug or gui.debug then\
                        log(\"paused task: \"..tostring(task_id), log.info)\
                        log:dump()\
                    end\
                    return true\
                else\
                    if debug or gui.debug then\
                        log(\"task \"..tostring(task_id)..\" not found\",log.error)\
                        log:dump()\
                    end\
                    return false\
                end\
            end,\
            resume=function()\
                local task = gui.paused_task_routine[task_id] or gui.task_routine[task_id]\
                if task then\
                    gui.task_routine[task_id] = task\
                    gui.paused_task_routine[task_id] = nil\
                    if debug or gui.debug then\
                        log(\"resumed task: \"..tostring(task_id), log.info)\
                        log:dump()\
                    end\
                    return true\
                else\
                    if debug or gui.debug then\
                        log(\"task \"..tostring(task_id)..\" not found\",log.error)\
                        log:dump()\
                    end\
                    return false\
                end\
            end,\
            get_error=function()\
                return errupvalue.err\
            end,\
            set_running=function(bool,debug)\
                local task = gui.task_routine[task_id] or gui.paused_task_routine[task_id]\
                local running = gui.task_routine[task_id] ~= nil\
                if task then\
                    if running and bool then return true end\
                    if not running and not bool then return true end\
                    if running and not bool then\
                        gui.paused_task_routine[task_id] = task\
                        gui.task_routine[task_id] = nil\
                        if debug or gui.debug then\
                            log(\"paused task: \"..tostring(task_id), log.info)\
                            log:dump()\
                        end\
                        return true\
                    end\
                    if not running and bool then\
                        gui.task_routine[task_id] = task\
                        gui.paused_task_routine[task_id] = nil\
                        if debug or gui.debug then\
                            log(\"resumed task: \"..tostring(task_id), log.info)\
                            log:dump()\
                        end\
                        return true\
                    end\
                end\
            end\
        },__tostring=function()\
            return \"GuiH.SCHEDULED_THREAD.\"..task_id\
        end})\
    end\
\
    gui.async = gui.schedule\
\
    --* used for creation of new event listeners\
    gui.add_listener = function(_filter,f,name,debug)\
        if not _G.type(f) == \"function\" then return end\
\
        --* if no event filter is present use an empty one\
        if not (_G.type(_filter) == \"table\" or _G.type(_filter) == \"string\") then _filter = {} end\
        local id = name or api.uuid4()\
        local listener = {filter=_filter,code=f}\
        gui.event_listeners[id] = listener\
        if debug or gui.debug then\
            log(\"created event listener: \"..id,log.success)\
            log:dump()\
        end\
        return setmetatable(listener,{__index={\
            kill=function()\
                --* removes the listener from the gui object\
                gui.event_listeners[id] = nil\
                gui.paused_listeners[id] = nil\
                if debug or gui.debug then\
                    log(\"killed event listener: \"..id,log.success)\
                    log:dump()\
                end\
            end,\
            pause=function()\
                --* pauses the listener by moving it out of gui.event_listeners\
                gui.paused_listeners[id] = listener\
                gui.event_listeners[id] = nil\
                if debug or gui.debug then\
                    log(\"paused event listener: \"..id,log.success)\
                    log:dump()\
                end\
            end,\
            resume=function()\
                --* resumes the listener by moving it back into gui.event_listeners\
                local listener = gui.paused_listeners[id] or gui.event_listeners[id]\
                if listener then\
                    gui.event_listeners[id] = listener\
                    gui.paused_listeners[id] = nil\
                    if debug or gui.debug then\
                        log(\"resumed event listener: \"..id,log.success)\
                        log:dump()\
                    end\
                elseif debug or gui.debug then\
                    log(\"event listener not found: \"..id,log.error)\
                    log:dump()\
                end\
            end\
        },__tostring=function()\
            --* used for custom listener object naming\
            return \"GuiH.EVENT_LISTENER.\"..id\
        end})\
    end\
\
    gui.cause_exeption = function(e)\
        err = tostring(e)\
    end\
\
    gui.stop = function()\
        running = false\
    end\
\
    gui.kill = gui.stop\
    gui.error = gui.cause_exeption\
\
    --* a function used for clearing the gui\
    gui.clear = function(debug)\
        if debug or gui.debug then\
            log(\"clearing the gui..\",log.update)\
        end\
        local empty = {}\
        for k,v in pairs(objects.types) do empty[v] = {} end\
        gui.gui = empty\
        gui.elements = empty\
        local creators = objects.main(gui,empty,log)\
        gui.create = creators\
        gui.new = creators\
    end\
\
    --* used for checking if any keys are currently held\
    --* by reading gui.held_keys\
    gui.isHeld = function(...)\
        local k_list = {...}\
        local out1,out2 = true,true\
        for k,key in pairs(k_list) do\
            local info = gui.held_keys[key] or {}\
            if info[1] then\
                out1 = out1 and true\
                out2 = out2 and info[2]\
            else\
                return false,false,gui.held_keys\
            end\
        end\
        return out1,out2,gui.held_keys\
    end\
    gui.key.held = gui.isHeld\
\
    --* used for running the actuall gui. handles graphics buffering\
    --* event handling,key handling,multitasking and updating the gui\
    gui.execute=setmetatable({},{__call=function(_,fnc,on_event,bef_draw,after_draw)\
        if running then log(\"Coulnt execute. Gui is already running\",log.error) log:dump() return false end\
        err = nil\
        running = true\
        log(\"\")\
        log(\"loading execute..\",log.update)\
        local execution_window = gui.term_object\
        local event\
        local sbg  = execution_window.getBackgroundColor()\
\
        --* this coroutine is used for udating the gui when an event happens\
        local gui_coro = coroutine.create(function()\
            local ok,erro = pcall(function()\
                execution_window.setVisible(true)\
\
                --* draw the GUI\
                updater(0)\
                execution_window.redraw()\
\
                while true do\
                    --* stop window updates\
                    execution_window.setVisible(false)\
\
                    --* clean the window\
                    execution_window.setBackgroundColor(gui.background or sbg)\
                    execution_window.clear();\
\
                    --* redraw the gui\
                    (bef_draw or function() end)(execution_window)\
                    local event = update(gui,nil,true,false,nil);\
                    (on_event or function() end)(execution_window,event);\
                    (after_draw or function() end)(execution_window)\
\
                    --* unfreeze\
                    execution_window.setVisible(true);\
                end\
            end)\
            if not ok then err = erro log:dump() end\
        end)\
\
        log(\"created graphic routine 1\",log.update)\
        local mns = fnc or function() end\
\
        --* this coroutine is running custom code.\
        local function main()\
            local ok,erro = pcall(mns,execution_window)\
            if not ok then err = erro log:dump() end\
        end\
\
        log(\"created custom updater\",log.update)\
\
        --* this coroutine updates the GUI's graphic side\
        --* wihnout the need for an event. makes gui update live with\
        --* no interaction\
        local graphics_updater = coroutine.create(function()\
            while true do\
\
                --* freeeze the Gui and update its graphics side\
                execution_window.setVisible(false)\
\
                execution_window.setBackgroundColor(gui.background or sbg)\
                execution_window.clear();\
\
                gui.update(0,true,nil,{type=\"mouse_click\",x=-math.huge,y=-math.huge,button=-math.huge});\
                (after_draw or function() end)(execution_window)\
                \
                --* unfreeze and freeze again for the updates to show up\
                execution_window.setVisible(true)\
                execution_window.setVisible(false)\
\
                if gui.update_delay < 0.05 then\
                    os.queueEvent(\"waiting\")\
                    os.pullEvent()\
                else sleep(gui.update_delay) end\
            end\
        end)\
\
        log(\"created event listener handle\",log.update)\
        --* used for updating event listeners\
        local listener_handle = coroutine.create(function()\
            local ok,erro = pcall(function()\
                while true do\
                    local eData = table.pack(os.pullEventRaw())\
                    \
                    --* iterates ever listeners with said event\
                    --* and if the event matches the filter or there is no filter\
                    --* runs the code asigned to the listener\
                    for k,v in pairs(gui.event_listeners) do\
                        local filter = v.filter\
                        if _G.type(filter) == \"string\" then filter = {[v.filter]=true} end\
                        if filter[eData[1]] or filter == eData[1] or (not next(filter)) then\
                            v.code(table.unpack(eData,_G.type(v.filter) ~= \"table\" and 2 or 1,eData.n))\
                        end\
                    end\
                end\
            end)\
            if not ok then err = erro log:dump() end\
        end)\
        log(\"created graphic routine 2\",log.update)\
\
        --* this coroutine is used for handling key presses\
        --* and adding/removing keys from gui.held_keys\
        --* used by the isHeld function\
        local key_handler = coroutine.create(function()\
            while true do\
                local name,key,held = os.pullEvent()\
                if name == \"key\" then gui.held_keys[key] = {true,held} end\
                if name == \"key_up\" then gui.held_keys[key] = nil end\
            end\
        end)\
        log(\"created key handler\")\
\
        --* builds the custom code coroutine\
        local func_coro = coroutine.create(main)\
\
        --* starts up the GUI\
        coroutine.resume(func_coro)\
        coroutine.resume(gui_coro,\"mouse_click\",math.huge,-math.huge,-math.huge)\
        coroutine.resume(gui_coro,\"mouse_click\",math.huge,-math.huge,-math.huge)\
        coroutine.resume(gui_coro,\"mouse_click\",math.huge,-math.huge,-math.huge)\
        log(\"\")\
        log(\"Started execution..\",log.success)\
        log(\"\")\
        log:dump()\
\
        --* loops until either the gui or your custom function dies\
        while ((coroutine.status(func_coro) ~= \"dead\" or not (_G.type(fnc) == \"function\")) and coroutine.status(gui_coro) ~= \"dead\" and err == nil) and running do\
            local event = table.pack(os.pullEventRaw())\
            if api.events_with_cords[event[1]] then\
                event[3] = event[3] - (gui.event_offset_x)\
                event[4] = event[4] - (gui.event_offset_y)\
            end\
\
            --* manual termination handling\
            if event[1] == \"terminate\" then err = \"Terminated\" break end\
\
            --* if the event hasnt been triggered by GuiH (guih_data_event) then\
            --* update the event listener coroutine\
            if event[1] ~= \"guih_data_event\" then\
                coroutine.resume(listener_handle,table.unpack(event,1,event.n))\
            end\
\
            --* runs your custom code\
            coroutine.resume(func_coro,table.unpack(event,1,event.n))\
\
            --* if the happening event is a keyboard based event then\
            --* update held keys\
            if event[1] == \"key\" or event[1] == \"key_up\" then\
                coroutine.resume(key_handler,table.unpack(event,1,event.n))\
            end\
\
            --* executes schedules  tasks\
            for k,v in pairs(gui.task_routine) do\
                if coroutine.status(v.c) ~= \"dead\" then\
                    if v.filter == event[1] or v.filter == nil then\
                        local ok,filter = coroutine.resume(v.c,table.unpack(event,1,event.n))\
                        if ok then v.filter = filter end\
                    end\
                else\
                    --* if the task is dead then remove it\
                    gui.task_routine[k] = nil\
                    gui.task_schedule[k] = nil\
                    if v.dbug then log(\"Finished sheduled task: \"..tostring(k),log.success) end\
                end\
            end\
\
            --* updates the GUI\
            coroutine.resume(gui_coro,table.unpack(event,1,event.n))\
            coroutine.resume(graphics_updater,table.unpack(event,1,event.n))\
\
            --* handling for window rescaling\
            local w,h = orig.getSize()\
            if w ~= gui.w or h ~= gui.h then\
                if (event[1] == \"monitor_resize\" and gui.monitor == event[2]) or gui.monitor == \"term_object\" then\
                    gui.term_object.reposition(1,1,w,h)\
                    coroutine.resume(gui_coro,\"mouse_click\",math.huge,-math.huge,-math.huge)\
                    gui.w,gui.h = w,h\
                    gui.width,gui.height = w,h\
                end\
            end\
        end\
        if err then gui.last_err = err end\
        --* makes sure the window is visible when execution ends\
        execution_window.setVisible(true)\
        if err then log(\"a Fatal error occured: \"..err..debug.traceback(),log.fatal)\
        else log(\"finished execution\",log.success) end\
        log:dump()\
        err = nil\
        --* returns the reason for the stop in execution\
        return gui.last_err,true\
    end,__tostring=function() return \"GuiH.main_gui_executor\" end})\
\
    gui.run = gui.execute\
\
    --* if the term object happens to be an monitor then get its name\
    if type == \"monitor\" then\
        log(\"Display object: monitor\",log.info)\
        gui.monitor = peripheral.getName(deepest)\
    else\
        log(\"Display object: term\",log.info)\
        gui.monitor = \"term_object\"\
    end\
\
    --* wrap the .nimg texture loader\
    gui.load_texture = function(data)\
        log(\"Loading nimg texture.. \",log.update)\
        local tex = graphic.load_texture(data)\
        return tex\
    end\
    --* wrap the .ppm texture loader so you dont have to\
    --* provide log and term object\
    gui.load_ppm_texture = function(data,mode)\
        local ok,tex,img = pcall(graphic.load_ppm_texture,gui.term_object,data,mode,log)\
        if ok then\
            return tex,img\
        else\
            log(\"Failed to load texture: \"..tex,log.error)\
        end\
    end\
    gui.load_cimg_texture = function(file_data)\
        log(\"Loading cimg texture.. \",log.update)\
        local tex = graphic.load_cimg_texture(file_data)\
        return tex\
    end\
    gui.load_blbfor_texture = function(file_data)\
        log(\"Loading blbfor texture.. \",log.update)\
        local tex,anim = graphic.load_blbfor_texture(file_data)\
        return tex,anim\
    end\
    gui.load_limg_texture = function(file_data,bg,image)\
        log(\"Loading limg texture.. \",log.update)\
        local tex,anim = graphic.load_limg_texture(file_data,bg,image)\
        return tex,anim\
    end\
    gui.load_limg_animation = function(file_data,bg)\
        log(\"Loading limg animation.. \",log.update)\
        local textures = graphic.load_limg_animation(file_data,bg)\
        return textures\
    end\
    gui.load_blbfor_animation = function(file_data)\
        log(\"Loading blbfor animation.. \",log.update)\
        local textures = graphic.load_blbfor_animation(file_data)\
        return textures\
    end\
\
    gui.set_event_offset = function(x,y)\
        gui.event_offset_x,gui.event_offset_y = x or gui.event_offset_x,y or gui.event_offset_y\
    end\
    \
    log(\"\")\
    log(\"Starting creator..\",log.info)\
    local creators = objects.main(gui,gui.gui,log)\
    gui.create = creators\
    gui.new = creators\
    log(\"\")\
    gui.update = updater\
    log(\"loading text object...\",log.update)\
    log(\"\")\
\
    gui.get_blit = function(y,sx,ex)\
        local line\
        pcall(function()\
            line = {gui.term_object.getLine(y)}\
        end)\
        if not line then return false end\
        return line[1]:sub(sx,ex),\
            line[2]:sub(sx,ex),\
            line[3]:sub(sx,ex)\
    end\
\
    gui.text = function(data)\
        data = data or {}\
\
        --* makes text not be centered by default\
        if _G.type(data.centered) ~= \"boolean\" then data.centered = false end\
\
        --* if no color data is provided make it 13 long blit for <TEXT OBJECT> name\
        local fg = (_G.type(data.text) == \"string\") and (\"0\"):rep(#data.text) or (\"0\"):rep(13)\
        local bg = (_G.type(data.text) == \"string\") and (\"f\"):rep(#data.text) or (\"f\"):rep(13)\
        if _G.type(data.blit) ~= \"table\" then data.blit = {fg,bg} end\
\
        --* lower blit for maniacs who use caps blit\
        data.blit[1] = (data.blit[1] or fg):lower()\
        data.blit[2] = (data.blit[2] or bg):lower()\
\
        log(\"created new text object\",log.info)\
        return setmetatable({\
            text = data.text or \"<TEXT OBJECT>\",\
            centered = data.centered,\
            x = data.x or 1,\
            y = data.y or 1,\
            offset_x = data.offset_x or 0,\
            offset_y = data.offset_y or 0,\
            blit = data.blit or {fg,bg},\
            transparent=data.transparent,\
            bg=data.bg,\
            fg=data.fg,\
            width=data.width,\
            height=data.height\
        },{\
            __call=function(self,tobject,x,y,w,h)\
                x,y = x or self.x,y or self.y\
                if self.width then w = self.width end\
                if self.height then h = self.height end\
                local term = tobject or gui.term_object\
                local sval\
                if _G.type(x) == \"number\" and _G.type(y) == \"number\" then sval = 1 end\
                if _G.type(x) ~= \"number\" then x = 1 end\
                if _G.type(y) ~= \"number\" then y = 1 end\
                local xin,yin = x,y\
                local strings = {}\
                for c in self.text:gmatch(\"[^\\n]+\") do table.insert(strings,c) end\
                if self.centered then yin = yin - #strings/2\
                else yin = yin - 1 end\
                for i=1,#strings do\
                    local text = strings[i]\
                    yin = yin + 1\
                    if self.centered then\
                        --* calcualte the center text position\
                        local y_centered = (h or gui.h)/2-0.5\
                        local x_centered = math.ceil(((w or gui.w)/2)-(#text/2)-0.5)\
                        term.setCursorPos(x_centered+self.offset_x+xin,y_centered+self.offset_y+yin)\
                        x,y = x_centered+self.offset_x+xin,y_centered+self.offset_y+yin\
                    else\
                        --* calculate the offset text position\
                        term.setCursorPos((sval or self.x)+self.offset_x+xin-1,(sval or self.y)+self.offset_y+yin-1)\
                        x,y = (sval or self.x)+self.offset_x+xin-1,(sval or self.y)+self.offset_y+yin-1\
                    end\
                    if self.transparent == true then\
\
                        --* if the text is of the screen to the left cut it\
                        --* at the spot where it leaves the screen  \
                        --* also move its cursor pos all the way to the left\
                        local n_val = -1\
                        if x < 1 then\
                            n_val = math.abs(math.min(x+1,3)-2)\
                            term.setCursorPos(1,y)\
                            x = 1\
                            text = text:sub(n_val+1)\
                        end\
                        \
                        --* get he provided blit data\
                        local fg,bg = table.unpack(self.blit)\
                        if self.bg then bg = graphic.code.to_blit[self.bg]:rep(#text) end\
                        if self.fg then fg = graphic.code.to_blit[self.fg]:rep(#text) end\
\
                        --* get the blit data on the line the text is on\
                        local line\
                        pcall(function()\
                            _,_,line = term.getLine(math.floor(y))\
                        end)\
                        if not line then return end\
                        --* calculate the blit under the text from its position\
                        --* and data from that line\
                        local sc_bg = line:sub(x,math.min(x+#text-1,gui.w))\
\
                        --* see if that data from the line is enough\
                        --* if not data from text.blit will get added on draw\
                        local diff = #text-#sc_bg-1\
\
                        --* draw the final text subed by b_val in case\
                        --* its off the screen to the left\
                        if #fg ~= #text then fg = (\"0\"):rep(#text) end\
                        pcall(term.blit,text,fg:sub(math.min(x,1)),sc_bg..bg:sub(#bg-diff,#bg))\
                    else\
                        --* draw text with provided blit\
                        local fg,bg = table.unpack(self.blit)\
                        if self.bg then bg = graphic.code.to_blit[self.bg]:rep(#text) end\
                        if self.fg then fg = graphic.code.to_blit[self.fg]:rep(#text) end\
                        if #fg ~= #text then fg = (\"0\"):rep(#text) end\
                        if #bg ~= #text then bg = (\"f\"):rep(#text) end\
                        pcall(term.blit,text,fg,bg)\
                    end\
                end\
            end,\
            __tostring=function() return \"GuiH.primitive.text\" end\
        })\
    end\
    return gui\
end\
\
return create_gui_object",
  [ "presets/tex/brick" ] = "--* creates a custom brick texture\
\
local graphic = require(\"graphic_handle\")\
\
return function(bg,brick)\
    if not bg then bg = colors.gray end\
    if not brick then brick = colors.lightGray end\
    local def = [[{\
        [3] = {[5] = {b = \"background\", s = \"\", t = \"brick\"}, [6] = {b = \"background\", s = \"\", t = \"brick\"}},\
        [4] = {[5] = {b = \"background\", s = \"\", t = \"brick\"}, [6] = {b = \"background\", s = \"\", t = \"brick\"}},\
        [5] = {[5] = {b = \"background\", s = \"\", t = \"brick\"}, [6] = {b = \"background\", s = \"\", t = \"brick\"}},\
        offset = {3, 9, 11, 4}\
    }]]\
    local out = def:gsub(\"background\",graphic.code.to_blit[bg]):gsub(\"brick\",graphic.code.to_blit[brick])\
    return graphic.load_texture(textutils.unserialize(out))\
end",
  [ "apis/pixelbox" ] = "--[[\
    * api for easy interaction with drawing characters\
]]\
\
local graphic = require(\"graphic_handle\")\
local api = require(\"api\")\
local ALGO = require(\"a-tools.algo\")\
\
_ENV = _ENV.ORIGINAL\
\
local EXPECT = require(\"cc.expect\").expect\
\
local PIXELBOX = {}\
local OBJECT = {}\
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
function OBJECT:push_updates()\
    PIXELBOX.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    self.symbols = api.tables.createNDarray(2)\
    self.lines = api.create_blit_array(self.height)\
    getmetatable(self.symbols).__tostring=function() return \"PixelBOX.SYMBOL_BUFFER\" end\
    setmetatable(self.lines,{__tostring=function() return \"PixelBOX.LINE_BUFFER\" end})\
    for y,x_list in pairs(self.CANVAS) do\
        for x,block_color in pairs(x_list) do\
            local RELATIVE_X = math.ceil(x/2)\
            local RELATIVE_Y = math.ceil(y/3)\
            local SYMBOL_POS_X = (x-1)%2+1\
            local SYMBOL_POS_Y = (y-1)%3+1\
            self.symbols[RELATIVE_Y][RELATIVE_X] = PIXELBOX.INDEX_SYMBOL_CORDINATION(\
                self.symbols[RELATIVE_Y][RELATIVE_X],\
                SYMBOL_POS_X,SYMBOL_POS_Y,\
                block_color\
            )\
        end\
    end\
    for y,x_list in pairs(self.symbols) do\
        for x,color_block in ipairs(x_list) do\
            local char,fg,bg = graphic.code.build_drawing_char(color_block)\
            self.lines[y] = {\
                self.lines[y][1]..char,\
                self.lines[y][2]..graphic.code.to_blit[fg],\
                self.lines[y][3]..graphic.code.to_blit[bg]\
            }\
        end\
    end\
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
    self.CANVAS = api.tables.createNDarray(2)\
    for y=1,self.height*3 do\
        for x=1,self.width*2 do\
            self.CANVAS[y][x] = color\
        end\
    end\
    getmetatable(self.CANVAS).__tostring = function() return \"PixelBOX_SCREEN_BUFFER\" end\
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
function OBJECT:set_pixel(x,y,color,thiccness)\
    PIXELBOX.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    EXPECT(1,x,\"number\")\
    EXPECT(2,y,\"number\")\
    EXPECT(3,color,\"number\")\
    PIXELBOX.ASSERT(x>0 and x<=self.width*2,\"Out of range\")\
    PIXELBOX.ASSERT(y>0 and y<=self.height*3,\"Out of range\")\
    thiccness = thiccness or 1\
    local t_ratio = (thiccness-1)/2\
    self:set_box(\
        math.ceil(x-t_ratio),\
        math.ceil(y-t_ratio),\
        x+thiccness-1,y+thiccness-1,color,true\
    )\
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
                self.CANVAS[y][x] = color\
            end\
        end\
    end\
end\
\
function OBJECT:set_ellipse(x,y,rx,ry,color,filled,thiccness,check)\
    if not check then\
        PIXELBOX.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
        EXPECT(1,x,\"number\")\
        EXPECT(2,y,\"number\")\
        EXPECT(3,rx,\"number\")\
        EXPECT(4,ry,\"number\")\
        EXPECT(5,color,\"number\")\
        EXPECT(6,filled,\"boolean\",\"nil\")\
    end\
    thiccness = thiccness or 1\
    local t_ratio = (thiccness-1)/2 \
    if type(filled) ~= \"boolean\" then filled = true end\
    local points = ALGO.get_elipse_points(rx,ry,x,y,filled)\
    for _,point in ipairs(points) do\
        if self:within(point.x,point.y) then\
            self:set_box(\
                math.ceil(point.x-t_ratio),\
                math.ceil(point.y-t_ratio),\
                point.x+thiccness-1,point.y+thiccness-1,color,true\
            )\
        end\
    end\
end\
\
function OBJECT:set_circle(x,y,radius,color,filled,thiccness)\
    PIXELBOX.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    EXPECT(1,x,\"number\")\
    EXPECT(2,y,\"number\")\
    EXPECT(3,radius,\"number\")\
    EXPECT(4,color,\"number\")\
    EXPECT(5,filled,\"boolean\",\"nil\")\
    self:set_ellipse(x,y,radius,radius,color,filled,thiccness,true)\
end\
\
function OBJECT:set_triangle(x1,y1,x2,y2,x3,y3,color,filled,thiccness)\
    PIXELBOX.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    EXPECT(1,x1,\"number\")\
    EXPECT(2,y1,\"number\")\
    EXPECT(3,x2,\"number\")\
    EXPECT(4,y2,\"number\")\
    EXPECT(5,x3,\"number\")\
    EXPECT(6,y3,\"number\")\
    EXPECT(7,color,\"number\")\
    EXPECT(8,filled,\"boolean\",\"nil\")\
    thiccness = thiccness or 1\
    local t_ratio = (thiccness-1)/2 \
    if type(filled) ~= \"boolean\" then filled = true end\
    local points\
    if filled then points = ALGO.get_triangle_points(\
        vector.new(x1,y1),\
        vector.new(x2,y2),\
        vector.new(x3,y3)\
    )\
    else points = ALGO.get_triangle_outline_points(\
        vector.new(x1,y1),\
        vector.new(x2,y2),\
        vector.new(x3,y3)\
    ) end\
    for _,point in ipairs(points) do\
        if self:within(point.x,point.y) then\
            self:set_box(\
                math.ceil(point.x-t_ratio),\
                math.ceil(point.y-t_ratio),\
                point.x+thiccness-1,point.y+thiccness-1,color,true\
            )\
        end\
    end\
end\
\
function OBJECT:set_line(x1,y1,x2,y2,color,thiccness)\
    PIXELBOX.ASSERT(type(self)==\"table\",\"Please use \\\":\\\" when running this function\")\
    EXPECT(1,x1,\"number\")\
    EXPECT(2,y1,\"number\")\
    EXPECT(3,x2,\"number\")\
    EXPECT(4,y2,\"number\")\
    EXPECT(5,color,\"number\")\
    thiccness = thiccness or 1\
    local t_ratio = (thiccness-1)/2 \
    local points = ALGO.get_line_points(x1,y1,x2,y2)\
    for _,point in ipairs(points) do\
        if self:within(point.x,point.y) then\
            self:set_box(\
                math.ceil(point.x-t_ratio),\
                math.ceil(point.y-t_ratio),\
                point.x+thiccness-1,point.y+thiccness-1,color,true\
            )\
        end\
    end\
end\
\
function PIXELBOX.ASSERT(condition,message)\
    if not condition then error(message,3) end\
    return condition\
end\
\
function PIXELBOX.new(terminal,bg,existing)\
    EXPECT(1,terminal,\"table\")\
    EXPECT(2,bg,\"number\",\"nil\")\
    EXPECT(3,existing,\"table\",\"nil\")\
    local bg = bg or terminal.getBackgroundColor() or colors.black\
    local BOX = {}\
    local w,h = terminal.getSize()\
    BOX.term = setmetatable(terminal,{__tostring=function() return \"term_object\" end})\
    BOX.CANVAS = api.tables.createNDarray(2,existing)\
    getmetatable(BOX.CANVAS).__tostring = function() return \"PixelBOX_SCREEN_BUFFER\" end\
    BOX.width = w\
    BOX.height = h\
    for y=1,h*3 do\
        for x=1,w*2 do\
            BOX.CANVAS[y][x] = bg\
        end\
    end\
    return setmetatable(BOX,{__index = OBJECT})\
end\
\
return PIXELBOX\
",
  object_loader = "--[[\
    * this file is used to make the\
    * object generators for the\
    * gui.create table\
]]\
\
local api = require(\"api\")\
\
--* function used to dereference\
--* the an table/gui element\
local function deepcopy(orig)\
\
    --* if the input is not an table\
    --* it doesnt have an reference\
    --* so we just return it\
    local orig_type = type(orig)\
    local copy\
    if orig_type == \"table\" then\
\
        --* if it is an table we iterate over it\
        copy = {}\
        for orig_key, orig_value in next, orig, nil do\
\
            --* if the table happens to be canvas\
            --* we just copy it. since canvas is recursive\
            --* and would cause an infinite loop\
            if orig_key == \"canvas\" then\
                copy.canvas = orig_value\
            else\
                --* if its not canvas then we dereference\
                --* the key and value inside+\
                --* and save that to our copy\
                copy[deepcopy(orig_key)] = deepcopy(orig_value)\
            end\
        end\
\
        --* we also create a dereferenced copy\
        --* of the metatable on this table and we put it back\
        setmetatable(copy, deepcopy(getmetatable(orig)))\
    else\
        copy = orig\
    end\
\
    --* return the dereferenced copy\
    return copy\
end\
\
return {main=function(i_self,guis,log)\
    local object = i_self\
    local objects = {}\
\
    --* we get all the object names and iterate over them\
    local object_list = fs.list(\"objects\")\
    for k,v in pairs(object_list) do\
        log(\"loading object: \"..v,log.update)\
\
        --* we require the main files for this object\
        local zok,main = pcall(require,\"objects/\"..v..\"/object\")\
        if zok and type(main) == \"function\" then\
            local aok,adat = pcall(require,\"objects/\"..v..\"/logic\")\
            local bok,bdat = pcall(require,\"objects/\"..v..\"/graphic\")\
\
            --* check if all files are present and working\
            if aok and bok and (type(adat) == \"function\") and (type(bdat) == \"function\") then\
                local c_file_names = fs.list(fs.combine(\"objects/\",v))\
                local custom_flags = {}\
                local custom_manipulators = {}\
\
                --* we iterate over all the files in the objects folder\
                for _k,_v in pairs(c_file_names) do\
                    local name = _v:match(\"(.*)%.\") or _v\
\
                    --* if the files name isnt any of the default files\
                    --* and it isnt a directorory then\
                    if not (name == \"logic\" or name == \"graphic\" or name == \"object\") and (not fs.isDir(\"objects/\"..v..\"/\"..name)) then\
                        log(\"objects.\"..v..\".\"..name)\
                        \
                        --* we require that file and add the function it returns\
                        --* into custom_flags saved under the files name\
                        local ok,err = pcall(require,\"objects/\"..v..\"/\"..name)\
                        if ok then\
                            log(\"found custom object flag \\\"\"..name .. \"\\\" for: \" .. v,log.update)\
                            custom_flags[name] = require(\"objects/\"..v..\"/\"..name)\
                        else\
                            log(\"bad object flag \"..err)\
                        end\
                    else\
                        --* if the file happens to be a directory called\
                        --* manipulators then we continue\
                        if name == \"manipulators\" then\
                            log(\"found custom object manipulators for: \" .. v,log.update)\
                            \
                            --* get all the files in the manipulators folder\
                            --* and iterate over them\
                            local manips = fs.list(\"objects/\"..v..\"/manipulators\")\
                            for _k,_v in pairs(manips) do\
\
                                --* we require the file and\
                                --* save it into custom_mainipulators\
                                --* table under its name\
                                local ok,err = pcall(require,\"objects/\"..v..\"/manipulators/\".._v:match(\"(.*)%.\") or _v)\
                                if ok then\
                                    log(\"found custom object manipulator \\\"\".._v .. \"\\\" for: \" .. v,log.update)\
                                    custom_manipulators[_v:match(\"(.*)%.\") or _v] = setmetatable({},{__call=function(_,...) return err(...) end,__index=err,__tostring=function() return \"GuiH.\"..v..\".manipulator\" end})\
                                else\
                                    log(\"bad object manipulator \"..err)\
                                end\
                            end\
                        end\
                    end\
                end\
\
                objects[v] = setmetatable({},{\
\
                --* we attach the custom creation flags\
                --* to the new object creator table\
                __index=custom_flags,\
                __tostring=function() return \"GuiH.element_builder.\"..v end,\
\
                --* add a __call for the object creation function\
                __call=function(_,data)\
\
                    --* create a new object using\
                    --* the object.lua file of this object\
                    local object = main(object,data)\
\
                    --* make sure all the nessesary values exist in the object\
                    if not (type(object.name) == \"string\") then object.name = api.uuid4() end\
                    if not (type(object.order) == \"number\") then object.order = 1 end\
                    if not (type(object.logic_order) == \"number\") then object.logic_order = 1 end\
                    if not (type(object.graphic_order) == \"number\") then object.graphic_order = 1 end\
                    if not (type(object.react_to_events) == \"table\") then object.react_to_events = {} end\
                    if not (type(object.btn) == \"table\") then object.btn = {} end\
                    if not (type(object.visible) == \"boolean\") then object.visible = true end\
                    if not (type(object.reactive) == \"boolean\") then object.reactive = true end\
\
                    if type(object.positioning) == \"table\" then\
                        if data.w and not data.width  then object.positioning.width  = data.w end\
                        if data.h and not data.height then object.positioning.height = data.h end\
                    end\
\
                    --* insert the new object into  the gui\
                    guis[v][object.name] = object\
\
                    local __object = object\
                    local __setters = {finish=function() return __object end}\
                    local __getters = {finish=function() return __object end}\
\
                    local function make_setters_and_getters(setters,getters,object,include_child)\
                        local function build_setter(array,name,tp)\
                            array[name] = setmetatable({},{__call=function(_,value,keep_env)\
                                if type(value) ~= tp then error(\"Types are immutable with setters\",2) end\
                                if i_self.debug then log(\"Modified \\\"\"..name..\"\\\" of \".. __object.name) end\
                                object[name] = value\
                                return keep_env and setters or __setters\
                            end})\
                        end\
                        local function build_getter(array,name)\
                            array[name] = setmetatable({},{__call=function()\
                                if i_self.debug then log(\"Read \\\"\" .. name .. \"\\\" of \".. __object.name) end\
                                return object[name]\
                            end})\
                        end\
                        for key,current_value in pairs(object) do\
                            local inc_child = key ~= \"canvas\" and key ~= \"parent\"\
                            build_setter(setters,key,type(current_value))\
                            build_getter(getters,key)\
                            if type(current_value) == \"table\" and include_child then\
                                if not setters[key] then setters[key] = {} end\
                                if not getters[key] then getters[key] = {} end\
                                make_setters_and_getters(setters[key],getters[key],current_value,inc_child)\
                            end\
                        end\
                    end\
\
                    make_setters_and_getters(__setters,__getters,object,true)\
\
                    --* attach custom manipulatos to the object\
                    --* also attach the core functions\
                    local  build_canvas = deepcopy(custom_manipulators) or {}\
                    local index = {}\
\
                    local attached = false\
\
                    for k,v in pairs(build_canvas) do\
                        index[k] = function(...) return v(object,...) end\
                        attached = true\
                    end\
\
                    if attached then log(\"Finished attaching manipulators to creator.\",log.info) end\
\
                    index.logic=adat\
                    index.graphic=bdat\
\
                    index.set = __setters\
                    index.get = __getters\
\
                    --* we attach default manipulators to the object\
                    index.kill=function()\
\
                        --* if the object existst   \
                        if guis[v][object.name] then\
\
                            --* we remove it from the GUI\
                            guis[v][object.name] = nil\
                            if i_self.debug then log(\"killed \"..v..\" > \"..object.name,log.warn) end\
                            return true\
                        else\
                            if i_self.debug then log(\"tried to manipulate dead object.\",log.error) end\
                            return false,\"object no longer exist\"\
                        end\
                    end \
                    index.get_position=function()\
\
                        --* if the object exists we return its position\
                        if guis[v][object.name] then\
                            if object.positioning then\
                                return object.positioning\
                            else\
                                return false,\"object doesnt have positioning information\"\
                            end\
                        else\
                            if i_self.debug then log(\"tried to manipulate dead object.\",log.error) end\
                            return false,\"object no longer exist\"\
                        end\
                    end\
                    index.replicate=function(name)\
                        name = name or api.uuid4()\
\
                        --* if the object exists and we give it a diffirent name then\
                        if guis[v][object.name] then\
                            if name == object.name then\
                                return \"name of copy cannot be the same!\"\
                            else\
\
                                --* we make a deepcopy of this object and add it\
                                --* to the gui with the new name\
                                if i_self.debug then log(\"Replicated \"..v..\" > \"..object.name..\" as \"..v..\" > \"..name,log.info) end\
                                local temp = deepcopy(guis[v][object.name])\
                                guis[v][name or \"\"] = temp\
                                temp.name = name\
                                return temp,true\
                            end\
                        else\
                            if i_self.debug then log(\"tried to manipulate dead object.\",log.error) end\
                            return false,\"object no longer exist\"\
                        end\
                    end\
                    index.isolate=function()\
                        if guis[v][object.name] then\
                            --* we save a deep copy of this object\
                            local object = deepcopy(guis[v][object.name])\
                            if i_self.debug then log(\"isolated \"..v..\" > \"..object.name,log.info) end\
                            return {\
                                parse=function(name)\
                                    if i_self.debug then log(\"parsed \"..v..\" > \"..object.name,log.info) end\
                                    --* if we still have the deepcopy we add it back to the gui\
                                    if object then\
                                        local name = name or object.name\
                                        if guis[v][name] then guis[v][name] = nil end\
                                        guis[v][name] = object\
                                        return guis[v][name]\
                                    else\
                                        return false,\"object no longer exist\"\
                                    end\
                                end,\
                                get=function()\
                                    if object then\
                                        if i_self.debug then log(\"returned \"..v..\" > \"..object.name,log.info) end\
                                        return object\
                                    else\
                                        return false,\"object no longer exist\"\
                                    end\
                                end,\
                                clear=function()\
                                    if i_self.debug then log(\"Removed copied object \"..v..\" > \"..object.name,log.info) end\
                                    object = nil\
                                end,\
                            }\
                        else\
                            if i_self.debug then log(\"tried to manipulate dead object.\",log.error) end\
                            return false,\"object no longer exist\"\
                        end\
                    end\
                    index.cut=function()\
                        --* we save a deep copy of this object\
                        --* and then remove it from the GUI\
                        if guis[v][object.name] then\
                            local object = deepcopy(guis[v][object.name])\
                            guis[v][object.name] = nil\
                            if i_self.debug then log(\"cut \"..v..\" > \"..object.name,log.info) end\
                            return {\
                                parse=function()\
                                    --* if we still got the copy then\
                                    --* we add it back to the GUI\
                                    if object then\
                                        if i_self.debug then log(\"parsed \"..v..\" > \"..object.name,log.info) end\
                                        if guis[v][object.name] then guis[v][object.name] = nil end\
                                        guis[v][object.name] = object\
                                        return guis[v][object.name]\
                                    else\
                                        return false,\"object no longer exist\"\
                                    end\
                                end,\
                                get=function()\
                                    if i_self.debug then log(\"returned \"..v..\" > \"..object.name,log.info) end\
                                    return object\
                                end,\
                                clear=function()\
                                    if i_self.debug then log(\"Removed copied object \"..v..\" > \"..object.name,log.info) end\
                                    object = nil\
                                end\
                            }\
                        else\
                            if i_self.debug then log(\"tried to manipulate dead object.\",log.error) end\
                            return false,\"object no longer exist\"\
                        end\
                    end\
                    \
                    --* aliases for object.kill\
                    index.destroy = index.kill\
                    index.murder = index.destroy\
                    index.copy = index.isolate\
\
                    --* we check if the object has propper main functions attached\
                    if not type(index.logic) == \"function\" then log(\"object \"..v..\" has invalid logic.lua\",log.error) return false end\
                    if not type(index.graphic) == \"function\" then log(\"object \"..v..\" has invalid graphic.lua\",log.error) return false end\
\
                    --* we attach theese to the object\
                    --* and give it a pointer to the gui object it is in\
                    setmetatable(object,{__index = index,__tostring=function() return \"GuiH.element.\"..v..\".\"..object.name end})\
                    if object.positioning then setmetatable(object.positioning,{__tostring=function() return \"GuiH.element.position\" end}) end\
                    object.canvas = i_self\
\
                    log(\"created new \"..v..\" > \"..object.name,log.info)\
                    log:dump()\
\
                    --* return the finished object\
                    return object\
                end})\
            else\
                \
                --* logs for debbuging purposes\
                if not aok and bok then\
                    log(v..\" is missing an logic file !\",log.error)\
                end\
                if not bok and aok then\
                    log(v..\" is missing an graphic file !\",log.error)\
                end\
                if not aok and not bok then\
                    log(v..\" is missing logic and graphic file !\",log.error)\
                end\
                if aok and (type(adat) ~= \"function\") then\
                    log(v..\" has an invalid logic file !\",log.error)\
                end\
                if bok and (type(bdat) ~= \"function\") then\
                    log(v..\" has an invalid graphic file !\",log.error)\
                end\
                if bok and aok and (type(bdat) ~= \"function\") and (type(adat) ~= \"function\") then\
                    log(v..\" has an invalid logic and graphic file !\",log.error)\
                end\
            end\
        else\
            if zok and not (type(main) == \"function\") then\
                log(v..\" has invalid object file!\",log.error)\
            else\
                log(v..\" is missing an object file !\",log.error)\
            end\
        end\
    end\
\
    --* return the list of object builders\
    _ENV = _ENV.ORIGINAL\
    return objects\
end,types=fs.list(\"objects\")}",
  [ "a-tools/algo" ] = "--[[\
    * this file is used for algorithms\
    * and shape drawing purposes\
    * i dont feel like explaining this file\
    * since i dont understand it very much myself.\
    ! sorry for that\
]]\
\
local api = require(\"api\")\
\
_ENV = _ENV.ORIGINAL\
\
local function get_elipse_points(radius_x,radius_y,xc,yc,filled)\
    local rx,ry = math.ceil(math.floor(radius_x-0.5)/2),math.ceil(math.floor(radius_y-0.5)/2)\
    local x,y=0,ry\
    local d1 = ((ry * ry) - (rx * rx * ry) + (0.25 * rx * rx))\
    local dx = 2*ry^2*x\
    local dy = 2*rx^2*y\
    local points = {}\
    while dx < dy do\
        table.insert(points,{x=x+xc,y=y+yc})\
        table.insert(points,{x=-x+xc,y=y+yc})\
        table.insert(points,{x=x+xc,y=-y+yc})\
        table.insert(points,{x=-x+xc,y=-y+yc})\
        if filled then\
            for y=-y+yc+1,y+yc-1 do\
                table.insert(points,{x=x+xc,y=y})\
                table.insert(points,{x=-x+xc,y=y})\
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
        table.insert(points,{x=x+xc,y=y+yc})\
        table.insert(points,{x=-x+xc,y=y+yc})\
        table.insert(points,{x=x+xc,y=-y+yc})\
        table.insert(points,{x=-x+xc,y=-y+yc})\
        if filled then\
            for y=-y+yc,y+yc do\
                table.insert(points,{x=x+xc,y=y})\
                table.insert(points,{x=-x+xc,y=y})\
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
    return points\
end\
\
local function drawFlatTopTriangle(points,vec1,vec2,vec3)\
    local m1 = (vec3.x - vec1.x) / (vec3.y - vec1.y)\
    local m2 = (vec3.x - vec2.x) / (vec3.y - vec2.y)\
    local yStart = math.ceil(vec1.y - 0.5)\
    local yEnd =   math.ceil(vec3.y - 0.5)-1\
    for y = yStart, yEnd do\
        local px1 = m1 * (y + 0.5 - vec1.y) + vec1.x\
        local px2 = m2 * (y + 0.5 - vec2.y) + vec2.x\
        local xStart = math.ceil(px1 - 0.5)\
        local xEnd =   math.ceil(px2 - 0.5)\
        for x=xStart,xEnd do\
            table.insert(points,{x=x,y=y})\
        end\
    end\
end\
\
local function drawFlatBottomTriangle(points,vec1,vec2,vec3)\
    local m1 = (vec2.x - vec1.x) / (vec2.y - vec1.y)\
    local m2 = (vec3.x - vec1.x) / (vec3.y - vec1.y)\
    local yStart = math.ceil(vec1.y-0.5)\
    local yEnd =   math.ceil(vec3.y-0.5)-1\
    for y = yStart, yEnd do\
        local px1 = m1 * (y + 0.5 - vec1.y) + vec1.x\
        local px2 = m2 * (y + 0.5 - vec1.y) + vec1.x\
        local xStart = math.ceil(px1 - 0.5)\
        local xEnd =   math.ceil(px2 - 0.5)\
        for x=xStart,xEnd do\
            table.insert(points,{x=x,y=y})\
        end\
    end\
end\
local function get_triangle_points(pv1,pv2,pv3)\
    local points = {}\
    if pv2.y < pv1.y then pv1,pv2 = pv2,pv1 end\
    if pv3.y < pv2.y then pv2,pv3 = pv3,pv2 end\
    if pv2.y < pv1.y then pv1,pv2 = pv2,pv1 end\
    if pv1.y == pv2.y then\
        if pv2.x < pv1.x then pv1,pv2 = pv2,pv1 end\
        drawFlatTopTriangle(points,pv1,pv2,pv3)\
    elseif pv2.y == pv3.y then\
        if pv3.x < pv2.x then pv3,pv2 = pv2,pv3 end\
        drawFlatBottomTriangle(points,pv1,pv2,pv3)\
    else \
        local alphaSplit = (pv2.y-pv1.y)/(pv3.y-pv1.y)\
        local vi ={ \
            x = pv1.x + ((pv3.x - pv1.x) * alphaSplit),      \
            y = pv1.y + ((pv3.y - pv1.y) * alphaSplit), }\
        if pv2.x < vi.x then\
            drawFlatBottomTriangle(points,pv1,pv2,vi)\
            drawFlatTopTriangle(points,pv2,vi,pv3)\
        else\
            drawFlatBottomTriangle(points,pv1,vi,pv2)\
            drawFlatTopTriangle(points,vi,pv2,pv3)\
        end\
    end\
    return points\
end\
\
local function get_rectangle_points(x,y,width,height)\
    local points = {}\
    for x=x,x+width do\
        for y=y,y+height do\
            table.insert(points,{x=x,y=y})\
        end\
    end\
end\
\
--credit to computercraft paintutils api\
local function get_line_points(startX, startY, endX, endY)\
    local points = {}\
    startX,startY,endX,endY = math.floor(startX),math.floor(startY),math.floor(endX),math.floor(endY)\
    if startX == endX and startY == endY then return {x=startX,y=startY} end\
    local minX = math.min(startX, endX)\
    local maxX, minY, maxY\
    if minX == startX then minY,maxX,maxY = startY,endX,endY\
    else minY,maxX,maxY = endY,startX,startY end\
    local xDiff,yDiff = maxX - minX,maxY - minY\
    if xDiff > math.abs(yDiff) then\
        local y = minY\
        local dy = yDiff / xDiff\
        for x = minX, maxX do\
            table.insert(points,{x=x,y=math.floor(y + 0.5)})\
            y = y + dy\
        end\
    else\
        local x,dx = minX,xDiff / yDiff\
        if maxY >= minY then\
            for y = minY, maxY do\
                table.insert(points,{x=math.floor(x + 0.5),y=y})\
                x = x + dx\
            end\
        else\
            for y = minY, maxY, -1 do\
                table.insert(points,{x=math.floor(x + 0.5),y=y})\
                x = x - dx\
            end\
        end\
    end\
    return points\
end\
\
local function get_triangle_outline_points(v1,v2,v3)\
    local final_points = {}\
    local s1 = get_line_points(v1.x,v1.y,v2.x,v2.y)\
    local s2 = get_line_points(v2.x,v2.y,v3.x,v3.y)\
    local s3 = get_line_points(v3.x,v3.y,v1.x,v1.y)\
    return api.tables.merge(s1,s2,s3)\
end\
\
return {\
    get_elipse_points = get_elipse_points,\
    get_triangle_points = get_triangle_points,\
    get_triangle_outline_points=get_triangle_outline_points,\
    get_line_points=get_line_points\
}\
",
  [ "presets/rect/framed_window" ] = "return function(side,bg)\
    return {\
        top_left={sym=\" \",bg=side,fg=bg},\
        top_right={sym=\" \",bg=side,fg=bg},\
        bottom_left={sym=\"\\138\",bg=side,fg=bg},\
        bottom_right={sym=\"\\133\",bg=side,fg=bg},\
        side_left={sym=\"\\149\",bg=bg,fg=side},\
        side_right={sym=\"\\149\",bg=side,fg=bg},\
        side_top={sym=\" \",bg=side,fg=bg},\
        side_bottom={sym=\"\\143\",bg=side,fg=bg},\
        inside={sym=\" \",bg=bg,fg=side}\
    }\
end",
  [ "objects/script/object" ] = "local api = require(\"api\")\
return function(object,data)\
    data = data or {}\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(data.reactive) ~= \"boolean\" then data.reactive = true end\
    local base = {\
        name=data.name or api.uuid4(),\
        visible=data.visible,\
        reactive=data.reactive,\
        code=data.code or function() return false end,\
        graphic=data.graphic or function() return false end,\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
        react_to_events={\
            mouse_click=true,\
            mouse_drag=true,\
            monitor_touch=true,\
            mouse_scroll=true,\
            mouse_up=true,\
            key=true,\
            key_up=true,\
            char=true,\
            paste=true\
        }\
    }\
    return base\
end\
",
  [ "presets/rect/frame_thick" ] = "return function(side,bg)\
    return {\
        top_left={sym=\" \",bg=side,fg=bg},\
        top_right={sym=\" \",bg=side,fg=bg},\
        bottom_left={sym=\" \",bg=side,fg=bg},\
        bottom_right={sym=\" \",bg=side,fg=bg},\
        side_left={sym=\" \",bg=side,fg=bg},\
        side_right={sym=\" \",bg=side,fg=bg},\
        side_top={sym=\" \",bg=side,fg=bg},\
        side_bottom={sym=\" \",bg=side,fg=bg},\
        inside={sym=\" \",bg=bg,fg=bg},\
    }\
end",
  [ "objects/ellipse/graphic" ] = "local algo = require(\"a-tools.algo\")\
local graphic = require(\"graphic_handle\").code\
local api = require(\"api\")\
\
return function(object)\
    local term = object.canvas.term_object\
    local draw_map = {}\
    local x_map = {}\
    local visited = api.tables.createNDarray(2)\
    if object.filled then\
        local points = algo.get_elipse_points(\
            object.positioning.width,\
            object.positioning.height,\
            object.positioning.x,\
            object.positioning.y,\
            true\
        )\
        for k,v in ipairs(points) do\
            if visited[v.x][v.y] ~= true then\
                draw_map[v.y] = (draw_map[v.y] or \"\")..\"*\"\
                x_map[v.y] = math.min(x_map[v.y] or math.huge,v.x)\
                visited[v.x][v.y] = true\
            end\
        end\
        for y,data in pairs(draw_map) do\
            term.setCursorPos(x_map[y],y)\
            term.blit(\
                data:gsub(\"%*\",object.symbol),\
                data:gsub(\"%*\",graphic.to_blit[object.fg]),\
                data:gsub(\"%*\",graphic.to_blit[object.bg])\
            )\
        end\
    else\
        local points = algo.get_elipse_points(\
            object.positioning.width,\
            object.positioning.height,\
            object.positioning.x,\
            object.positioning.y\
        )\
        for k,v in pairs(points) do\
            term.setCursorPos(v.x,v.y)\
            term.blit(\
                object.symbol,\
                graphic.to_blit[object.fg],\
                graphic.to_blit[object.bg]\
            )\
        end\
    end\
end",
  [ "objects/progressbar/logic" ] = "return function(object)\
end\
",
  [ "objects/frame/logic" ] = "local api = require(\"api\")\
return function(object,event,self)\
    object.on_any(object,event)\
    local x,y = object.window.getPosition()\
    local dragger_x = object.dragger.x+x\
    local dragger_y = object.dragger.y+y\
    if event.name == \"mouse_click\" or event.name == \"monitor_touch\" then\
        if api.is_within_field(\
            event.x,\
            event.y,\
            dragger_x-1,\
            dragger_y-1,\
            object.dragger.width,\
            object.dragger.height\
        ) then\
            object.dragged = true\
            object.last_click = event\
            object.on_select(object,event)\
        end\
    elseif event.name == \"mouse_up\" then\
        object.dragged = false\
        object.on_select(object,event)\
    elseif event.name == \"mouse_drag\" and object.dragged and object.dragable then\
        local wx,wy = object.window.getPosition()\
        local ww,wh = object.window.getSize()\
        local change_x,change_y = event.x-object.last_click.x,event.y-object.last_click.y\
        object.last_click = event\
        local nx,ny = wx+change_x,wy+change_y\
        if not object.on_move(object,{x=nx,y=ny}) then\
            object.window.reposition(nx,ny)\
        end\
    end\
end\
",
  [ "presets/rect/border" ] = "return function(border,bg)\
    return {\
        top_left={sym=\"\\159\",fg=bg,bg=border},\
        top_right={sym=\"\\144\",fg=border,bg=bg},\
        bottom_left={sym=\"\\130\",fg=border,bg=bg},\
        bottom_right={sym=\"\\129\",fg=border,bg=bg},\
        side_left={sym=\"\\149\",fg=bg,bg=border},\
        side_right={sym=\"\\149\",fg=border,bg=bg},\
        side_top={sym=\"\\143\",fg=bg,bg=border},\
        side_bottom={sym=\"\\131\",fg=border,bg=bg},\
        inside={sym=\" \",bg=bg,fg=border},\
    }\
end",
  [ "objects/frame/object" ] = "local api = require(\"api\")\
local main = require(\"a-tools.gui_object\")\
\
return function(object,data)\
    data = data or {}\
    if type(data.clear) ~= \"boolean\" then data.clear = true end\
    if type(data.draggable) ~= \"boolean\" then data.draggable = true end\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(data.reactive) ~= \"boolean\" then data.reactive = true end\
    local btn = {\
        name=data.name or api.uuid4(),\
        positioning = {\
            x=data.x or 1,\
            y=data.y or 1,\
            width=data.width or 0,\
            height=data.height or 0\
        },\
        visible=data.visible,\
        reactive=data.reactive,\
        react_to_events={\
            mouse_drag=true,\
            mouse_click=true,\
            mouse_up=true\
        },\
        dragged=false,\
        dragger=data.dragger,\
        last_click={\
            x=1,\
            y=1\
        },\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
        btn=data.btn,\
        dragable=data.draggable,\
        on_move=data.on_move or function() end,\
        on_select=data.on_select or function() end,\
        on_any=data.on_any or function() end,\
        on_graphic=data.on_graphic or function() end,\
        on_deselect=data.on_deselect or function() end\
    }\
    local window = window.create(\
        object.term_object,\
        btn.positioning.x,\
        btn.positioning.y,\
        btn.positioning.width,\
        btn.positioning.height\
    )\
    if not btn.dragger then\
        btn.dragger = {\
            x=1,\
            y=1,\
            width=btn.positioning.width,\
            height=1\
        }\
    end\
    btn.child = main(window,object.term_object,object.log)\
    btn.window = window\
    btn.child.inherit(object,btn)\
    return btn\
end",
  [ "objects/progressbar/object" ] = "local api = require(\"api\")\
\
local types = {\
    [\"left-right\"]=true,\
    [\"right-left\"]=true,\
    [\"top-down\"]=true,\
    [\"down-top\"]=true,\
}\
\
return function(object,data)\
    data = data or {}\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(data.drag_texture) ~= \"boolean\" then data.drag_texture = false end\
    local btn = {\
        name=data.name or api.uuid4(),\
        positioning = {\
            x=data.x or 1,\
            y=data.y or 1,\
            width=data.width or 0,\
            height=data.height or 0\
        },\
        visible=data.visible,\
        fg=data.fg or colors.white,\
        bg=data.bg or colors.black,\
        texture=data.tex,\
        value=data.value or 0,\
        direction=types[data.direction] and data.direction or \"left-right\",\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
        drag_texture=data.drag_texture,\
        tex_offset_x=data.tex_offset_x or 0,\
        tex_offset_y=data.tex_offset_y or 0,\
    }\
    return btn\
end\
",
  [ "a-tools/logger" ] = "--[[\
    * this is an modified version of my log api\
    * made specificaly for GuiH logging\
    * designed to log into a file\
]]\
\
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
\
local index = {\
    error=1,\
    warn=2,\
    fatal=3,\
    success=4,\
    message=6,\
    update=7,\
    info=8\
}\
\
local type_space = 15\
\
local revIndex = {}\
\
--* reverses table indexe with value\
for k,v in pairs(index) do\
    revIndex[v] = k\
end\
\
--*removes time data from start of a string. time format: (\"HH:MM PM/AM?\")\
local function remove_time(str)\
    local str = str:gsub(\"^%[%d-%:%d-% %a-]\",\"\")\
    return str\
end\
\
--* takes the logs history data and procceses it into a file\
function index:dump()\
end\
\
--* creates a new entry in  the log\
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
\
--* makes the log object\
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
return {create_log=createLogInternal}\
",
  [ "objects/rectangle/logic" ] = "return function()\
end\
",
  [ "objects/rectangle/graphic" ] = "local graphics = require(\"graphic_handle\").code\
\
return function(object)\
    local term = object.canvas.term_object\
    local x,y = object.positioning.x,object.positioning.y\
    local w,h = object.positioning.width,object.positioning.height\
    term.setCursorPos(x,y)\
    term.blit(\
        object.symbols.top_left.sym..object.symbols.side_top.sym:rep(w-2)..object.symbols.top_right.sym,\
        graphics.to_blit[object.symbols.top_left.fg]..graphics.to_blit[object.symbols.side_top.fg]:rep(w-2)..graphics.to_blit[object.symbols.top_right.fg],\
        graphics.to_blit[object.symbols.top_left.bg]..graphics.to_blit[object.symbols.side_top.bg]:rep(w-2)..graphics.to_blit[object.symbols.top_right.bg]\
    )\
    for i=1,h-2 do\
        term.setCursorPos(x,y+i)\
        term.blit(\
            object.symbols.side_left.sym..object.symbols.inside.sym:rep(w-2)..object.symbols.side_right.sym,\
            graphics.to_blit[object.symbols.side_left.fg]..graphics.to_blit[object.symbols.inside.fg]:rep(w-2)..graphics.to_blit[object.symbols.side_right.fg],\
            graphics.to_blit[object.symbols.side_left.bg]..graphics.to_blit[object.symbols.inside.bg]:rep(w-2)..graphics.to_blit[object.symbols.side_right.bg]\
        )\
    end\
    term.setCursorPos(x,y+h-1)\
    term.blit(\
        object.symbols.bottom_left.sym..object.symbols.side_bottom.sym:rep(w-2)..object.symbols.bottom_right.sym,\
        graphics.to_blit[object.symbols.bottom_left.fg]..graphics.to_blit[object.symbols.side_bottom.fg]:rep(w-2)..graphics.to_blit[object.symbols.bottom_right.fg],\
        graphics.to_blit[object.symbols.bottom_left.bg]..graphics.to_blit[object.symbols.side_bottom.bg]:rep(w-2)..graphics.to_blit[object.symbols.bottom_right.bg]\
    )\
end",
  [ "objects/triangle/graphic" ] = "local algo = require(\"a-tools.algo\")\
local graphic = require(\"graphic_handle\").code\
\
return function(object)\
    local term = object.canvas.term_object\
    local draw_map = {}\
    local x_map = {}\
    if object.filled then\
        local points = algo.get_triangle_points(\
            object.positioning.p1,\
            object.positioning.p2,\
            object.positioning.p3\
        )\
        for k,v in ipairs(points) do\
            draw_map[v.y] = (draw_map[v.y] or \"\")..\"*\"\
            x_map[v.y] = math.min(x_map[v.y] or math.huge,v.x)\
        end\
        for y,data in pairs(draw_map) do\
            term.setCursorPos(x_map[y],y)\
            term.blit(\
                data:gsub(\"%*\",object.symbol),\
                data:gsub(\"%*\",graphic.to_blit[object.fg]),\
                data:gsub(\"%*\",graphic.to_blit[object.bg])\
            )\
        end\
    else\
        local points = algo.get_triangle_outline_points(\
            object.positioning.p1,\
            object.positioning.p2,\
            object.positioning.p3\
        )\
        for k,v in pairs(points) do\
            term.setCursorPos(v.x,v.y)\
            term.blit(\
                object.symbol,\
                graphic.to_blit[object.fg],\
                graphic.to_blit[object.bg]\
            )\
        end\
    end\
end",
  [ "objects/ellipse/logic" ] = "return function()\
end\
",
  [ "objects/text/object" ] = "local api = require(\"api\")\
return function(object,data)\
    data = data or {}\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(data.reactive) ~= \"boolean\" then data.reactive = true end\
    local base = {\
        name=data.name or api.uuid4(),\
        visible=data.visible,\
        text=data.text or object.text{text=\"none\",x=1,y=1,bg=colors.red,fg=colors.black},\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
        update=data.update or function() end\
    }\
    return base\
end",
  [ "objects/script/logic" ] = "return function(object,event)\
    object.code(object,event)\
end\
",
  [ "objects/progressbar/graphic" ] = "local graphic = require(\"graphic_handle\")\
\
return function(object)\
    local term = object.canvas.term_object\
    local pointValue = math.floor(math.max(math.min(object.positioning.width*(object.value/100),object.positioning.width),0))\
    local left = math.ceil(math.min(math.max(object.positioning.width-pointValue,0),object.positioning.width))\
    if object.direction == \"left-right\"  then\
        if not object.texture then\
            for y=object.positioning.y,object.positioning.height+object.positioning.y-1 do\
                term.setCursorPos(object.positioning.x,y)\
                term.blit(\
                    (\" \"):rep(pointValue)..(\" \"):rep(left),\
                    (\"f\"):rep(pointValue)..(\"f\"):rep(left),\
                    graphic.code.to_blit[object.fg]:rep(pointValue)..graphic.code.to_blit[object.bg]:rep(left)\
                )\
            end\
        else\
            if not object.drag_texture then\
                graphic.code.draw_box_tex(\
                    term,\
                    object.texture,\
                    object.positioning.x,\
                    object.positioning.y,\
                    pointValue,\
                    object.positioning.height,object.bg,object.fg,\
                    object.tex_offset_x,\
                    object.tex_offset_y,\
                    object.canvas.texture_cache\
                )\
            else\
                graphic.code.draw_box_tex(\
                    term,\
                    object.texture,\
                    object.positioning.x,\
                    object.positioning.y,\
                    pointValue,\
                    object.positioning.height,object.bg,object.fg,\
                    -pointValue+1+object.tex_offset_x,\
                    object.tex_offset_y,\
                    object.canvas.texture_cache\
                )\
            end\
            for y=object.positioning.y,object.positioning.height+object.positioning.y-1 do\
                term.setCursorPos(object.positioning.x+pointValue,y)\
                term.blit(\
                    (\" \"):rep(left),\
                    (\"f\"):rep(left),\
                    graphic.code.to_blit[object.bg]:rep(left)\
                )\
            end\
        end\
    end\
    if object.direction == \"right-left\" then\
        if not object.texture then\
            for y=object.positioning.y,object.positioning.height+object.positioning.y-1 do\
                term.setCursorPos(object.positioning.x,y)\
                term.blit(\
                    (\" \"):rep(left)..(\" \"):rep(pointValue),\
                    (\"f\"):rep(left)..(\"f\"):rep(pointValue),\
                    graphic.code.to_blit[object.bg]:rep(left)..graphic.code.to_blit[object.fg]:rep(pointValue)\
                )\
            end\
        else\
            if object.drag_texture then\
                graphic.code.draw_box_tex(\
                    term,\
                    object.texture,\
                    object.positioning.x+object.positioning.width-pointValue,\
                    object.positioning.y,\
                    pointValue,\
                    object.positioning.height,object.bg,object.fg,\
                    object.tex_offset_x,\
                    object.tex_offset_y,\
                    object.canvas.texture_cache\
                )\
            else\
                graphic.code.draw_box_tex(\
                    term,\
                    object.texture,\
                    object.positioning.x+object.positioning.width-pointValue,\
                    object.positioning.y,\
                    pointValue,\
                    object.positioning.height,object.bg,object.fg,\
                    -pointValue+1+object.tex_offset_x,\
                    object.tex_offset_y,\
                    object.canvas.texture_cache\
                )\
            end\
            for y=object.positioning.y,object.positioning.height+object.positioning.y-1 do\
                term.setCursorPos(object.positioning.x,y)\
                term.blit(\
                    (\" \"):rep(left),\
                    (\"f\"):rep(left),\
                    graphic.code.to_blit[object.bg]:rep(left)\
                )\
            end\
        end\
    end\
    local pointValue = math.floor(math.min(object.positioning.height,math.max(0,math.floor(object.positioning.height*(math.floor(object.value))/100))))\
    local left = math.ceil(math.min(object.positioning.height,math.max(0,object.positioning.height-pointValue)))\
    if object.direction == \"top-down\" then\
        if not object.texture then\
            for y=object.positioning.y,object.positioning.y+object.positioning.height-1 do\
                term.setCursorPos(object.positioning.x,y)\
                if y <= pointValue+object.positioning.y-0.5 then\
                    term.blit(\
                        (\" \"):rep(object.positioning.width),\
                        (\"f\"):rep(object.positioning.width),\
                        graphic.code.to_blit[object.fg]:rep(object.positioning.width)\
                    )\
                else\
                    term.blit(\
                        (\" \"):rep(object.positioning.width),\
                        (\"f\"):rep(object.positioning.width),\
                        graphic.code.to_blit[object.bg]:rep(object.positioning.width)\
                    )\
                end\
            end\
        else\
            if not object.drag_texture then\
                graphic.code.draw_box_tex(\
                    term,\
                    object.texture,\
                    object.positioning.x,\
                    object.positioning.y,\
                    object.positioning.width,\
                    pointValue,object.bg,object.fg,\
                    object.tex_offset_x,\
                    object.tex_offset_y,\
                    object.canvas.texture_cache\
                )\
            else\
                graphic.code.draw_box_tex(\
                    term,\
                    object.texture,\
                    object.positioning.x,\
                    object.positioning.y,\
                    object.positioning.width,\
                    pointValue,object.bg,object.fg,object.tex_offset_x,\
                    -pointValue+1+object.tex_offset_y,\
                    object.canvas.texture_cache\
                )\
            end\
            for y=object.positioning.y+pointValue,object.positioning.y+object.positioning.height-1 do\
                term.setCursorPos(object.positioning.x,y)\
                term.blit(\
                    (\" \"):rep(object.positioning.width),\
                    (\"f\"):rep(object.positioning.width),\
                    graphic.code.to_blit[object.bg]:rep(object.positioning.width)\
                )\
            end\
        end\
    end\
    local pointValue = math.min(object.positioning.height,math.max(0,math.floor(object.positioning.height*(100-math.floor(object.value))/100)))\
    local left = math.min(object.positioning.height,math.max(0,object.positioning.height-pointValue))\
    if object.direction == \"down-top\" then\
        if not object.texture then\
            for y=object.positioning.y,object.positioning.y+object.positioning.height-1 do\
                term.setCursorPos(object.positioning.x,y)\
                if y <= pointValue+object.positioning.y-0.5 then\
                    term.blit(\
                        (\" \"):rep(object.positioning.width),\
                        (\"f\"):rep(object.positioning.width),\
                        graphic.code.to_blit[object.bg]:rep(object.positioning.width)\
                    )\
                else\
                    term.blit(\
                        (\" \"):rep(object.positioning.width),\
                        (\"f\"):rep(object.positioning.width),\
                        graphic.code.to_blit[object.fg]:rep(object.positioning.width)\
                    )\
                end\
            end\
        else\
            if object.drag_texture then\
                graphic.code.draw_box_tex(\
                    term,\
                    object.texture,\
                    object.positioning.x,\
                    object.positioning.y+pointValue,\
                    object.positioning.width,\
                    left,object.bg,object.fg,\
                    object.tex_offset_x,\
                    object.tex_offset_y,object.canvas.texture_cache\
                )\
            else\
                graphic.code.draw_box_tex(\
                    term,\
                    object.texture,\
                    object.positioning.x,\
                    object.positioning.y+pointValue,\
                    object.positioning.width,\
                    left,object.bg,object.fg,object.tex_offset_x,\
                    -left+1+object.tex_offset_y,\
                    object.canvas.texture_cache\
                )\
            end\
            for y=object.positioning.y,object.positioning.y+pointValue-1 do\
                term.setCursorPos(object.positioning.x,y)\
                term.blit(\
                    (\" \"):rep(object.positioning.width),\
                    (\"f\"):rep(object.positioning.width),\
                    graphic.code.to_blit[object.bg]:rep(object.positioning.width)\
                )\
            end\
        end\
    end\
end",
  [ "apis/fuzzy_find" ] = "_ENV = _ENV.ORIGINAL\
\
local pretty = require(\"cc.pretty\")\
\
local function fuzzy_match(str, pattern)\
    local part = 100/math.max(#str,#pattern)\
    local str_len = string.len(str)\
    local pattern_len = string.len(pattern)\
    local dp = {}\
    for i = 0, str_len do\
        dp[i] = {}\
        dp[i][0] = i\
    end\
    for j = 0, pattern_len do\
        dp[0][j] = j\
    end\
    for i = 1, str_len do\
        for j = 1, pattern_len do\
            local cost = 0\
            if string.sub(str, i, i) ~= string.sub(pattern, j, j) then\
                cost = 1\
            end\
            dp[i][j] = math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + cost)\
        end\
    end\
    return 100-dp[str_len][pattern_len]*part\
end\
\
local function sort_strings(str_array, pattern)\
    local result,out = {},{}\
    for k, str in pairs(str_array) do\
        table.insert(result,{fuzzy_match(k, pattern),k,str})\
    end\
    table.sort(result, function(a, b) return a[1] > b[1] end)\
    for k,v in ipairs(result) do\
        out[k] = {match=v[1],str=v[2],data=v[3]}\
    end\
    return out\
end\
\
return {\
    fuzzy_match=fuzzy_match,\
    sort_strings=sort_strings,\
}\
",
  [ "objects/text/graphic" ] = "return function(object)\
    if object.text then\
        object:update(object.text)\
        object.text()\
    end\
end",
  [ "a-tools/object-base" ] = "--[[\
    ! this file doesnt do anything !\
    * it shows how to make a propper new object.lua\
    * for your own custom elements\
]]\
\
local api = require(\"api\")\
\
return function(object,data)\
    data = data or {}\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(data.reactive) ~= \"boolean\" then data.reactive = true end\
    local base = {\
        name=data.name or api.uuid4(),\
        visible=data.visible,\
        reactive=data.reactive,\
        react_to_events={}, --*events that the object should run logic.lua on. LUT\
        btn={}, --*buttons that the object should run logic.lua on. LUT\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
    }\
    return base\
end",
  [ "objects/switch/object" ] = "local api = require(\"api\")\
\
return function(object,data)\
    data = data or {}\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(data.reactive) ~= \"boolean\" then data.reactive = true end\
    local btn = {\
        name=data.name or api.uuid4(),\
        positioning = {\
            x=data.x or 1,\
            y=data.y or 1,\
            width=data.width or 0,\
            height=data.height or 0\
        },\
        on_change_state=data.on_change_state or function() end,\
        background_color = data.background_color or object.term_object.getBackgroundColor(),\
        background_color_on = data.background_color_on or object.term_object.getBackgroundColor(),\
        text_color = data.text_color or object.term_object.getTextColor(),\
        text_color_on = data.text_color_on or object.term_object.getTextColor(),\
        symbol=data.symbol or \" \",\
        texture = data.tex,\
        texture_on = data.tex_on,\
        text=data.text,\
        text_on=data.text_on,\
        visible=data.visible,\
        reactive=data.reactive,\
        react_to_events={\
            mouse_click=true,\
            monitor_touch=true\
        },\
        btn=data.btn,\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
        tags={},\
        value=(data.value ~= nil) and data.value or false\
    }\
    return btn\
end\
",
  [ "a-tools/blbfor" ] = "--[[\
    * BLBFOR - BLIT BYTE FORMAT\
    * a format used for storing blit data\
    * in a compact way\
    * 1 pixel == 2 bytes\
]]\
\
local EXPECT = require(\"cc.expect\").expect\
\
_ENV = _ENV.ORIGINAL\
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
    BLBFOR.INTERNAL.ASSERT(header == \"BLBFOR1\", \"Invalid header\",2)\
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
        stream.close()\
        error(\"invalid mode. please use \\\"w\\\" or \\\"r\\\" (Write/Read)\",2)\
    end\
end\
\
return BLBFOR\
",
  [ "objects/switch/logic" ] = "local api = require(\"api\")\
return function(object,event)\
    if api.is_within_field(\
        event.x,\
        event.y,\
        object.positioning.x,\
        object.positioning.y,\
        object.positioning.width,\
        object.positioning.height\
    ) then\
        object.value = not object.value\
        object.on_change_state(object,event)\
    end\
end ",
  [ "apis/log" ] = "_ENV = _ENV.ORIGINAL\
\
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
\
local index = {\
    error=1,\
    warn=2,\
    fatal=3,\
    success=4,\
    message=6,\
    update=7,\
    info=8\
}\
\
local revIndex = {}\
for k,v in pairs(index) do\
    revIndex[v] = k\
end\
\
local function remove_time(str)\
    local str = str:gsub(\"^%[%d-%:%d-% %a-]\",\"\")\
    return str\
end\
\
local function writeWrapped(termObj,str,bg,title)\
    local width,height = termObj.getSize()\
    local strings,maxLen = {},math.ceil(#str/width)\
    local last = 0\
    for i=1,maxLen do\
        local _,y = termObj.getCursorPos()\
        if y > height then\
            termObj.scroll(1)\
            termObj.setCursorPos(1,y-1)\
            y = y - 1\
        end\
        termObj.write(str:sub(last+1,i*width))\
        termObj.setCursorPos(1,y+1)\
        last=i*width\
    end\
    return maxLen\
end\
\
local function getLineLen(termObj,str)\
    local width = termObj.getSize()\
    local strings,maxLen = {},math.ceil(#str/width)\
    local last = 0\
    local strLen\
    for i=1,maxLen do\
        local strs = str:sub(last+1,i*width)\
        last=i*width\
        strLen = #strs\
    end\
    return strLen\
end\
\
function index:dump(path)\
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
        outputInternal[#outputInternal+1] = v.str..\"(\"..tostring(nstr)..\") type: \"..(revIndex[v.type] or \"info\")\
        lastLog = remove_time(v.str)..v.type\
    end\
    for k,v in ipairs(outputInternal) do\
        str = str .. v .. \"\\n\"\
    end\
    if type(path) == \"string\" then\
        local file = fs.open(path..\".log\",\"w\")\
        file.write(str)\
        file.close()\
    end\
    return str\
end\
\
local function write_to_log_internal(self,str,type)\
    local width,height = self.term.getSize()\
    local x,y = self.term.getCursorPos()\
    local str = tostring(str)\
    type = type or \"info\"\
    if self.lastLog == str..type then\
        self.nstr = self.nstr + 1\
        local yid = y-self.maxln\
        self.term.setCursorPos(x,yid)\
    else\
        self.nstr = 1\
    end\
    self.lastLog = str..type\
    local timeStr = \"[\"..textutils.formatTime(os.time())..\"] \"\
    local tb,tt = self.term.getBackgroundColor(),self.term.getTextColor()\
    local lFg,lBg = unpack(typeList[type] or {})\
    self.term.setBackgroundColor(lBg or tb);self.term.setTextColor(lFg or colors.gray)\
    local strse = timeStr..str..\"(\"..tostring(self.nstr)..\")\"\
    local len = #strse\
    if len < 1 then len = 1 end\
    local wlen = width-len\
    if wlen < 1 then wlen = 1 end\
    wlen = width-(getLineLen(self.term,strse))\
    local strWrt = timeStr..str..(\" \"):rep(wlen)\
    table.insert(self.history,{\
        str=strWrt,\
        type=type\
    })\
    self.maxln = writeWrapped(self.term,strWrt..\"(\"..tostring(self.nstr)..\")\",tb,self.title)\
    local x,y = self.term.getCursorPos()\
    self.term.setBackgroundColor(self.sbg);self.term.setTextColor(self.sfg) \
    if self.title then\
        self.term.setCursorPos(1,1)\
        self.term.write((self.tsym):rep(width))\
        self.term.setCursorPos(math.ceil((width / 2) - (#self.title / 2)), 1)\
        self.term.write(self.title)\
        self.term.setCursorPos(x,y)\
    end\
    self.term.setBackgroundColor(tb);self.term.setTextColor(tt) \
end\
\
local function createLogInternal(termObj,title,titlesym,auto_dump,file)\
    titlesym = titlesym or \"-\"\
    local width,height = termObj.getSize()\
    local log = setmetatable({\
        lastLog=\"\",\
        nstr=1,\
        maxln=1,\
        term=termObj,\
        history={},\
        title = title,\
        tsym=(#titlesym < 4) and titlesym or \"-\",\
        sbg=termObj.getBackgroundColor(),\
        sfg=termObj.getTextColor(),\
        auto_dump=auto_dump\
    },{\
        __index=index,\
        __call=write_to_log_internal\
    })\
    if log.title then\
        log.term.setCursorPos(1,1)\
        log.term.write((log.tsym):rep(width))\
        log.term.setCursorPos(math.ceil((width / 2) - (#log.title / 2)), 1)\
        log.term.write(log.title)\
        log.term.setCursorPos(1,2)\
    end\
    log.lastLog = nil\
    return log\
end\
\
return {create_log=createLogInternal}\
",
  [ "objects/ellipse/object" ] = "local api = require(\"api\")\
\
local types = {\
    [\"left-right\"]=true,\
    [\"right-left\"]=true,\
    [\"top-down\"]=true,\
    [\"down-top\"]=true,\
}\
\
return function(object,data)\
    data = data or {}\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(object.symbols) ~= \"table\" then data.symbols = {} end\
    if type(data.filled) ~= \"boolean\" then data.filled = true end\
    local btn = {\
        name=data.name or api.uuid4(),\
        positioning = {\
            x=data.x or 1,\
            y=data.y or 1,\
            width=data.width or 1,\
            height=data.height or 1\
        },\
        symbol=data.symbol or \" \",\
        bg=data.background_color or colors.white,\
        fg=data.text_color or colors.black,\
        visible=data.visible,\
        filled=data.filled,\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
    }\
    return btn\
end\
",
  [ "objects/inputbox/logic" ] = "local api = require(\"api\")\
\
local function depattern(str)\
    return str:gsub(\"[%[%]%(%)%.%+%-%%%$%^%*%?]\", \"%%%1\")\
end\
\
\
local function likeness(str1,str2,give_default)\
    local likeness = 0\
    local len1 = string.len(str1)\
    local len2 = string.len(str2)\
    local minlen = math.min(len1, len2)\
    if str1 == str2 then return 0 end\
    if len1 == 0 and give_default then return 0.4 end\
    for i = 1, minlen do\
        if str1:sub(i, i) == str2:sub(i, i) then\
            likeness = likeness + 1\
        end\
    end\
    return likeness\
end\
\
local function get_keys(array)\
    local temp = {}\
    for k,v in pairs(array) do\
        temp[#temp+1] = {key=k,value=v}\
    end\
    return temp\
end\
\
local function sort_strings_likeness(input,string_array)\
    local strings_likeness = {}\
    local out = {}\
    local give_default = string_array.show_default\
    local zero_likeness = {}\
    for k,v in ipairs(string_array) do\
        local likeness = likeness(input,v,give_default)\
        if likeness > 0 and type(k) == \"number\" then\
            if strings_likeness[likeness] then table.insert(strings_likeness[likeness],v)\
            else strings_likeness[likeness] = {v} end\
        else table.insert(zero_likeness,v) end\
    end\
    local keys = get_keys(strings_likeness)\
    table.sort(keys,function(a,b) return a.key > b.key end)\
    for k,v in ipairs(keys) do\
        for _k,_v in ipairs(v.value) do\
            table.insert(out,_v)\
        end\
    end\
    local out_len = table.getn(out)\
    for k,v in pairs(zero_likeness) do out[1+out_len+k] = v end\
    return out\
end\
\
return function(object,event)\
    local term = object.canvas.term_object\
    if event.name == \"mouse_click\" then\
        if api.is_within_field(\
            event.x,\
            event.y,\
            object.positioning.x,\
            object.positioning.y,\
            object.positioning.width+1,\
            1\
        ) then\
            if object.selected then\
                object.cursor_pos = math.min(object.cursor_pos + (event.x-object.cursor_x),#object.input)\
            else\
                object.cursor_pos = object.old_cursor or 0\
                object.on_change_select(object,event,true)\
            end\
            object.selected = true\
        else\
            if object.selected then\
                object.on_change_select(object,event,false)\
                object.old_cursor = object.cursor_pos\
                object.cursor_pos = -math.huge\
            end\
            object.selected = false\
        end\
    end\
    local a = object.input:sub(1,object.cursor_pos)\
    local b = object.input:sub(object.cursor_pos+1,#object.input)\
    if next(object.autoc.strings) or next(object.autoc.spec_strings) and object.selected then\
        local search_string = depattern(a):match(\"%S+$\") or \"\"\
        local search_string = search_string:gsub(\"%%(.)\", \"%1\")\
        local array = object.autoc.spec_strings[select(2,a:gsub(\"%W+\",\"\"))+1] or object.autoc.strings\
        if array then\
            local sorted = sort_strings_likeness(search_string,array)\
            object.autoc.sorted = sorted\
            if object.autoc.selected > #sorted then\
                object.autoc.selected = #sorted\
            end\
            if sorted[1] ~= search_string then\
                object.autoc.current = search_string\
                object.autoc.str_diff = object.autoc.sorted[object.autoc.selected]\
                if not object.autoc.str_diff then object.autoc.str_diff = \"\" end\
                object.autoc.current_likeness = likeness(search_string,object.autoc.str_diff)\
            end\
        end\
    end\
    if event.name == \"char\" and object.selected and event.character:match(object.pattern) then\
        if #object.input < object.char_limit then\
            if not object.insert then\
                object.input = a..event.character..b\
                object.cursor_pos = object.cursor_pos + 1\
            else\
                object.input = a..event.character..b:gsub(\"^.\",\"\")\
                object.cursor_pos = object.cursor_pos + 1\
            end\
            object.autoc.selected = 1\
            object.on_change_input(object,event,object.input)\
        end\
    end\
    if event.name == \"key_up\" and object.selected then\
        if event.key == keys.leftCtrl or event.key == keys.rightCtrl then\
            object.ctrl = false\
        end\
    end\
    if event.name == \"key\" and object.selected then\
        if event.key == keys.leftCtrl or event.key == keys.rightCtrl then\
            object.ctrl = true\
        elseif event.key == keys.backspace then\
            object.input = a:gsub(\".$\",\"\")..b\
            object.autoc.selected = 1\
            object.cursor_pos = math.max(object.cursor_pos-1,0)\
            object.on_change_input(object,event,object.input)\
        elseif event.key == keys.left then\
            if not object.ctrl then object.cursor_pos = math.max(object.cursor_pos-1,0)\
            else\
                local diff = a:reverse():find(\" \")\
                object.cursor_pos = diff and #a-diff or 0\
            end\
        elseif  event.key == keys.right then\
            if not object.ctrl then object.cursor_pos = math.min(math.max(object.cursor_pos+1,0),#object.input)\
            else\
                local diff = b:sub(2,#b):find(\" \")\
                object.cursor_pos = diff and diff+#a or #object.input\
            end\
        elseif event.key == keys.tab and not object.ignore_tab and not event.held and (next(object.autoc.strings) or next(object.autoc.spec_strings) and object.selected) then\
            local diff = #object.autoc.str_diff-#object.autoc.current\
            local res = object.input:gsub(object.autoc.current..\"$\",object.autoc.str_diff)\
            if #res <= object.char_limit and object.cursor_pos >= #object.input then\
                if object.autoc.put_space then\
                    object.input = res..\" \"\
                    object.cursor_pos = object.cursor_pos + diff + 1\
                else\
                    object.input = res\
                    object.cursor_pos = object.cursor_pos + diff\
                end\
                object.autoc.sorted = {}\
                object.autoc.str_diff = \"\"\
                object.on_change_input(object,event,object.input)\
            end\
        elseif event.key == keys.home then\
            object.cursor_pos = 0\
        elseif event.key == keys[\"end\"] then\
            object.cursor_pos = #object.input\
        elseif event.key == keys.delete then\
            object.input = a..b:gsub(\"^.\",\"\")\
            object.autoc.selected = 1\
            object.on_change_input(object,event,object.input)\
        elseif event.key == keys.insert and not event.held then\
            object.insert = not object.insert\
        elseif event.key == keys.down then\
            if object.autoc.selected+1 <= #object.autoc.sorted then\
                object.autoc.selected = object.autoc.selected + 1\
            end\
        elseif event.key == keys.up then\
            if object.autoc.selected > 1 then\
                object.autoc.selected = object.autoc.selected - 1\
            end\
        elseif event.key == keys.enter and object.selected then\
            local arguments = {}\
            object.input:gsub(\"%S+\",function(str) table.insert(arguments,str) end)\
            object.on_enter(object,event,arguments)\
        end\
    end\
    if event.name == \"paste\" then\
        object.autoc.selected = 1\
        object.input = a..event.text..b\
        object.cursor_pos = object.cursor_pos+#event.text\
        object.on_change_input(object,event,object.input)\
    end\
end",
  api = "--[[\
    * this file includes general usage functions so i wont\
    * explain them. i use this file almost everywhere and\
    * cause it has some useful stuff\
]]\
\
_ENV = _ENV.ORIGINAL\
\
local function is_within_field(x,y,start_x,start_y,width,height)\
    return x >= start_x and x < start_x+width and y >= start_y and y < start_y+height\
end\
\
local HSVToRGB = function(hue, saturation, value)\
    if saturation == 0 then return value, value, value end\
    local hue_sector = math.floor(hue / 60)\
    local hue_sector_offset = (hue / 60) - hue_sector\
    local p = value * (1 - saturation)\
    local q = value * (1 - saturation * hue_sector_offset)\
    local t = value * (1 - saturation * (1 - hue_sector_offset))\
    if hue_sector == 0 then return value, t, p\
    elseif hue_sector == 1 then return q, value, p\
    elseif hue_sector == 2 then return p, value, t\
    elseif hue_sector == 3 then return p, q, value\
    elseif hue_sector == 4 then return t, p, value\
    elseif hue_sector == 5 then return value, p, q end\
end\
\
local function createNDarray(n, tbl)\
    tbl = tbl or {}\
    if n == 0 then return tbl end\
    setmetatable(tbl, {__index = function(t, k)\
        local new = createNDarray(n - 1)\
        t[k] = new\
        return new\
    end})\
    return tbl\
end\
\
local create2Darray = function(tbl)\
    return setmetatable(tbl or {},\
        {\
            __index=function(t,k)\
                local new = {}\
                t[k]=new\
                return new\
            end\
        }\
    )\
end\
\
local create3Darray = function(tbl)\
    return setmetatable(tbl or {},\
        {\
            __index=function(t,k)\
                local new = create2Darray()\
                t[k]=new\
                return new\
            end\
        }\
    )\
end\
\
local function merge_tables(...)\
    local out = {}\
    for k,v in pairs({...}) do\
        for _k,_v in pairs(v) do table.insert(out,_v) end\
    end\
    return out\
end\
\
local function interpolateY(a,b,y)\
    local ya = y - a.y\
    local ba = b.y - a.y\
    local x = a.x + (ya * (b.x - a.x)) / ba\
    local z = a.z + (ya * (b.z - a.z)) / ba\
    return x,z\
end\
\
local function interpolateZ(a,b,x)\
    local z = a.z + (x-a.x) * (((b.z-a.z)/(b.x-a.x)))\
    return z\
end\
\
local function interpolateOnLine(x1, y1, w1, x2, y2, w2, x3, y3)\
    local fxy1=(x2-x3)/(x2-x1)*w1+(x3-x1)/(x2-x1)*w2\
    return (y2-y3)/(y2-y1)*fxy1+(y3-y1)/(y2-y1)*fxy1\
end\
\
local function switchXYArray(array)\
    local output = createSelfIndexArray()\
    for x,yout in pairs(array) do\
        if type(yout) == \"table\" then\
            for y,val in pairs(yout) do\
                output[y][x] = val\
            end\
        end\
    end\
    return output\
end\
\
local getTrueTableLen = function(tbl)\
    local realLen = 0\
    for k,v in pairs(tbl) do\
        realLen = realLen + 1\
    end\
    return realLen,#tbl\
end\
\
local compareTable = function(tbl1,tbl2)\
    local isMatching = true\
    local tbl1Len = getTrueTableLen(tbl1)\
    local tbl2Len = getTrueTableLen(tbl2)\
    for k,v in pairs(tbl1) do\
        if v ~= tbl2[k] then\
            isMatching = false\
        end\
    end\
    if isMatching and tbl1Len == tbl2Len then\
        return true\
    end\
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
local function iterate_order(tbl)\
    local indice = 0\
    local keys = keys(tbl)\
    table.sort(keys, function(a, b) return a<b end)\
    return function()\
        indice = indice + 1\
        if tbl[keys[indice]] then return keys[indice],tbl[keys[indice]]\
        else return end\
    end\
end\
\
local function uuid4()\
    local random = math.random\
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'\
    return string.gsub(template, '[xy]', function (c)\
        return string.format('%x', c == 'x' and random(0, 0xf) or random(8, 0xb))\
    end)\
end\
\
local function precise_sleep(t)\
    local ftime = os.epoch(\"utc\")+t*1000\
    while os.epoch(\"utc\") < ftime do\
        os.queueEvent(\"waiting\")\
        os.pullEvent()\
    end\
end\
\
local function piece_string(str)\
    local out = {}\
    str:gsub(\".\",function(c)\
        table.insert(out,c)\
    end)\
    return out\
end\
\
local function create_blit_array(count)\
    local out = {}\
    for i=1,count do\
        out[i] = {\"\",\"\",\"\"}\
    end\
    return out\
end\
\
local events_with_cords = {\
    monitor_touch=true,\
    mouse_click=true,\
    mouse_drag=true,\
    mouse_scroll=true,\
    mouse_up=true\
}\
\
return {\
    is_within_field=is_within_field,\
    tables={\
        createNDarray=createNDarray,\
        get_true_table_len=getTrueTableLen,\
        compare_table=compareTable,\
        switchXYArray=switchXYArray,\
        create2Darray=create2Darray,\
        create3Darray=create3Darray,\
        iterate_order=iterate_order,\
        merge=merge_tables\
    },\
    math={\
        interpolateY=interpolateY,\
        interpolateZ=interpolateZ,\
        interpolate_on_line=interpolateOnLine\
    },\
    HSVToRGB=HSVToRGB,\
    uuid4=uuid4,\
    precise_sleep=precise_sleep,\
    piece_string=piece_string,\
    create_blit_array=create_blit_array,\
    events_with_cords=events_with_cords\
}",
  [ "objects/switch/graphic" ] = "local texture = require(\"graphic_handle\").code\
\
return function(object)\
    local term = object.canvas.term_object\
    local x,y = object.positioning.x,object.positioning.y\
    if not object.texture and not object.texture_on then\
        term.setBackgroundColor(object.value and object.background_color_on or object.background_color)\
        term.setTextColor(object.value and object.text_color_on or object.text_color)\
        for i=y,object.positioning.height+y-1 do\
            term.setCursorPos(x,i)\
            term.write(object.symbol:rep(object.positioning.width))\
        end\
    else\
        texture.draw_box_tex(\
            term,\
            (object.value and object.texture_on or object.texture) or (object.texture or object.texture_on),\
            object.positioning.x,\
            object.positioning.y,\
            object.positioning.width,\
            object.positioning.height,\
            (object.value and object.background_color_on or object.background_color) or colors.red,\
            (object.value and object.text_color_on or object.text_color) or colors.black,nil,nil,\
            object.canvas.texture_cache\
        )\
    end\
    if object.text and ((not object.value ) or not object.text_on) then\
        object.text(term,object.positioning.x,object.positioning.y,object.positioning.width,object.positioning.height)\
    elseif object.text_on and object.value then\
        object.text_on(term,object.positioning.x,object.positioning.y,object.positioning.width,object.positioning.height)\
    end\
end\
",
  [ "objects/scrollbox/object" ] = "local api = require(\"api\")\
return function(object,data)\
    data = data or {}\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(data.reactive) ~= \"boolean\" then data.reactive = true end\
    local base = {\
        name=data.name or api.uuid4(),\
        positioning = {\
            x=data.x or 1,\
            y=data.y or 1,\
            width=data.width or 1,\
            height=data.height or 1\
        },\
        visible=data.visible,\
        reactive=data.reactive,\
        react_to_events={[\"mouse_scroll\"]=true},\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
        value=data.value or 1,\
        limit_min=data.limit_min or -math.huge,\
        limit_max=data.limit_max or math.huge,\
        on_change_value=data.on_change_value or function() end,\
        on_up=data.on_up or function() end,\
        on_down=data.on_down or function() end\
    }\
    return base\
end",
  [ "apis/termtools" ] = "--[[\
    * this file will have various tools\
    * and utilities for working with term objects\
]]\
\
_ENV = _ENV.ORIGINAL\
\
local function mirror_monitors(base,...)\
    local mons = {...}\
    local out = {}\
    for fname,_ in pairs(mons[1]) do\
        out[fname] = function(...)\
            local ret = table.pack(base[fname](...))\
            for k,mon in pairs(mons) do\
                ret = table.pack(mon[fname](...))\
            end\
            return table.unpack(ret,1,ret.n or 1)\
        end\
    end\
    return out\
end\
\
local function make_shared_terminal(...)\
    local mons = {...}\
    local out = {}\
    for fname,_ in pairs(mons[1]) do\
        out[fname] = function(...)\
            local ret = {}\
            for k,mon in pairs(mons) do\
                ret = table.pack(mon[fname](...))\
            end\
            return table.unpack(ret,1,ret.n or 1)\
        end\
    end\
    return out\
end\
\
return {\
    mirror_monitors=mirror_monitors,\
    make_shared_terminal=make_shared_terminal\
}\
",
  [ "objects/script/graphic" ] = "return function(object,event)\
    object.graphic(object,event)\
end",
  [ "objects/group/graphic" ] = "return function(object)\
    object.window.redraw()\
end",
  [ "objects/circle/object" ] = "local api = require(\"api\")\
\
local types = {\
    [\"left-right\"]=true,\
    [\"right-left\"]=true,\
    [\"top-down\"]=true,\
    [\"down-top\"]=true,\
}\
\
return function(object,data)\
    data = data or {}\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(object.symbols) ~= \"table\" then data.symbols = {} end\
    if type(data.filled) ~= \"boolean\" then data.filled = true end\
    local btn = {\
        name=data.name or api.uuid4(),\
        positioning = {\
            x=data.x or 1,\
            y=data.y or 1,\
            radius=data.radius or 3\
        },\
        symbol=data.symbol or \" \",\
        bg=data.background_color or colors.white,\
        fg=data.text_color or colors.black,\
        visible=data.visible,\
        filled=data.filled,\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
    }\
    return btn\
end\
",
  [ "apis/text" ] = "_ENV = _ENV.ORIGINAL\
\
local expect = require(\"cc.expect\").expect\
\
local function wrap_text(str,lenght,nnl)\
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
                    if #(line..cur) > lenght then words[1] = wrap_text(cur..rest,lenght,true) break end\
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
local function cut_parts(str,part_size)\
    expect(1,str,\"string\")\
    expect(2,part_size,\"number\")\
    local parts = {}\
    local part = \"\"\
    for c in str:gmatch(\".\") do\
        if #part + #c <= part_size then part = part .. c\
        else\
            table.insert(parts,part)\
            part = c\
        end\
    end\
    table.insert(parts,part)\
    return parts\
end\
\
local function ensure_size(str,width)\
    expect(1,str,\"string\")\
    expect(2,width,\"number\")\
    local f_line = str:sub(1, width)\
    if #f_line < width then\
        f_line = f_line .. (\" \"):rep(width-#f_line)\
    end\
    return f_line\
end\
\
local function newline(tbl)\
    expect(1,tbl,\"table\")\
    return table.concat(tbl,\"\\n\")\
end\
\
return {\
    wrap = wrap_text,\
    cut_parts = cut_parts,\
    ensure_size = ensure_size\
}\
",
  [ "objects/triangle/logic" ] = "return function()\
end\
",
  [ "objects/scrollbox/logic" ] = "local api = require(\"api\")\
\
return function(object,event)\
    if api.is_within_field(\
        event.x,\
        event.y,\
        object.positioning.x,\
        object.positioning.y,\
        object.positioning.width,\
        object.positioning.height\
    ) then\
        if event.direction == -1 then\
            object.value = object.value + 1\
            if object.value > object.limit_max then object.value = object.limit_max end\
            object.on_change_value(object)\
            object.on_up(object)\
        elseif event.direction == 1 then\
            object.value = object.value - 1\
            if object.value < object.limit_min then object.value = object.limit_min end\
            object.on_change_value(object)\
            object.on_down(object)\
        end\
    end\
end",
  [ "objects/rectangle/object" ] = "local api = require(\"api\")\
\
local types = {\
    [\"left-right\"]=true,\
    [\"right-left\"]=true,\
    [\"top-down\"]=true,\
    [\"down-top\"]=true,\
}\
\
return function(object,data)\
    data = data or {}\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(data.symbols) ~= \"table\" then data.symbols = {} end\
    local btn = {\
        name=data.name or api.uuid4(),\
        positioning = {\
            x=data.x or 1,\
            y=data.y or 1,\
            width=data.width or 0,\
            height=data.height or 0\
        },\
        visible=data.visible,\
        color=data.color or colors.white,\
        filled=data.filled,\
        symbols={\
            [\"top_left\"]=data.symbols.top_left or {sym=\" \",bg=data.color or colors.white,fg=colors.black},\
            [\"top_right\"]=data.symbols.top_right or {sym=\" \",bg=data.color or colors.white,fg=colors.black},\
            [\"bottom_left\"]=data.symbols.bottom_left or {sym=\" \",bg=data.color or colors.white,fg=colors.black},\
            [\"bottom_right\"]=data.symbols.bottom_right or {sym=\" \",bg=data.color or colors.white,fg=colors.black},\
            [\"side_left\"]=data.symbols.side_left or {sym=\" \",bg=data.color or colors.white,fg=colors.black},\
            [\"side_right\"]=data.symbols.side_right or {sym=\" \",bg=data.color or colors.white,fg=colors.black},\
            [\"side_top\"]=data.symbols.side_top or {sym=\" \",bg=data.color or colors.white,fg=colors.black},\
            [\"side_bottom\"]=data.symbols.side_bottom or {sym=\" \",bg=data.color or colors.white,fg=colors.black},\
            [\"inside\"]=data.symbols.inside or {sym=\" \",bg=data.color or colors.white,fg=colors.black}\
        },\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
    }\
    return btn\
end\
",
  graphic_handle = "--[[\
    * this file is used for drawing and texturing\
    * it loads textures. converts into nimg,\
    * and draws them\
]]\
\
local decode_ppm = require \"a-tools.luappm\"\
local decode_blbfor =  require \"a-tools.blbfor\".open\
local api = require \"api\"\
\
_ENV = _ENV.ORIGINAL\
\
local expect = require \"cc.expect\"\
\
local chars = \"0123456789abcdef\"\
local saveCols, loadCols = {}, {}\
\
--* create 2 table used for decoding and encoding blit\
for i = 0, 15 do\
    saveCols[2^i] = chars:sub(i + 1, i + 1)\
    loadCols[chars:sub(i + 1, i + 1)] = 2^i\
end\
\
--* this function is used for decoding .nimg files\
--* its actually just converting blit to numbers.\
local decode = function(tbl)\
    local output = api.tables.createNDarray(2)\
    output[\"offset\"] = tbl[\"offset\"]\
    for k,v in pairs(tbl) do\
        for ko,vo in pairs(v) do\
            if type(vo) == \"table\" then\
                output[k][ko] = {}\
                if vo then\
                    output[k][ko].t = loadCols[vo.t]\
                    output[k][ko].b = loadCols[vo.b]\
                    output[k][ko].s = vo.s \
                end\
            end\
        end\
    end\
    return setmetatable(output,getmetatable(tbl))\
end\
\
--* this function will get width and height of an 2D array;;\
local function get2DarraySquareWH(array)\
    local minx, maxx = math.huge, -math.huge\
    local miny,maxy = math.huge, -math.huge\
    for x,yList in pairs(array) do\
        minx, maxx = math.min(minx, x), math.max(maxx, x)\
        for y,_ in pairs(yList) do\
            miny, maxy = math.min(miny, y), math.max(maxy, y)\
        end\
    end\
    return math.abs(minx)+maxx,math.abs(miny)+maxy\
end\
\
--* theese to functions are for finding closest key to an non existent key in a table\
local function index_proximal_small(list,num)\
    local diffirences = {}\
    local outs = {}\
    for k,v in pairs(list) do\
        local diff = math.abs(k-num)\
        diffirences[#diffirences+1],outs[diff] = diff,k\
    end\
    local proximal = math.min(table.unpack(diffirences))\
    return list[outs[proximal]]\
end\
local function index_proximal_big(list,num) --! credit to wojbie\
    if not next(list) then return nil end\
    if list[num] then return list[num] end\
    local cur = math.floor(num+0.5)\
    if list[cur] then return list[cur] end\
    for i=1,math.huge do\
        if list[cur+i] then return list[cur+i] end\
        if list[cur-i] then return list[cur-i] end\
    end\
end\
\
--* a function used to convert .nimg images into GuiH textures\
local function load_texture(file_name)\
\
    --* loads input/string file\
    local file,data\
    if not (type(file_name) == \"table\") and (file_name:match(\".nimg$\") and fs.exists(file_name)) then\
        file = fs.open(file_name,\"r\")\
        if not file then error(\"file doesnt exist\",2) end\
        data = textutils.unserialise(file.readAll())\
    else\
        data = file_name\
    end\
\
    --* decodes the nimg and converts it into a 2D map\
    --* creates an empty new 2D map\
    local nimg = api.tables.createNDarray(2,decode(data))\
    local temp = api.tables.createNDarray(2)\
\
    --* shifts the textur into the enw 2D map\
    for x,dat in pairs(nimg) do\
        if type(x) ~= \"string\" then\
            for y,data in pairs(dat) do\
                temp[x-nimg.offset[1]+1][y-nimg.offset[2]+5] = {\
                    text_color=data.t,\
                    background_color=data.b,\
                    symbol=data.s\
                }\
            end\
        end\
    end\
\
    --* gets the size of the new texture\
    temp.scale = {get2DarraySquareWH(temp)}\
\
    --* returns the new texture with its\
    --* dimensions,data,offset\
    return setmetatable({\
        tex=temp,\
        offset=nimg.offset,\
        id=api.uuid4()\
    },{__tostring=function() return \"GuiH.texture\" end})\
end\
\
--* a function so compec can shut up.\
local function load_cimg_texture(file_name)\
    local data\
    expect(1,file_name,\"string\",\"table\")\
    if type(file_name) == \"table\" then\
        data = file_name\
    else\
        local file = fs.open(file_name,\"r\")\
        assert(file,\"file doesnt exist\")\
        data = textutils.unserialise(file.readAll())\
        file.close()\
    end\
    local texture_raw = api.tables.createNDarray(2,{offset = {5, 13, 11, 4}})\
    for x,y_list in pairs(data) do\
        for y,c in pairs(y_list) do\
            texture_raw[x+4][y+7] = {\
                s=\" \",\
                b=c,\
                t=\"0\"\
            }\
        end\
    end\
    return load_texture(texture_raw)\
end\
\
\
local function load_blbfor_animation(file_name)\
    local ok,blit_file_handle = pcall(decode_blbfor,file_name,\"r\")\
    if not ok then error(blit_file_handle,3) end\
    local layers = {}\
    for layer_index=1,blit_file_handle.layers do\
        local texture_raw = api.tables.createNDarray(2,{offset = {5, 13, 11, 4}})\
        for x=1,blit_file_handle.width do\
            for y=1,blit_file_handle.height do\
                local char,fg,bg = blit_file_handle:read_pixel(layer_index,x,y,true)\
                texture_raw[x+4][y+8] = {\
                    s=char,\
                    b=bg,\
                    t=fg\
                }\
            end\
        end\
        layers[layer_index] = load_texture(texture_raw)\
    end\
    return layers\
end\
\
local function load_limg_animation(file_name,background)\
    background = background or colors.black\
    local file = fs.open(file_name,\"r\")\
    if not file then error(\"file doesnt exist\",2) end\
    local data = textutils.unserialise(file.readAll())\
    file.close()\
    assert(data.type==\"lImg\" or data.type == nil,\"not an limg image\")\
    local frames = {}\
    for frame,frame_data in pairs(data) do\
        if frame ~= \"type\" and frame_data ~= \"lImg\" then\
            local raw_texture = api.tables.createNDarray(2,{offset = {5, 13, 11, 4}}) \
            for y,blit in pairs(frame_data) do\
                local bg,fg,char = blit[3]:gsub(\"T\",saveCols[background]),blit[2]:gsub(\"T\",saveCols[background]),blit[1]\
                local bg_arr = api.piece_string(bg)\
                local fg_arr = api.piece_string(fg)\
                local char_arr = api.piece_string(char)\
                for n,c in pairs(char_arr) do\
                    raw_texture[n+4][y+8] = {\
                        s=c,\
                        b=bg_arr[n],\
                        t=fg_arr[n]\
                    }\
                end\
            end\
            frames[frame] = load_texture(raw_texture)\
        end\
    end\
    return frames\
end\
\
local function load_limg_texture(file_name,background,image)\
    local anim = load_limg_animation(file_name,background)\
    return anim[image or 1],anim\
end\
\
local function load_blbfor_texture(file_name)\
    local anim = load_blbfor_animation(file_name)\
    return anim[1],anim\
end\
\
--* finds the closest CC color to an RGB value\
--* with the current palette\
local function get_color(terminal,c)\
    local palette = {}\
\
    --* iterate over all the 16 colors in CC\
    for i=0,15 do\
\
        --* get the RGB values for the current CC color\
        local r,g,b = terminal.getPaletteColor(2^i)\
\
        --* use the distance formula to insert the current color\
        --* and its distance from desired color into the palette table\
        table.insert(palette,{\
            dist=math.sqrt((r-c.r)^2 + (g-c.g)^2 + (b-c.b)^2),\
            color=2^i\
        })\
    end\
\
    --* sort the palette table by distance\
    table.sort(palette,function(a,b) return a.dist < b.dist end)\
\
    --* return the closet color\
    return palette[1].color,palette[1].dist,palette\
end\
\
--* this function builds a CC drawing chracter from a list of 6 colors\
local function build_drawing_char(arr,mode)\
    local cols,fin,char,visited = {},{},{},{}\
    local entries = 0\
    \
    --* iterate over all the colors in the list\
    --* and figure out how many of each color there is\
    for k,v in pairs(arr) do\
        cols[v] = cols[v] ~= nil and\
            {count=cols[v].count+1,c=cols[v].c}\
            or (function() entries = entries + 1 return {count=1,c=v} end)()\
    end\
\
    --* we convert the colors into a format where they can be sorted.\
    --* we also make sure there are no duplicate entries.\
    --* if there is just one color in the entire list\
    --* we make a duplicate entry on purpose\
    for k,v in pairs(cols) do\
        if not visited[v.c] then\
            visited[v.c] = true\
            if entries == 1 then table.insert(fin,v) end\
            table.insert(fin,v)\
        end\
    end\
\
    --* sort the colors by count to find 2 most\
    --* common colors\
    table.sort(fin,function(a,b) return a.count > b.count end)\
\
    --* iterate over the 6 colors and if the colors in that spot\
    --* are same as in the array we keep them\
    --* if there is a color we cant fit then we make that pixel\
    --* be the most common color in that character\
    for k=1,6 do\
        if arr[k] == fin[1].c then char[k] = 1\
        elseif arr[k] == fin[2].c then char[k] = 0\
        else char[k] = mode and 0 or 1 end\
    end\
\
    --* then we just convert the list of 1s and 0s into a character with some magic\
    if char[6] == 1 then for i = 1, 5 do char[i] = 1-char[i] end end\
    local n = 128\
    for i = 0, 4 do n = n + char[i+1]*2^i end\
\
    --* return the resulting data\
    return string.char(n),char[6] == 1 and fin[2].c or fin[1].c,char[6] == 1 and fin[1].c or fin[2].c\
end\
\
--* used for indexing 1D 2x3 table with x y cordinates\
local function set_symbols_xy(tbl,x,y,val)\
    tbl[x+y*2-2] = val\
    return tbl\
end\
\
--* uses the previous functions and the LuaPPM lib to load .ppm textures\
local function load_ppm_texture(terminal,file,mode,log)\
    local _current = term.current()\
    log(\"loading ppm texture.. \",log.update)\
    log(\"decoding ppm.. \",log.update)\
\
    --* we load the image file and also decode it using LuaPPM\
    local img = decode_ppm(file)\
    log(\"decoding finished. \",log.success)\
    \
    --* if this image is valid then we continue\
    if img then\
        local char_arrays = {}\
        log(\"transforming pixels to characters..\",log.update)\
        \
        --* iterate over the imag pixels using its width and height\
        for x=1,img.width do\
            for y=1,img.height do\
\
                --* converts the pixels color into an CC color\
                local c = get_color(terminal or _current,img.get_pixel(x,y))\
\
                --* finds what character on the screen the pixel belongs to\
                local rel_x,rel_y = math.ceil(x/2),math.ceil(y/3)\
\
                --* finds where in that character will the pixel be placed\
                local sym_x,sym_y = (x-1)%2+1,(y-1)%3+1\
                \
                --* we use set_symbols_xy to add that pixel into our character at its cordiantes saved\
                --* in char_arrays, which is a table of character color data\
                if not char_arrays[rel_x] then char_arrays[rel_x] = {} end\
                char_arrays[rel_x][rel_y] = set_symbols_xy(char_arrays[rel_x][rel_y] or {},sym_x,sym_y,c)\
\
                --* pullEvent to prevent too long wihnout yielding error\
                os.queueEvent(\"\")\
                os.pullEvent(\"\")\
            end\
        end\
        log(\"transformation finished. \"..tostring((img.width/2)*(img.height/3))..\" characters\",log.success)\
\
        --* we create a new empty .nimg texture\
        local texture_raw = api.tables.createNDarray(2,{\
            offset = {5, 13, 11, 4}\
        })\
\
        log(\"building nimg format..\",log.update)\
\
        --* iterate over the char_arrays table and build the nimg texture\
        for x,yList in pairs(char_arrays) do\
            for y,sym_data in pairs(yList) do\
                local char,fg,bg = build_drawing_char(sym_data,mode)\
                texture_raw[x+4][y+8] = {\
                    s=char,\
                    t=saveCols[fg],\
                    b=saveCols[bg]\
                }\
            end\
        end\
        log(\"building finished. texture loaded.\",log.success)\
        log(\"\")\
        log:dump()\
\
        --* at last we use load_texture to convert it to GuiH texture\
        --* and then we return it along with the decoded PPM image\
        return setmetatable(load_texture(texture_raw),{__tostring=function() return \"GuiH.texture\" end}),img\
    end\
end\
\
--* function used to get a single character in an GuiH texture\
local function get_pixel(x,y,tex,fill_empty)\
    local texture = tex.tex\
\
    --* calculate the width and height of the texture\
    local w,h = math.floor(texture.scale[1]-0.5),math.floor(texture.scale[2]-0.5)\
\
    --* modulo the x,y by the width,height in case the x,y goes of the texture\
    x = ((x-1)%w)+1\
    y = ((y-1)%h)+1\
\
    --* read that pixel from the texture\
    local pixel = texture[x][y]\
\
    --* then we move the scale data into a termorary placed\
    --* so we can use index_proximal_ small/big\
    local scale = texture.scale\
    texture.scale = nil\
\
    --* we can use index_proximal to fill in empty gaps in the texture if we want to.\
    if not pixel and fill_empty then\
        --* we find pixel with the closest x cordinate to our\
        local x_proximal = index_proximal_small(texture,x)\
\
        --* we find pixel with the closest y cordinate to our in x_proximal\
        --* and save that pixel\
        pixel = index_proximal_big(x_proximal or {},y)\
    end\
\
    --* we put the scale data back\
    texture.scale = scale\
\
    --* and return our desired pixel\
    return pixel\
end\
\
local function draw_box_tex(term,tex,x,y,width,height,bg,tg,offsetx,offsety,cache)\
    local bg_layers,fg_layers,text_layers = {},{},{}\
    offsetx,offsety = offsetx or 0,offsety or 0\
\
    --* we first iterate over the texture to loada it into blit data\
    local same_args = false\
    if type(cache) == \"table\" and cache[tex.id] then\
        local c = cache[tex.id].args\
        same_args = c.x == x\
                and c.y == y\
                and c.width == width\
                and c.height == height\
                and c.bg == bg\
                and c.tg == tg\
                and c.offsetx == offsetx\
                and c.offsety == offsety\
    end\
    if type(cache) == \"table\" and cache[tex.id] and same_args then\
        bg_layers = cache[tex.id].bg_layers\
        fg_layers = cache[tex.id].fg_layers\
        text_layers = cache[tex.id].text_layers\
    else\
        for yis=1,height do\
            for xis=1,width do\
                local pixel = get_pixel(xis+offsetx,yis+offsety,tex)\
                if pixel and next(pixel) then\
                    bg_layers[yis] = (bg_layers[yis] or \"\")..saveCols[pixel.background_color]\
                    fg_layers[yis] = (fg_layers[yis] or \"\")..saveCols[pixel.text_color]\
                    text_layers[yis] = (text_layers[yis] or \"\")..pixel.symbol:match(\".$\")\
                else\
                    bg_layers[yis] = (bg_layers[yis] or \"\")..saveCols[bg]\
                    fg_layers[yis] = (fg_layers[yis] or \"\")..saveCols[tg]\
                    text_layers[yis] = (text_layers[yis] or \"\")..\" \"\
                end\
            end\
        end\
        if type(cache) == \"table\" then\
            cache[tex.id] = {\
                bg_layers = bg_layers,\
                fg_layers = fg_layers,\
                text_layers = text_layers,\
                args={\
                    term=term,x=x,y=y,width=width,height=height,bg=bg,tg=tg,offsetx=offsetx,offsety=offsety\
                }\
            }\
        end\
    end\
    --* then we draw the blit data to the screen\
    for k,v in pairs(bg_layers) do\
        term.setCursorPos(x,y+k-1)\
        term.blit(text_layers[k],fg_layers[k],bg_layers[k])\
    end\
end\
\
return {\
    load_nimg_texture=load_texture,\
    load_ppm_texture=load_ppm_texture,\
    load_cimg_texture=load_cimg_texture,\
    load_blbfor_texture=load_blbfor_texture,\
    load_blbfor_animation=load_blbfor_animation,\
    load_limg_texture=load_limg_texture,\
    load_limg_animation=load_limg_animation,\
    code={\
        get_pixel=get_pixel,\
        draw_box_tex=draw_box_tex,\
        to_blit=saveCols,\
        to_color=loadCols,\
        build_drawing_char=build_drawing_char\
    },\
    load_texture=load_texture\
}\
",
  [ "objects/button/object" ] = "local api = require(\"api\")\
\
return function(object,data)\
    data = data or {}\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(data.reactive) ~= \"boolean\" then data.reactive = true end\
    local btn = {\
        name=data.name or api.uuid4(),\
        positioning = {\
            x=data.x or 1,\
            y=data.y or 1,\
            width=data.width or 0,\
            height=data.height or 0\
        },\
        on_click=data.on_click or function() end,\
        background_color = data.background_color or object.term_object.getBackgroundColor(),\
        text_color = data.text_color or object.term_object.getTextColor(),\
        symbol=data.symbol or \" \",\
        texture = data.tex,\
        text=data.text,\
        visible=data.visible,\
        reactive=data.reactive,\
        react_to_events={\
            mouse_click=true,\
            monitor_touch=true,\
        },\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
        tags={},\
        btn=data.btn,\
        value=(data.value ~= nil) and data.value or true\
    }\
    return btn\
end\
",
  [ "objects/scrollbox/graphic" ] = "return function()\
end\
",
  installer = "fs.makeDir(\"GuiH\")\
fs.makeDir(\"GuiH/a-tools\")\
fs.makeDir(\"GuiH/objects\")\
fs.makeDir(\"GuiH/apis/\")\
fs.makeDir(\"GuiH/apis/fonts.7sh\")\
fs.makeDir(\"GuiH/presets\")\
fs.makeDir(\"GuiH/presets/rect\")\
fs.makeDir(\"GuiH/presets/tex\")\
\
local github_api = http.get(\
\9\"https://api.github.com/repos/9551-Dev/GuiH/git/trees/main?recursive=1\",\
\9_G._GIT_API_KEY and {Authorization = 'token ' .. _G._GIT_API_KEY}\
)\
\
local list = textutils.unserialiseJSON(github_api.readAll())\
local ls = {}\
local len = 0\
github_api.close()\
for k,v in pairs(list.tree) do\
    if v.type == \"blob\" and v.path:lower():match(\".+%.lua\") then\
        ls[\"https://raw.githubusercontent.com/9551-Dev/GuiH/main/\"..v.path] = v.path\
        len = len + 1\
    end\
end\
local percent = 100/len\
local finished = 0\
local size_gained = 0\
local downloads = {}\
for k,v in pairs(ls) do\
    table.insert(downloads,function()\
        local web = http.get(k)\
        local file = fs.open(\"./GuiH/\"..v,\"w\")\
        file.write(web.readAll())\
        file.close()\
        web.close()\
        finished = finished + 1\
        local file_size = fs.getSize(\"./GuiH/\"..v)\
        size_gained = size_gained + file_size\
        print(\"downloading \"..v..\"  \"..tostring(math.ceil(finished*percent))..\"% \"..tostring(math.ceil(file_size/1024*10)/10)..\"kB total: \"..math.ceil(size_gained/1024)..\"kB\")\
    end)\
end\
parallel.waitForAll(table.unpack(downloads))\
print(\"Finished downloading GuiH\")\
",
  [ "objects/inputbox/object" ] = "local api = require(\"api\")\
\
return function(object,data)\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(data.reactive) ~= \"boolean\" then data.reactive = true end\
    if not data.autoc then data.autoc = {} end\
    if type(data.autoc.put_space) ~= \"boolean\" then data.autoc.put_space = true end\
    local btn = {\
        name=data.name or api.uuid4(),\
        visible=data.visible,\
        reactive=data.reactive,\
        react_to_events={\
            [\"mouse_click\"]=true,\
            [\"monitor_touch\"]=true,\
            [\"char\"]=true,\
            [\"key\"]=true,\
            [\"key_up\"]=true,\
            [\"paste\"]=true\
        },\
        positioning = {\
            x=data.x or 1,\
            y=data.y or 1,\
            width=data.width or 0,\
        },\
        pattern=data.pattern or \".\",\
        selected=data.selected or false,\
        insert=false,\
        ctrl=false,\
        btn=data.btn,\
        cursor_pos=data.cursor_pos or 0,\
        char_limit = data.char_limit or data.width or math.huge,\
        input=\"\",\
        background_color = data.background_color or object.term_object.getBackgroundColor(),\
        text_color = data.text_color or object.term_object.getTextColor(),\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
        shift=0,\
        space_symbol=data.space_symbol or \"\\175\",\
        background_symbol=data.background_symbol or \" \",\
        on_change_select=data.on_change_select or function() end,\
        on_change_input=data.on_change_input or function() end,\
        on_enter=data.on_enter or function() end,\
        replace_char=data.replace_char,\
        ignore_tab = data.ignore_tab,\
        autoc={\
            strings=data.autoc.strings or {},\
            spec_strings=data.autoc.spec_strings or {},\
            bg=data.autoc.bg or data.background_color or object.term_object.getBackgroundColor(),\
            fg=data.autoc.fg or data.text_color or object.term_object.getTextColor(),\
            current=\"\",\
            selected=1,\
            put_space=data.autoc.put_space\
        }\
    }\
    btn.cursor_x = btn.positioning.x\
    return btn\
end",
  [ "objects/group/logic" ] = "return function(object,event)\
    object.bef_draw(object,event)\
end",
  [ "objects/triangle/object" ] = "local api = require(\"api\")\
\
local types = {\
    [\"left-right\"]=true,\
    [\"right-left\"]=true,\
    [\"top-down\"]=true,\
    [\"down-top\"]=true,\
}\
\
return function(object,data)\
    data = data or {}\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(object.symbols) ~= \"table\" then data.symbols = {} end\
    if type(data.filled) ~= \"boolean\" then data.filled = true end\
    if type(data.p1) ~= \"table\" then data.p1 = {} end\
    if type(data.p2) ~= \"table\" then data.p2 = {} end\
    if type(data.p3) ~= \"table\" then data.p3 = {} end\
    local btn = {\
        name=data.name or api.uuid4(),\
        positioning = {\
            p1 = {\
                x=data.p1[1] or 1,\
                y=data.p1[2] or 1\
            },\
            p2 = {\
                x=data.p2[1] or 1,\
                y=data.p2[2] or 1\
            },\
            p3 = {\
                x=data.p3[1] or 1,\
                y=data.p3[2] or 1\
            }\
        },\
        symbol=data.symbol or \" \",\
        bg=data.background_color or colors.white,\
        fg=data.text_color or colors.black,\
        visible=data.visible,\
        filled=data.filled,\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
    }\
    return btn\
end\
",
  init = "--* check for emulators\
if config then\
    if config.get(\"standardsMode\") == false then\
        print(\"WARNING: standardsMode is set to false, this is not supported by the GuiH API\")\
        print(\"Enter Y to enable standards mode, this will reboot the computer\")\
        local input = read()\
        if input:lower():match(\"y\") then\
            config.set(\"standardsMode\", true)\
            os.reboot()\
        else\
            error(\"GuiH cannot run without standards mode\",0)\
        end\
    end\
end\
\
\
local GuiH = require \"main\"\
return setmetatable(GuiH,{__tostring=function() return \"GuiH.API\" end})\
",
  [ "objects/inputbox/graphic" ] = "local graphic = require(\"graphic_handle\").code\
\
local function depattern(str)\
    return str:gsub(\"[%[%]%(%)%.%+%-%%%$%^%*%?]\", \"%%%1\")\
end\
\
return function(object)\
    local term = object.canvas.term_object\
    local text,mv = object.input,0\
    if #object.input >= object.positioning.width-1 then\
        text = object.input:sub(#object.input-object.positioning.width+1-object.shift,#object.input-object.shift)\
        mv = #object.input-#text\
    end\
    local cursor_x = (object.positioning.x+object.cursor_pos)-mv\
    term.setCursorPos(object.positioning.x,object.positioning.y)\
    local or_text = text\
    text = text:gsub(\" \",object.space_symbol)..object.background_symbol:rep(object.positioning.width-#text+1)\
    local rChar\
    if object.replace_char then\
        rChar = object.replace_char:rep(#or_text)..object.background_symbol:rep(object.positioning.width-#or_text+1)\
    end\
    term.blit(\
        rChar or text,\
        graphic.to_blit[object.text_color]:rep(#text),\
        graphic.to_blit[object.background_color]:rep(#text)\
    )\
    if object.selected and (object.char_limit > object.cursor_pos) then\
        term.setCursorPos(math.max(cursor_x+object.shift,object.positioning.x),object.positioning.y)\
        if cursor_x+object.shift < object.positioning.x then\
            object.shift = object.shift + 1\
        end\
        if cursor_x+object.shift > object.positioning.x+object.positioning.width then\
            object.shift = object.shift - 1\
        end\
        local cursor\
        if object.cursor_pos < object.positioning.width then\
            cursor = object.input:sub(object.cursor_pos+1,object.cursor_pos+1)\
            object.cursor_x = object.cursor_pos+1\
        else\
            cursor = object.input:sub(object.cursor_pos+1,object.cursor_pos+1)\
            term.setCursorPos(cursor_x+object.shift,object.positioning.y)\
        end\
        object.cursor_x = cursor_x+object.shift\
        term.blit(\
            (cursor) ~= \"\" and (object.replace_char or cursor) or \"_\",\
            cursor ~= \"\" and graphic.to_blit[object.background_color] or graphic.to_blit[object.text_color],\
            cursor ~= \"\" and graphic.to_blit[object.text_color] or graphic.to_blit[object.background_color]\
        )\
    else\
        term.setCursorPos(object.positioning.x+object.positioning.width,object.positioning.y)\
        term.blit(\
            \"\\127\",\
            graphic.to_blit[object.text_color],\
            graphic.to_blit[object.background_color]\
        )\
    end\
    if object.autoc.str_diff then\
        term.setCursorPos(object.cursor_x+object.shift,object.positioning.y)\
        local str = object.autoc.sorted[object.autoc.selected]\
        if str then\
            local mid = object.input:match(\"%S+$\") or \"\"\
            local diff = str:gsub(\"^\"..mid:gsub(\" $\",\"\"),\"\")\
            if object.cursor_pos >= #object.input then\
                local diff = diff:gsub(\"%%(.)\", \"%1\")\
                local max_x = object.positioning.x+object.positioning.width+1\
                local autoc_x = object.cursor_x+object.shift+#diff\
                if autoc_x > max_x and not object.autoc.ignore_width then\
                    local ndiff = autoc_x-max_x\
                    diff = diff:sub(1,#diff-ndiff)\
                end\
                term.blit(\
                    diff,\
                    graphic.to_blit[object.autoc.fg]:rep(#diff),\
                    graphic.to_blit[object.autoc.bg]:rep(#diff)\
                )\
            end\
        end\
    end\
end",
  [ "presets/rect/frame" ] = "return function(side,bg)\
    return {\
        top_left={sym=\"\\151\",bg=bg,fg=side},\
        top_right={sym=\"\\148\",bg=side,fg=bg},\
        bottom_left={sym=\"\\138\",bg=side,fg=bg},\
        bottom_right={sym=\"\\133\",bg=side,fg=bg},\
        side_left={sym=\"\\149\",bg=bg,fg=side},\
        side_right={sym=\"\\149\",bg=side,fg=bg},\
        side_top={sym=\"\\131\",bg=bg,fg=side},\
        side_bottom={sym=\"\\143\",bg=side,fg=bg},\
        inside={sym=\" \",bg=bg,fg=side}\
    }\
end",
  [ "objects/frame/graphic" ] = "return function(object)\
    object.on_graphic(object)\
end",
  [ "objects/text/logic" ] = "return function()\
end\
",
  [ "objects/circle/graphic" ] = "local algo = require(\"a-tools.algo\")\
local graphic = require(\"graphic_handle\").code\
local api = require(\"api\")\
\
return function(object)\
    local term = object.canvas.term_object\
    local draw_map = {}\
    local x_map = {}\
    local visited = api.tables.createNDarray(2)\
    if object.filled then\
        local points = algo.get_elipse_points(\
            object.positioning.radius,\
            math.ceil(object.positioning.radius-object.positioning.radius/3)+0.5,\
            object.positioning.x,\
            object.positioning.y,\
            true\
        )\
        for k,v in ipairs(points) do\
            if visited[v.x][v.y] ~= true then\
                draw_map[v.y] = (draw_map[v.y] or \"\")..\"*\"\
                x_map[v.y] = math.min(x_map[v.y] or math.huge,v.x)\
                visited[v.x][v.y] = true\
            end\
        end\
        for y,data in pairs(draw_map) do\
            term.setCursorPos(x_map[y],y)\
            term.blit(\
                data:gsub(\"%*\",object.symbol),\
                data:gsub(\"%*\",graphic.to_blit[object.fg]),\
                data:gsub(\"%*\",graphic.to_blit[object.bg])\
            )\
        end\
    else\
        local points = algo.get_elipse_points(\
            object.positioning.radius,\
            math.ceil(object.positioning.radius-object.positioning.radius/3)+0.5,\
            object.positioning.x,\
            object.positioning.y\
        )\
        for k,v in pairs(points) do\
            term.setCursorPos(v.x,v.y)\
            term.blit(\
                object.symbol,\
                graphic.to_blit[object.fg],\
                graphic.to_blit[object.bg]\
            )\
        end\
    end\
end",
  [ "a-tools/luappm" ] = "--[[\
    * this is the LuaPPM library\
    * its used for reading .ppm images exported from gimp\
]]\
_ENV = _ENV.ORIGINAL\
--* returns all bytes between the specified start and end\
local function read_characters(file,start,en)\
    local out = {}\
\
    --* reads all the bytes\
    for i=start,en do\
        file.seek(\"set\",i)\
        table.insert(out,file.read())\
    end\
\
    --* converts them into characters\
    return string.char(table.unpack(out))\
end\
\
--* this is used to get width,height,color type of an image\
local function get_meta(file,on)\
    local sekt = on\
    local out = {}\
\
    --* runs 3 times since we have 3 values to get\
    for i=1,3 do\
        \
        --* loops thru bytes until it gets an newline or space\
        --* and then merges them into one number\
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
--* reads all the pixel data from the image\
local function get_image_data(file,on,meta)\
    local sekt = on\
    local out = {}\
    local pixels = 0\
    file.seek(\"set\",on)\
\
    --* get the amount of color values in an image\
    while file.read() do pixels = pixels + 1 end\
\
    file.seek(\"set\",sekt)\
\
    --* runs the amount of times there is pixels in the image (each pixel has 3 values R,G,B so /3)\
    for i=1,math.floor(pixels/3) do\
        local data = \"\"\
\
        --* runs 3 times to retrieve all the 3 colors for that pixel\
        for i=1,3 do\
            \
            --* goes forward until it finds all the color data it needs\
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
            --* if there is no more data to find then stop the loop\
            if not next(full) then break end\
            table.insert(out,{r=full[1],g=full[2],b=full[3]})\
        end\
    end\
\
    --* returuns the array of all the pixels in the image\
    return out,pixels/3\
end\
\
--* this functions turns array of all the pixels and the image width anto an 2D array with the images data !\
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
\
--* makes use of all the functions so far to decode the image\
local function decode(_file)\
    local file = fs.open(_file,\"rb\")\
    if not file then error(\"File: \"..(_file or \"\")..\" doesnt exist\",3) end\
\
    --* reads the first 3 bytes and checks if it is a raw ppm file\
    if read_characters(file,0,2) == \"P6\\x0A\" then\
        local seek_offset = -math.huge\
        while true do\
            --* reads the first byte after \"magic number\"\
            local data = file.read()\
            --* if there is an comment it will loop\
            --* until it gets to the end of it\
            if string.char(data) == \"#\" then\
                while true do\
                    local cmt_part = file.read()\
                    if cmt_part == 0x0A then break end\
                    seek_offset = file.seek(\"cur\")+1\
                end\
            else\
                --* gets the metadata of the image\
                local meta,seek_offset = get_meta(file,seek_offset)\
\
                --* reads the color data\
                local _temp,pixels = get_image_data(file,seek_offset,meta)\
\
                --* turns the data into a 2D array of pixels\
                local data = process_to_2d_array(_temp,meta[1],true)\
\
                --* reads the total data in the file and closes it\
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
\
                    --* returns a pixel from the 2D array\
                    get_pixel=function(x,y)\
                        local y_list = data[math.floor(x+0.5)]\
                        if y_list then\
                            return y_list[math.floor(y+0.5)]\
                        end\
                    end,\
\
                    --* this function is used to get all the shades of colors\
                    --* in the loaded image\
                    get_palette=function()\
                        local cols = {}\
                        local palette_cols = 0\
                        local out = {}\
                        local final = {}\
\
                        --* loops over all the pixels\
                        --* and if it finds a pixel with a color it hasnt found yet\
                        --* add it to the cols list\
                        --* if this color is already in the cols list.\
                        --* increase its count by 1\
                        for k,v in pairs(_temp) do\
                            local hex = colors.packRGB(v.r,v.g,v.b)\
                            if not cols[hex] then\
                                palette_cols = palette_cols + 1\
                                cols[hex] = {c=hex,count=0}\
                            end\
                            cols[hex].count = cols[hex].count + 1\
                        end\
\
                        --* sort the colors by count from most used to least\
                        for k,v in pairs(cols) do\
                            table.insert(out,v)\
                        end\
                        table.sort(out,function(a,b) return a.count > b.count end)\
                        for k,v in ipairs(out) do\
                            local r,g,b = colors.unpackRGB(v.c)\
                            table.insert(final,{r=r,g=g,b=b,c=v.count})\
                        end\
\
                        --* return final sorted table\
                        return final,palette_cols\
                    end\
                }\
            end\
        end\
    else\
        --* if the file isnt raw ppm then closes the file and throws an error\
        file.close()\
        error(\"File is unsupported format: \"..read_characters(file,0,1),2)\
    end\
end\
\
return decode",
  main = "--[[\
    * this file is used to provide you with the main few main functions that\
    * and load all the nessesary presets and modules, also sets up log\
]]\
\
local logger = require(\"a-tools.logger\")\
\
local log = logger.create_log()\
\
--* puts the internal apis into the apis table cause they may be useful\
local apis = {\
    algo=require(\"a-tools.algo\"),\
    luappm=require(\"a-tools.luappm\"),\
    blbfor=require(\"a-tools.blbfor\"),\
    graphic=require(\"graphic_handle\").code,\
    general=require(\"api\")\
}\
local presets={}\
\
--* iterating over everything in the apis and presets folder and loading them\
log(\"loading apis..\",log.update)\
for k,v in pairs(fs.list(\"apis\")) do\
    local name = v:match(\"[^.]+\")\
    if not fs.isDir(\"apis/\"..v) then\
        apis[name] = require(\"apis.\"..name)\
        log(\"loaded api: \"..name)\
    end\
end\
log(\"\")\
log(\"loading presets..\",log.update)\
for k,v in pairs(fs.list(\"presets\")) do\
    for _k,_v in pairs(fs.list(\"presets/\"..v)) do\
        if not presets[v] then presets[v] = {} end\
        local name = _v:match(\"[^.]+\")\
        presets[v][name] = require(\"presets.\"..v..\".\"..name)\
        log(\"loaded preset: \"..v..\" > \"..name)\
    end\
end\
log(\"\")\
log(\"finished loading\",log.success)\
log(\"\")\
\
--* dumps the log into the a-tools/log.log file\
log:dump()\
\
--* this function is used to build a new gui_object using the gui_object.lua file\
local function generate_ui(m,event_offset_x,event_offset_y)\
    local create = require(\"a-tools.gui_object\")\
    local win = window.create(m,1,1,m.getSize())\
    log(\"creating gui object..\",log.update)\
    local gui = create(win,m,log,event_offset_x,event_offset_y)\
    log(\"finished creating gui object!\",log.success)\
    log(\"\",log.info)\
    log:dump()\
    local mt = getmetatable(gui) or {}\
    mt.__tostring = function() return \"GuiH.MAIN_UI.\"..tostring(gui.id) end\
    gui.api=apis\
    gui.preset=presets\
    return setmetatable(gui,mt)\
end\
\
return {\
    create_gui=generate_ui,\
    new=generate_ui,\
    load_texture=require(\"graphic_handle\").load_texture,\
    convert_event=function(ev_name,e1,e2,e3,id)\
        local ev_data = {}\
        if ev_name == \"monitor_touch\" then ev_data = {name=ev_name,monitor=e1,x=e2,y=e3} end\
        if ev_name == \"mouse_click\" or ev_name == \"mouse_up\" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end\
        if ev_name == \"mouse_drag\" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end\
        if ev_name == \"mouse_scroll\" then ev_data = {name=ev_name,direction=e1,x=e2,y=e3} end\
        if ev_name == \"key\" then ev_data = {name=ev_name,key=e1,held=e2,x=math.huge,y=math.huge} end\
        if ev_name ==\"key_up\" then ev_data = {name=ev_name,key=e1,x=math.huge,y=math.huge} end\
        if ev_name == \"char\" then ev_data = {name=ev_name,character=e1,x=math.huge,y=math.huge} end\
        if ev_name == \"guih_data_event\" then ev_data = e1 end\
        if not ev_data.monitor then ev_data.monitor = \"term_object\" end\
        return ev_data or {name=ev_name}\
    end,\
    apis=apis,\
    presets=presets,\
    valid_events={\
        [\"mouse_click\"]=true,\
        [\"mouse_drag\"]=true,\
        [\"monitor_touch\"]=true,\
        [\"mouse_scroll\"]=true,\
        [\"mouse_up\"]=true,\
        [\"key\"]=true,\
        [\"key_up\"]=true,\
        [\"char\"]=true,\
        [\"guih_data_event\"]=true\
    },\
    log=log\
}\
",
  [ "a-tools/update" ] = "--[[\
    * this file is used for updating\
    * graphics and state of gui elements\
    * also used for event proccessing\
]]\
\
local api = require(\"api\")\
\
_ENV = _ENV.ORIGINAL\
\
--* definitions for events and what they are\
local events = {\
    [\"mouse_click\"]=true,\
    [\"mouse_drag\"]=true,\
    [\"monitor_touch\"]=true,\
    [\"mouse_scroll\"]=true,\
    [\"mouse_up\"]=true,\
    [\"key\"]=true,\
    [\"key_up\"]=true,\
    [\"char\"]=true,\
    [\"guih_data_event\"]=true,\
    [\"paste\"]=true\
}\
local keyboard_events = {\
    [\"key\"]=true,\
    [\"key_up\"]=true,\
    [\"char\"]=true,\
    [\"paste\"]=true\
}\
local valid_mouse_buttons = {\
    [1]=true,\
    [2]=true\
}\
local valid_mouse_event = {\
    [\"mouse_click\"]=true,\
    [\"mouse_drag\"]=true,\
    [\"mouse_up\"]=true,\
    [\"mouse_scroll\"]=true\
}\
--* end of event definitions\
\
return function(self,timeout,visible,is_child,data_in,block_logic,block_graphic)\
\
    --* set up some variables for use later and for placeholders\
    if visible == nil then visible = true end\
    local ev_name = \"none\"\
    local ev_data = data_in\
    local data = data_in\
    local gui = self.gui\
    local e1,e2,e3,id\
    local frames,layers={},{}\
    local updateD = true\
\
    --* if there is a timeout and this isnt a child gui update then continue\
    if ((timeout or math.huge) > 0) and not block_logic then\
        if not data or not is_child then\
\
            --* startinga timer that will stop the event waiting once done\
            local tid = os.startTimer(timeout or 0)\
\
            --* if there is supposed to be no timeout setup an fake event to instantly trigger\
            if timeout == 0 then os.queueEvent(\"mouse_click\",math.huge,-math.huge,-math.huge) end\
\
            --* pull event until eighter one of events useful for GUIs happens\
            --* or the timer goes off\
            while not events[ev_name] or (ev_name == \"timer\" and e1 == tid) do\
                ev_name,e1,e2,e3,id = os.pullEvent()\
            end\
\
            --* convert the event into a more convinient format\
            if ev_name == \"monitor_touch\" then ev_data = {name=ev_name,monitor=e1,x=e2,y=e3} end\
            if ev_name == \"mouse_click\" or ev_name == \"mouse_up\" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end\
            if ev_name == \"mouse_drag\" then ev_data = {name=ev_name,button=e1,x=e2,y=e3} end\
            if ev_name == \"mouse_scroll\" then ev_data = {name=ev_name,direction=e1,x=e2,y=e3} end\
            if ev_name == \"key\" then ev_data = {name=ev_name,key=e1,held=e2,x=math.huge,y=math.huge} end\
            if ev_name == \"key_up\" then ev_data = {name=ev_name,key=e1,x=math.huge,y=math.huge} end\
            if ev_name == \"paste\" then ev_data = {name=ev_name,text=e1,x=math.huge,y=math.huge} end\
            if ev_name == \"char\" then ev_data = {name=ev_name,character=e1,x=math.huge,y=math.huge} end\
\
            --* guih data event is used to pass events onto child objects\
            if ev_name == \"guih_data_event\" then ev_data = e1 end\
\
            --* if you are using term instead of an monitor then the monitor used by the event\
            --* will be set to term_object which is monitor name used by term in\
            --* a-tools/gui_object.lua\
            if not ev_data.monitor then ev_data.monitor = \"term_object\" end\
\
            --* trigger GuiH data event with the current event if the event we received was not\
            --* created here. to prevent infinte event loops\
            --* if we catch an event that was also made here then set updatedD\
            --* to false so we dont update the gui with replica event\
            if e2 ~= self.id and ev_name ~= \"guih_data_event\" then\
                os.queueEvent(\"guih_data_event\",ev_data,self.id)\
            else\
                updateD = false\
            end\
        end\
\
        local update_layers = {}\
\
        --* if the monitor that we clicked matches the one the gui is set to respond to then we continue\
        if updateD and ev_data.monitor == self.monitor and not block_graphic then\
\
            --* iterate over all the elements in the gui\
            for _k,_v in pairs(gui) do for k,v in pairs(_v) do\
\
                --* if the element is reactive and is set to respond to the current event then continue\
                if (v.reactive and v.react_to_events[ev_data.name]) or not next(v.react_to_events) then\
\
                    --* build a function that updates this element and add it into update_layers\
                    --* with its update logic_order or order as a key\
                    if not update_layers[v.logic_order or v.order] then update_layers[v.logic_order or v.order] = {} end\
                    table.insert(update_layers[v.logic_order or v.order],function()\
\
                        --* if the event is a keyboard based event then straight up\
                        --* update the object, but if its nota keyboard based object then\
                        --* check if the button clicked matches with v.btn\
                        --* which is a LUT of the buttons the object should respond to\
                        --* also check if the monitor that this event happened on matches\
                        if keyboard_events[ev_data.name] then\
                            if v.logic then setfenv(v.logic,_ENV)(v,ev_data,self) end\
                        else\
                            if ((v.btn or valid_mouse_buttons)[ev_data.button]) or ev_data.monitor == self.monitor then\
                                if v.logic then setfenv(v.logic,_ENV)(v,ev_data,self) end\
                            end\
                        end\
                    end)\
                end\
            end end\
        end\
        --* execute all of the objects functions in the right order using the iterate_order function\
        for k,v in api.tables.iterate_order(update_layers) do parallel.waitForAll(unpack(v)) end\
    end\
    local cx,cy = self.term_object.getCursorPos()\
\
    --* if this update is meant to be visible\
    if visible and self.visible then\
        \
        --* iterate over all the elements in the gui\
        for _k,_v in pairs(gui) do for k,v in pairs(_v) do\
\
            --* build a function that updates this element and add it into update_layers\
            --* with its update logic_order or order as a key\
            if not layers[v.graphic_order or v.order] then layers[v.graphic_order or v.order] = {} end\
            table.insert(layers[v.graphic_order or v.order],function()\
\
                --* if this object doesnt have any child gui and is set to visible then update it\
                --* if it has a child object and is visible then update it and add that child\
                --* element to the frames list to be updated reccursively later\
                if not (v.gui or v.child) then\
                    if v.visible and v.graphic then setfenv(v.graphic,_ENV)(v,self) end\
                else\
                    if v.visible and v.graphic then\
                        setfenv(v.graphic,_ENV)(v,self);\
                        (v.gui or v.child).term_object.redraw()\
                    end\
                end\
            end)\
        end end\
    end\
\
    --* execute all of the objects functions in the right order using the iterate_order function\
    for k,v in api.tables.iterate_order(layers) do parallel.waitForAll(table.unpack(v)) end\
\
    local child_layers = {}\
    for _k,_v in pairs(gui) do for k,v in pairs(_v) do\
        if not child_layers[v.graphic_order or v.order] then child_layers[v.graphic_order or v.order] = {} end\
        table.insert(child_layers[v.graphic_order or v.order],function()\
            if v.gui or v.child then\
                table.insert(frames,v)\
            end\
        end)\
    end end\
\
    for k,v in api.tables.iterate_order(child_layers) do for _k,_v in pairs(v) do _v() end end\
\
    --* if we had caught an replica event then end the update here. else continue\
    if not updateD then return ev_data,table.pack(ev_name,e1,e2,e3,id) end\
\
    --* iterate over all the frames so their child guis can be updated\
    for k,v in ipairs(frames) do\
\
        --* get the childs size and position info\
        local x,y = v.window.getPosition()\
        local w,h = v.window.getSize()\
\
        --* try to get any event data that could be here\
        local data = data or data_in or ev_data\
        if data then\
            \
            --* offset the event data to make the click relative to the window object\
            local dat = {\
                x = (data.x-x)+1,\
                y = (data.y-y)+1,\
                name = data.name,\
                monitor = data.monitor,\
                button = data.button,\
                direction = data.direction,\
                held=data.held,\
                key=data.key,\
                character=data.character,\
                text=data.text\
            }\
\
            --* if the element has an gui (for example group) then clear it with its background color\
            if v.gui and v.gui.cls then\
                v.gui.term_object.setBackgroundColor(v.gui.background)\
                v.gui.term_object.clear()\
            end\
\
            --* if the event has happened within the gui object that update it like normal\
            --* else update it with infinite event cordinates so nothing will most likely get triggered\
            if api.is_within_field(data.x,data.y,x,y,x+w,y+h) then\
                (v.child or v.gui).update(math.huge,v.visible,true,dat,not v.reactive,not v.visible)\
            else\
                dat.x = -math.huge\
                dat.y = -math.huge;\
                (v.child or v.gui).update(math.huge,v.visible,true,dat,not v.reactive,not v.visible)\
            end\
            if v.gui and v.gui.cls then \
                v.gui.term_object.redraw()\
            end\
        end\
    end\
\
    --* restore the cursor position\
    self.term_object.setCursorPos(cx,cy)\
    return ev_data,table.pack(ev_name,e1,e2,e3,id)\
end\
",
  [ "presets/rect/window" ] = "return function(side,bg)\
    return {\
        top_left={sym=\" \",bg=side,fg=bg},\
        top_right={sym=\" \",bg=side,fg=bg},\
        bottom_left={sym=\" \",bg=bg,fg=side},\
        bottom_right={sym=\" \",bg=bg,fg=side},\
        side_left={sym=\" \",bg=bg,fg=side},\
        side_right={sym=\" \",bg=bg,fg=side},\
        side_top={sym=\" \",bg=side,fg=bg},\
        side_bottom={sym=\" \",bg=bg,fg=side},\
        inside={sym=\" \",bg=bg,fg=side},\
    }\
end",
  [ "objects/button/logic" ] = "local api = require(\"api\")\
return function(object,event)\
    --* if a click happens on the buttons area\
    --* run on_click function\
    if api.is_within_field(\
        event.x,\
        event.y,\
        object.positioning.x,\
        object.positioning.y,\
        object.positioning.width,\
        object.positioning.height\
    ) then\
        object.on_click(object,event)\
    end\
end",
  [ "objects/button/graphic" ] = "local texture = require(\"graphic_handle\").code\
\
return function(object)\
    local term = object.canvas.term_object\
    local x,y = object.positioning.x,object.positioning.y\
    if not object.texture then\
\
        --* draw a colored box for the button\
        term.setBackgroundColor(object.background_color)\
        term.setTextColor(object.text_color)\
        for i=y,object.positioning.height+y-1 do\
            term.setCursorPos(x,i)\
            term.write(object.symbol:rep(object.positioning.width))\
        end\
    else\
\
        --* draw the texture for the button\
        texture.draw_box_tex(\
            term,\
            object.texture,\
            x,y,object.positioning.width,object.positioning.height,\
            object.background_color,object.text_color,nil,nil,object.canvas.texture_cache\
        )\
    end\
    if object.text then\
\
        --* draw the text for the button\
        object.text(term,object.positioning.x,object.positioning.y,object.positioning.width,object.positioning.height)\
    end\
end",
  [ "objects/circle/logic" ] = "return function()\
end\
",
  [ "objects/group/object" ] = "local api = require(\"api\")\
local main = require(\"a-tools.gui_object\")\
\
return function(object,data)\
    data = data or {}\
    if type(data.visible) ~= \"boolean\" then data.visible = true end\
    if type(data.reactive) ~= \"boolean\" then data.reactive = true end\
    local btn = {\
        name=data.name or api.uuid4(),\
        positioning = {\
            x=data.x or 1,\
            y=data.y or 1,\
            width=data.width or 0,\
            height=data.height or 0\
        },\
        visible=data.visible,\
        order=data.order or 1,\
        logic_order=data.logic_order,\
        graphic_order=data.graphic_order,\
        bef_draw=data.bef_draw or function() end\
    }\
    local window = window.create(\
        object.term_object,\
        btn.positioning.x,\
        btn.positioning.y,\
        btn.positioning.width,\
        btn.positioning.height\
    )\
    btn.gui = main(window,object.term_object,object.log)\
    btn.window = window\
    btn.gui.inherit(object,btn)\
    return btn\
end",
} local e local t local function a(o)local i=files[o]local n=load(i)return
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
return r end local x=a("init")return x()
