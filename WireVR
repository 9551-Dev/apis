--*WireVR--
--*computercraft OS for VR by 9551Dev--
local middle = {x=0,z=0}
local offset = {x=-0.5,z=-0.5}
local power = 0.035
local defects = 50
local maxpower = 10
local DefGroundLevel = 0
local useCanvas = true
local state = true
local moveBack = true
local GPcheckerQuality = 1
local doMoves = 1
local controls = {
    forward = keys.w,
    backward = keys.s,
    left = keys.a,
    right = keys.d,
    shift = keys.leftShift,
	jump = keys.space
}
if not fs.exists("ButtonH") then shell.run("pastebin get LTDZZZEJ ButtonH") end
local b = require("ButtonH").terminal

local controlsList = {
    ["forward"] = true,
    ["backward"] = true,
    ["left"] = true,
    ["right"] = true,
    ["shift"] = true,
    ["jump"] = true
}
local per = peripheral.wrap("back")
local vpos
local eventQueue = {}
local setGroundPerPos = {}
local engineState = true
local groundLevel = DefGroundLevel
local currentPos = vector.new(0,0,0)
local setPosition = function(x,y,z) currentPos = vector.new(x,y,z) end
local setGroundLevel = function(height) DefGroundLevel = height end
local useVposForMoveback
local getVPOS = function()
    local vpos = vpos or vector.new(0,0,0)
    return vector.new(vpos.z,vpos.y,-vpos.x)
end
local floorVector = function(vec)
    local x = math.floor(vec.x)
    local y = math.floor(vec.y)
    local z = math.floor(vec.z)
    return vector.new(x,y,z)
end
local vecMathMin = function(vec,vec2)
    local x = math.min(vec.x,vec2.x)
    local y = math.min(vec.y,vec2.y)
    local z = math.min(vec.z,vec2.z)
    return vector.new(x,y,z)
end
local inVecMathMax = function(vec)
    return math.max(vec.x,vec.y,vec.z)
end
local getVecLength = function(vec)
    local x = #(tostring(vec.x))
    local y = #(tostring(vec.y))
    local z = #(tostring(vec.z))
    return vector.new(x,y,z)
end
local meta
local om
local getPlayerData = function()
    if meta then om = meta end
    meta = per.getMetaOwner()
    local meta = meta or om
    return meta.yaw,meta.pitch,meta.isSprinting,meta.isSneaking
end
local getPlayerPos = function()
    local x,_,z = gps.locate()
    return x,z
end
local eventYield = function()
    os.queueEvent("faked")
    os.pullEvent("faked")
end
local isIn = function(posX,posY,startX,startY,length,height)
    return posX >= startX and
    posX <= startX + length and
    posY >= startY and
    posY <= startY + height
end
local move = function()
    power = power + defects / 1000
    local xy,_,zy = gps.locate()
    local tempx,tempz
    local Cnter = 0
    while state do
        if moveBack then
            if Cnter == GPcheckerQuality then
                Cnter = 0
                tempx,_,tempz = gps.locate()
            else
				Cnter = Cnter + 1
			end
            xy,zy = (tempx or xy), (tempz or zy)
            local xyz,zyz = xy-(middle.x-offset.x),zy-(middle.z-offset.z)
            for i=1,doMoves do
                local yaw = math.deg(math.atan2(-xyz, zyz))
                local power = math.min(math.sqrt(xyz^2+zyz^2)*power,maxpower)
                per.launch(yaw-180,0,power)
            end
        else
			sleep(1)
		end
        sleep(0.1)
    end
end
local menu = function()
    engineState = false
    sleep(0.5)
    while state do
        if eventQueue[controls.shift] then
            sleep(0.5)
            break
        end
        if useCanvas then
            per.look(180,0);
            (canvasMenuFunc or function() end)()
        else
            per.look(180,0);
            (canvasFreeMenuFunc or function() end)()
        end
        sleep(0.5)
    end
