local function getLine(files, line)
    local l = 1
    local out = {}
    local file = fs.open(files, "r")
    repeat
        out[l] = file.readLine()
        l = l + 1
    until not out[l - 1]
	file.close()
    return out[line]
end
local function writeLine(files, line, data, overhead)
    local l = 1
    local alldata = {}
    while getLine(files, l) do
        alldata[l] = getLine(files, l)
        l = l + 1
    end
    alldata[line] = data
    local file = fs.open(files, "w")
    for i = 1, #alldata + line + (overhead or 1) do
        file.writeLine(alldata[i])
    end
    file.close()
end
local function clear(file)
	fs.open(file,"w").close()
end
local function length(tbl)
    local biggest = 0
    for k in pairs(tbl) do
        if type(k) == "number" then
            biggest = math.max(biggest, k)
        end
    end
    return biggest
end
local function ser(ins)
    local out = {}
    local start = 1
    for i = 1, length(ins) do
        if ins[i] ~= nil then
            out[start] = ins[i]
            start = start + 1
        end
    end
    return out
end
return {
    getLine = getLine,
    writeLine = writeLine,
	clear = clear,
	length = length,
	ser = ser
}
