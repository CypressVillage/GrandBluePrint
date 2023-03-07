local modname = modname or 'log'
local LOGPATH = '../mods/'..modname..'/log/' or 'log/'
local LOGPATH = 'log/' -- 不开游戏测试用这个

local LOGPS1 = '[GBP LOG]: '
local LOGPS2 = '[GBP ERROR]: '
local file

-- 获取时间戳
local function getTimestamp()
    local time = os.date('*t')
    local rtn = string.format('%04d-%02d-%02d-%02d-%02d-%02d', time.year, time.month, time.day, time.hour, time.min, time.sec)
    return rtn
end

-- 打开日志文件
local function logopen(typ)
    if file ~= nil then logclose() end

    typ = typ or ''
    local fname = LOGPATH..typ..'log_'..getTimestamp()..'.txt'
    file = io.open(fname, 'a')
    if file == nil then print('[GBP ERROR]: log file open failed') end
end
_G.logopen = logopen

-- 关闭日志文件
local function logclose()
    io.close(file)
end

-- 写入日志
local function log(str, typ)
    local typ = typ or LOGPS1
    file:write(typ..str..'\n')
end
_G.log = log

logopen()


_G.DEBUG_GBP = true

-- -- 计算时间开销
-- _G.tim1 = os.clock
-- _G.tim2 = function (str)
--     return string.format(str..'total time: %.2fms\n', (os.clock() - _G.tim1())*1000)
-- end

-- 全局DEBUG
_G.dbg = function(str)
    local rtn = '[GBP DEBUG] '..str
    print(rtn)
    if DEBUG_GBP then
        c_announce(rtn)
    end
end

