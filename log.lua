local index = {}

local function writeWrapped(termObj,str)
    local width,height = termObj.getSize()
    local strings,maxLen = {},math.ceil(#str/width)
    local last = 0
    for i=1,maxLen do
        local _,y = termObj.getCursorPos()
        termObj.write(str:sub(last+1,i*width))
        if y+1 > height then
            termObj.scoll(1)
            termObj.setCursorPos(1,height)
        end
        termObj.setCursorPos(1,y+1)
        last=i*width
    end
    return maxLen
end

local function getLineLen(termObj,str)
    local width = termObj.getSize()
    local strings,maxLen = {},math.ceil(#str/width)
    local last = 0
    local strLen
    for i=1,maxLen do
        local strs = str:sub(last+1,i*width)
        last=i*width
        strLen = #strs
    end
    return strLen
end

function index:log(str,type)
    type = type or "info"
    local width,height = self.term.getSize()
    if self.lastLog == str..type then
        self.nstr = self.nstr + 1
        local x,y = self.term.getCursorPos()
        local yid = y-self.maxln
        self.term.setCursorPos(x,yid)
        self.term.clearLine()
    else
        self.nstr = 1
    end
    self.lastLog = str..type
    local timeStr = "["..textutils.formatTime(os.time()).."] "
    local tb,tt = self.term.getBackgroundColor(),self.term.getTextColor()
    if type == "error" then self.term.setTextColor(colors.red)
    elseif type == "warn" then self.term.setTextColor(colors.yellow)
    elseif type == "fatal" then self.term.setBackgroundColor(colors.red)
    elseif type == "sucess" then self.term.setBackgroundColor(colors.lime)
    elseif type == "message" then self.term.setTextColor(colors.white)
    elseif type == "update" then self.term.setTextColor(colors.green)
    elseif type == "info" then self.term.setTextColor(colors.gray)
    else self.term.setTextColor(colors.magenta) end
    local strse = timeStr..str.."("..tostring(self.nstr)..")"
    local len = #strse
    if len < 1 then len = 1 end
    local wlen = width-len
    if wlen < 1 then wlen = 1 end
    wlen = width-(getLineLen(self.term,strse))
    self.maxln = writeWrapped(self.term,timeStr..str..(" "):rep(wlen).."("..tostring(self.nstr)..")")
    self.term.setBackgroundColor(tb);self.term.setTextColor(tt)
end

local function createLog(termObj)
    return setmetatable({
        lastLog="",
        nstr=1,
        maxln=1,
        term=termObj
    },{__index=index})
end

return {create_log=createLog}
