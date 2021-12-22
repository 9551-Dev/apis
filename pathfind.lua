local pureLua = false
local expect
if not pureLua then
    expect = require("cc.expect").expect
end
local vector = {}
vector.new = function(x,y,z)
    return setmetatable({
        x=x or 0,
        y=y or 0,
        z=z or 0
    },{__add=function(i,x)
        return {
            x=i.x+x.x,
            y=i.y+x.y,
            z=i.z+x.z
        }
    end,
    __tostring = function(self)
        local x = tostring(self.x)
        local y = tostring(self.y)
        local z = tostring(self.z)
        return x..","..y..","..z
    end
    })
end
local createNode = function(passable,x,y,z)
    if passable == nil then passable = true end
    if not pureLua then
        expect(1,passable,"boolean","nil")
        expect(2,x,"number")
        expect(3,y,"number")
    end
    local gCost = 0
    local hCost = 0
    return setmetatable({
        isPassable = passable,
        gCost = gCost,
        hCost = hCost,
        pos = vector.new(x,y,z),
    },{__index=function(self,index)
            if index == "fCost" then
                return self.gCost+self.hCost
            end
        end
    })
end
local createSelfIndexArray = function()
    return setmetatable({},
        {
            __index=function(t,k)
                local new = {}
                t[k]=new
                return new
            end
        }
    )
end
local findInGrid = function(grid,vec)
    if not pureLua then
        expect(1,grid,"table")
        expect(2,vec,"table")
    end
    for k,v in pairs(grid) do
        if (v.pos.x == vec.x) and (v.pos.y == vec.y) and (v.pos.z == vec.z) then
            return v,grid[k],k
        end
    end
end
local getNeighbors = function(grid,node,sizedat)
    local foundNeighbors = {}
    for x=-1,1 do
        for y=-1,1 do
            for z=-1,1 do
                local abs = {math.abs(x),math.abs(y),math.abs(z)}
                if not (x == 0 and y == 0 and z == 0) and not (abs[1] == 1 and abs[2] == 1 and abs[3] == 1) then
                    local relative = node.pos+vector.new(x,y,z)
                    local relativeX,relativeY,relativeZ = relative.x,relative.y,relative.z
                    if (relativeX >= 0 and relativeX < sizedat.w+1) and (relativeY >= 0 and relativeY < sizedat.h+1) and (relativeZ >= 0 and relativeZ < sizedat.d+1) then
                        local neighbor = findInGrid(grid,vector.new(relativeX,relativeY,relativeZ))
                        table.insert(foundNeighbors,neighbor)
                    end
                end
            end
        end
    end
    return foundNeighbors
end
local getDistance = function(grid,nodeA,nodeB)
    return math.sqrt((nodeA.pos.x - nodeB.pos.x)^2 + (nodeA.pos.y - nodeB.pos.y)^2 + (nodeA.pos.z - nodeB.pos.z)^2)
