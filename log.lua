local index = {}

function index:log(str,type)
    type = type or "info"
    if self.lastLog == str..type then
        self.nstr = self.nstr + 1
        local x,y = self.term.getCursorPos()
        self.term.setCursorPos(x,y-1)
        self.term.clearLine()
    else
        self.nstr = 1
    end
    self.lastLog = str..type
    local width = self.term.getSize()
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
    local len = #str+#timeStr+#("("..tostring(self.nstr)..")")
    if len < 2 then len = 2 end
    self.term.write(timeStr..str..(" "):rep(width-len).."("..tostring(self.nstr)..")")
    local _,y = self.term.getCursorPos()
    self.term.setCursorPos(1,y+1)
    self.term.setBackgroundColor(tb);self.term.setTextColor(tt)
end

local function createLog(termObj)
    return setmetatable({
        lastLog="",
        nstr=1,
        term=termObj
    },{__index=index})
end

return {create_log=createLog}
