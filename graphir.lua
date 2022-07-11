--[[
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
]]

local expect = require("cc.expect").expect
local GRAPHIR = {INTERNAL={},OBJECT={}}

local modes = {
    normal=true,
    dots=true,
    connected=true
}

function GRAPHIR.INTERNAL.EXTRACT_NUMBERS(array,run_extract)
    local numbers = {}
    for k,v in ipairs(array) do
        if type(v) == "number" then
            if run_extract then
                run_extract(v)
            else
                table.insert(numbers, v)
            end
        end
    end
    return numbers
end

function GRAPHIR.INTERNAL.CALCULATE_GRAPH_POINT(highest,height,current)
    return height*current/highest
end

function GRAPHIR.OBJECT:push()
    if not self and not self.members then error("Failed to access the graph object, are you sure you are running the function with \":\" and not \".\"") end
    local resolution = self.spaced and self.canvas.width or self.canvas.width*2
    local visible_members = {}
    local highest_point = -math.huge
    for index=#self.members-resolution+1,#self.members do
        if self.members[index] then
            table.insert(visible_members,self.members[index])
            highest_point = math.max(highest_point,self.members[index])
        end
    end
    self.canvas:clear(self.bg)
    local last
    for point_number,v in pairs(visible_members) do
        local point_height = GRAPHIR.INTERNAL.CALCULATE_GRAPH_POINT(highest_point, self.canvas.height*3, v)
        local starting_point = self.canvas.height*3-point_height+1
        if not last then last = starting_point end
        local x = math.min((self.spaced and (point_number-1)*2+1 or point_number),self.canvas.width*2)
        if self.mode == "normal" or self.mode == "dots" then
            for y=starting_point,self.canvas.height*3 do
                self.canvas:set_pixel(x,math.ceil(y),self.fg)
                if self.mode == "dots" then
                    break
                end
            end
        elseif self.mode == "connected" and last then
            local a,b = last,starting_point
            if a > b then b,a = a,b end
            for y=a,b do
                self.canvas:set_pixel(x,math.floor(math.min(math.max(y,1),self.canvas.height*3)),self.fg)
            end
            last = starting_point
        end
    end
end

function GRAPHIR.OBJECT:add(value)
    if not self and not self.members then error("Failed to access the graph object, are you sure you are running the function with \":\" and not \".\"") end
    expect(1,value,"number")
    table.insert(self.members,value)
    local index = #self.members
    local modifiers = {}
    local modifiable = true
    function modifiers.undo()
        if modifiable then
            modifiable = false
            table.remove(self.members,index)
        else
            error("This object can no longer be modified",2)
        end
    end
    function modifiers.set(new_value)
        if modifiable and self.members[index] then
            self.members[index] = new_value
        end
    end
    return modifiers
end

function GRAPHIR.OBJECT:set(index,value)
    if not self and not self.members then error("Failed to access the graph object, are you sure you are running the function with \":\" and not \".\"") end
    expect(1,index,"number")
    expect(2,value,"number")
    local old = self.members[index]
    if self.members[index] or self.members[index-1] then
        self.members[index] = value
    end
    local modifiers = {}
    local modifiable = true
    function modifiers.undo()
        if modifiable then
            if not (type(old) == "number") then modifiable = false end
            self.members[index] = old
        end
    end
    function modifiers.set(new_value)
        expect(1,new_value,"number")
        if modifiable and self.members[index] then
            if not new_value then modifiable = false end
            self.members[index] = new_value
        end
    end
end

function GRAPHIR.OBJECT:set_values(...)
    if not self and not self.members then error("Failed to access the graph object, are you sure you are running the function with \":\" and not \".\"") end
    self.members = {}
    local numbers = GRAPHIR.INTERNAL.EXTRACT_NUMBERS({...})
    self.members = numbers
end

function GRAPHIR.OBJECT:add_values(...)
    if not self and not self.members then error("Failed to access the graph object, are you sure you are running the function with \":\" and not \".\"") end
    GRAPHIR.INTERNAL.EXTRACT_NUMBERS({...},function(n)
        table.insert(self.members,n)
    end)
end

function GRAPHIR.OBJECT:remove(index)
    if not self and not self.members then error("Failed to access the graph object, are you sure you are running the function with \":\" and not \".\"") end
    expect(1,index,"number")
    if self.members[index] then
        table.remove(self.members,index)
    end
end

function GRAPHIR.OBJECT:remove_multiple(start_index,end_index)
    if not self and not self.members then error("Failed to access the graph object, are you sure you are running the function with \":\" and not \".\"") end
    expect(1,start_index,"number")
    expect(2,end_index,"number")
    if start_index > end_index then
        start_index,end_index = end_index,start_index
    end
    for _=start_index,end_index do
        if self.members[start_index] then
            table.remove(self.members,start_index)
        end
    end
end

function GRAPHIR.new(box,graph_color,background_color,remove_spaces,mode)
    expect(1,box,"table")
    expect(2,graph_color,"number")
    expect(3,background_color,background_color,"number")
    expect(4,remove_spaces,"boolean","nil")
    expect(5,mode,"string","nil")
    if (not mode) or (not modes[mode]) then mode = "normal" end
    local object = {
        canvas = box,
        fg=graph_color,
        bg=background_color,
        members = {},
        spaced = not remove_spaces,
        mode = mode
    }
    return setmetatable(object,{__index=GRAPHIR.OBJECT})
end

return GRAPHIR