end
local tblRev = function(tbl)
    local temp = {}
    for k,v in pairs(tbl) do
        temp[(#tbl-k)] = v
    end
    return temp
end
local retracePath = function(grid,sNode,nNode,sizedat)
    local path = {nNode}
    local curNode = nNode
    local eStr = tostring(sNode.pos)
    local curNode = (getNeighbors(grid,curNode,sizedat))[1]
    if curNode then
        while tostring(curNode.pos) ~= eStr do
            table.insert(path,curNode)
            curNode = curNode.parent
        end
    end
    table.insert(path,sNode)
    local output = {}
    local tempValue = tblRev(path)
    for k,v in pairs(tempValue or {}) do
        table.insert(output,{x=v.pos.x,y=v.pos.y,z=v.pos.z,g=v.gCost,h=v.hCost,f=v.fCost})
        tempValue = v.parent
    end
    return output
end
local createField = function(w,h,d,xin,yin,zin,width,height,depth)
    if not pureLua then
        expect(1,w,"number")
        expect(2,h,"number")
        expect(3,xin,"number")
        expect(4,yin,"number")
    end
    width = width or w
    height = height or h
    local temp = {}
    for x=xin,xin+width do
        for y=yin,yin+height do
            for z=zin,zin+depth do
                table.insert(temp,createNode(true,x,y,z))
            end
        end
    end
    return {grid=temp,sizeData={w=w,h=h,d=d}}
end
local pathfind = function(gridData,startNode,endNode)
    if not pureLua then
        expect(1,gridData,"table")
        expect(2,startNode,"table")
        expect(3,endNode,"table")
    end
    local grid = gridData.grid
    local sizedat = gridData.sizeData
    local targetNode = endNode
    local openSet = {startNode}
    local closedSet = {}
    while next(openSet) do
        local lastIndice = 1
        local curNode = openSet[1]
        for i=2,#openSet do
            if (openSet[i].fCost < curNode.fCost) or (openSet[i].fCost == curNode.fCost and openSet[i].hCost < curNode.hCost) then
                curNode = openSet[i]
                lastIndice = i
            end
        end
        table.insert(closedSet,curNode)
        table.remove(openSet, lastIndice)
        local cx,cy,cz = curNode.pos.x,curNode.pos.y,curNode.pos.z
        local ex,ey,ez = targetNode.pos.x,targetNode.pos.y,targetNode.pos.z
        if cx == ex and cy == ey and cz == ez then
            return retracePath(closedSet,startNode,targetNode,sizedat)
        end
        for i,neighbor in pairs(getNeighbors(grid,curNode,sizedat)) do
            if not ((not neighbor.isPassable) or findInGrid(closedSet,neighbor.pos)) then
                local newMovCostToNeighbor = curNode.gCost + getDistance(grid,curNode,neighbor)
                if (newMovCostToNeighbor < neighbor.gCost) or not findInGrid(openSet,neighbor.pos) then
                    neighbor.gCost = newMovCostToNeighbor
                    neighbor.hCost = getDistance(grid,neighbor,targetNode)
                    neighbor.parent = curNode
                    if not findInGrid(openSet,neighbor.pos) then
                        table.insert(openSet,neighbor)
                    end
                end
            end
        end
    end
    return {},false,"unable to find path"
end
local grid = createField(10,10,10,1,1,1,10,10,10)
_G.grid = grid  
local startNode = createNode(true,1,3,10)
local endNode = createNode(true,4,9,1 )
local out = {pathfind(grid,startNode,endNode)}

local main = require("engine")
local width,height = term.getSize()
local win = window.create(term.current(),1,1,width,height)
local oldTerm = term.redirect(win)
local sTime = os.epoch("utc")/1000
local frames = math.huge
local speed = 10
local objects = {}
for k,v in pairs(out[1]) do
    local cube = main.objects.newCube()
    cube.loc.x = v.x-1
    cube.loc.y = v.y-5 
    cube.loc.z = -v.z-15
    cube.rot.z = 0.5
    table.insert(objects,cube)
end
local distanceShader = main.createDistanceShader()
local cFG = colors.white
distanceShader = {
    {" ",cFG},
    [4] = {".",cFG},
    [5] = {".",cFG},
    [6] = {":",cFG},
    [7] = {":",cFG},
    [8] = {"-",cFG},
    [9] = {"=",cFG},
    [10] = {"+",cFG},
    [11] = {"*",cFG},
    [12] = {"#",cFG},
    [13] = {"#",cFG},
    [14] = {"%",cFG},
    [15] = {"%",cFG},
    [16] = {"@",cFG},
    [17] = {"@",cFG}
}

local clickMap = {}
local obj

local drawArgs = main.getProcessingArgs()
drawArgs.drawWireFrame = true
drawArgs.drawTriangles = true
drawArgs.doCulling = true
drawArgs.frontCulling = false
drawArgs.backCulling = true

local function render()
    local camPos = vector.new(0,0,0)
    local camRot = vector.new(0,0,0)
    for i=1,frames do
        local perspertive = main.createPerspective(width,height,40)
        local camera = main.createCamera(camPos,camRot)
        local projected = main.transform(objects,perspertive,camera)
        local zBuffer = main.createZBuffer()
        local dat = main.proccesTriangleData(zBuffer,projected,drawArgs)
        clickMap = main.tools.copyTbl(dat)
        local blit = main.convertBufferToDrawable(width,height,dat,distanceShader,false)
        main.drawConverted(term,blit)
        os.queueEvent("yielding")
        os.pullEvent("yielding")
    end
end
local function engine()
    local ok,err = pcall(render)
    term.redirect(oldTerm)
    term.setCursorPos(1,1)
    if not ok then print(err,0) end
    local eTime = os.epoch("utc")/1000
    local tDiff = eTime-sTime
    _G.FPS = frames/tDiff
    print("FPS: ".._G.FPS)
end
local function key()
    local col = main.createColor()
    local sCol = main.createColor({
        [colors.green]=true,
        [colors.lime]=true
    })
    while true do
        local ev,char = os.pullEvent("key")
        for k,v in pairs(objects) do
            objects[k].color = col
        end
        if obj then
            obj.color = sCol
            if char == keys.s then obj.loc.z = obj.loc.z + 0.1 end
            if char == keys.w then obj.loc.z = obj.loc.z - 0.1 end
            if char == keys.a then obj.loc.x = obj.loc.x - 0.1 end
            if char == keys.d then obj.loc.x = obj.loc.x + 0.1 end
            if char == keys.leftShift then obj.loc.y = obj.loc.y - 0.1 end
            if char == keys.space then obj.loc.y = obj.loc.y + 0.1 end
            if char == keys.right then obj.rot.y = obj.rot.y + 1 end
            if char == keys.left then obj.rot.y = obj.rot.y - 1 end
            if char == keys.up then obj.rot.x = obj.rot.x - 1 end
            if char == keys.down then obj.rot.x = obj.rot.x + 1 end
        end
    end
end
local function click()
    while true do
        local ev,k,x,y = os.pullEvent("mouse_click")
        if clickMap[x][y] then obj = clickMap[x][y].objectPointer.main else obj = nil end
        os.queueEvent("key","UPDATE")
    end
end
parallel.waitForAny(engine,key,click)
term.setGraphicsMode(false)