end 
local jump = false
local lookVector
local vPos = function()
    local YAW_ROT
    local PITCH_ROT
    local lookAng
    local addUp
    local keyUpEv
    local keyDownEv
    local ran = false
    local keyDown = function()
        while state do
            _,keyDownEv = os.pullEvent("key")
            if not eventQueue[keyDownEv] then
                eventQueue[keyDownEv] = true
            end
        end
    end
    local keyUp = function()
        while state do
            _,keyUpEv = os.pullEvent("key_up")
            eventQueue[keyUpEv] = false
        end
    end
    function lookVector(angle)
        local rads = math.rad(angle - 180)
        local divider = 4 
        local _,_,sprint,sneak = getPlayerData()
        if sprint then divider = 2 end
        if sneak then divider = 13 end
        return {
            x = math.cos(rads)/divider,
            z = math.sin(rads)/divider
        }
    end
    local MovementHandle = function()
        while state do
            if engineState then
                YAW_ROT,PITCH_ROT = getPlayerData()
                if not eventQueue[controls.right] and not eventQueue[controls.left] then
                    lookAng = lookVector(YAW_ROT)
                elseif eventQueue[controls.right] then
                    lookAng = lookVector(YAW_ROT+90)
                elseif eventQueue[controls.left] then
                    lookAng = lookVector(YAW_ROT-90)
                end
                addUp = vector.new(lookAng.x,0,lookAng.z)
                if eventQueue[controls.right] or eventQueue[controls.left] then
                    currentPos = currentPos:add(addUp)
                end
                if eventQueue[controls.forward] then
                    if eventQueue[controls.right] or eventQueue[controls.left] then
                        lookAng = lookVector(YAW_ROT)
                        addUp = vector.new(lookAng.x,0,lookAng.z)
                    end
                    currentPos = currentPos:add(addUp)
                end
                if eventQueue[controls.backward] then
                    if eventQueue[controls.right] or eventQueue[controls.left] then
                        lookAng = lookVector(YAW_ROT)
                        addUp = vector.new(lookAng.x,0,lookAng.z)
                    end
                    currentPos = currentPos:add(-addUp)
                end
                if eventQueue[controls.jump] then
                    if not jump then
                        jump = true
                    end
                end
                vpos = currentPos
                ran = true
            end
            sleep(0.05)
        end
    end
    local main = function()
        while state do
            local isEmptySpace = true
            if ran then
                engineState = true
                YAW_ROT,PITCH_ROT = getPlayerData()
                for _,v in pairs(setGroundPerPos) do
                    if isIn(currentPos.x,currentPos.z,v.f.x,v.f.z,v.t[1],v.t[2]) then
                        groundLevel = v.fl
                        isEmptySpace = false
                    end
                end
                if isEmptySpace then
                    groundLevel = DefGroundLevel
                end
                sleep(0.05)
            end
            sleep(0.05)
        end
    end
        local gravity = function()
            local jump
            local animationQuality = 10
            local GRAVITY_ACCELERATION_Y = -0.5
            local JUMP_SPEED = 1.19/animationQuality
            local GRAVITY = vector.new(0, GRAVITY_ACCELERATION_Y, 0)
            local JUMP = vector.new(0, JUMP_SPEED, 0)
            local playerVelocity = vector.new(0, 0, 0)
            local lastTime = os.epoch("utc")
            while state do
                if eventQueue[controls.jump] and jump then
                    for _=1,animationQuality do
                        currentPos = currentPos + JUMP
                        sleep()
                    end
                end
                local currentTime = os.epoch("utc")
                if currentPos.y > groundLevel then
                    jump = false
                    local diffTime = (os.epoch("utc") - lastTime) / 1000
                    currentPos = currentPos + (playerVelocity * diffTime)
                    playerVelocity = playerVelocity + GRAVITY
                    if currentPos.y < groundLevel then currentPos.y = groundLevel end
                else 
                    jump = true
                    playerVelocity = vector.new(0, 0, 0)
                end
                lastTime = currentTime
                os.sleep()
            end
        end
    local menuRunner = function()
        while state do
            if eventQueue[controls.shift] and PITCH_ROT == 90 then 
                menu()
            end
            sleep(0.1)
        end
    end
    parallel.waitForAll(keyUp,keyDown,MovementHandle,gravity,menuRunner,main)
end
local safety = function()
    local ran = false
    while not ran do
        if not ran and not state then
            os.queueEvent("key",0)
            os.queueEvent("key_up",0)
            ran = true
        end
        sleep()
    end
end
local LAUNCH = function() parallel.waitForAll(vPos,move,safety) end
local getEventQueue = function() return eventQueue end
local getEngineState = function() return engineState end
local setMiddle = function(x,z) middle = {x=x,z=z} end
local setOffset = function(x,z) offset = {x=x,z=z} end
local setMaxPower = function(power) maxpower = math.min(power,10) end
local canvasMenu = function(bool) useCanvas = bool end
local getGroundLevel = function() return groundLevel end
local getButtonAPI = function() return b end
local setState = function(stateVar) state = stateVar end
local doMoveBack = function(state) moveBack = state end
local setGPcheckerQuality = function(value) GPcheckerQuality = value end
local setMovePrecision = function(value) doMoves = value end
local getAllPData = function()
    local meta = per.getMetaOwner()
    local x,y,z = gps.locate()
    local playerData = { 
        rot = vector.new(meta.pitch, meta.yaw, 0),
        loc = vector.new(x,y,z)
    }
    return playerData
end
local VPDT = function()
    local meta = per.getMetaOwner()
    local playerData = { 
        rot = vector.new(meta.pitch, meta.yaw, 0),
        loc = getVPOS()
    }
    return playerData
end
local setControls = function(control,key)
    if not controlsList[control] then
        print("invalid control please use:")
        for k,_ in pairs(controlsList) do
            print(k)
        end
    end
    if not keys[key] then print("invalid key") end
    controls[control] = keys[key]
end
local colors2rgb = function(ins,mode)
	if not mode then
		mode = 255
	end
    local r,g,b = term.getPaletteColor(ins)
    return r*mode,g*mode,b*mode
end
local setPosGround = function(StartTable,ScaleTable,GL)
    table.insert(setGroundPerPos,{f=StartTable,t=ScaleTable,fl=GL})
end
local setMenuFunction = function(func,isCanvas)
    if isCanvas then canvasMenuFunc = func
	else canvasFreeMenuFunc = func end
end
return {
    launch = LAUNCH,
    setMaxPower = setMaxPower,
    setOffset = setOffset,
    setMiddle = setMiddle,
    getVPos = getVPOS,
    floorVector = floorVector,
    getPlayerPos = getPlayerPos,
    getPlayerData = getPlayerData,
    eventYield = eventYield,
    getEventQueue = getEventQueue,
    lookVector = lookVector,
    getEngineState = getEngineState,
    setControls = setControls,
    colors2rgb = colors2rgb,
    setGroundLevel = setGroundLevel,
    vecMathMin = vecMathMin,
    canvasMenu = canvasMenu,
    isIn = isIn,
    setPosGround = setPosGround,
    getGroundLevel = getGroundLevel,
    setPosition = setPosition,
    openMenu = menu,
    getButtonAPI = getButtonAPI,
    inVecMathMax = inVecMathMax,
    getVecLength = getVecLength,
    getAllPData = getAllPData,
    setState = setState,
    getVposARotation = VPDT,
    doMoveBack = doMoveBack,
    setMenuFunction = setMenuFunction,
    setGPcheckerQuality = setGPcheckerQuality,
	setMovePrecision = setMovePrecision
}
