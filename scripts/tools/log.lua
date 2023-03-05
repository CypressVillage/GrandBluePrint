local modname = modname or 'log'
local LOGPATH = '../mods/'..modname..'/log/' or 'log/'
local LOGPATH = 'log/'

local LOGPS1 = '[GBP] '

local file = nil

local function getTimestamp()
    local time = os.date('*t')
    local rtn = string.format('%04d-%02d-%02d-%02d-%02d-%02d', time.year, time.month, time.day, time.hour, time.min, time.sec)
    return rtn
end


local function logopen(type)
    type = type or 'log_'
    local fname = LOGPATH..type..getTimestamp()..'.txt'
    file = io.open(fname, 'a')
    if file == nil then
        print('[GBP]: log file open failed')
    end
end

local function logclose()
    io.close(file)
end

-- 创建日志文件
local function log(str, type)
    file:write(str..'\n')
end

logopen()
log(LOGPS1..'log test')
logclose()