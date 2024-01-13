local _G = GLOBAL
--[[
    LOG_LEVEL
    0: 不打印信息，不写入log文件
    1: 打印信息，写入log文件
    2: 打印信息并announce，写入log文件
    ]]
_G.LOG_LEVEL = 0
local MODROOT = MODROOT or ''
local LOGPATH = MODROOT .. 'log/'

local LOGPS1 = '[GBP LOG]: '
local LOGPS2 = '[GBP DEBUG]: '
local LOGPS3 = '[GBP ERROR]: '
local file
local first = true
local DEBUG_GBP = true

-- 获取时间戳
local function getTimestamp()
    local time = os.date('*t')
    local rtn = string.format('%04d-%02d-%02d-%02d-%02d-%02d', time.year, time.month, time.day, time.hour, time.min,
        time.sec)
    return rtn
end

-- 打开日志文件
local function logopen(typ)
    typ = typ or ''
    local fname = LOGPATH .. typ .. 'log_' .. getTimestamp() .. '.txt'

    if first then
        local file = io.open(fname, "w")
        file:close()
        file = nil
        first = false
    end
    local res, re
    file, res = io.open(fname, "r")
    if file then
        re = file:read('*a')
        file:close()
    end

    file = io.open(fname, "w")
    if re then
        file:write(re)
    end
end

-- 关闭日志文件
local function logclose()
    io.close(file)
end

-- 写入日志
local function log(str, typ)
    local typ = typ or LOGPS1
    file:write(typ .. str .. '\n')
end

-- 全局DEBUG
_G.dbg = function(str)
    if not DEBUG_GBP then return end
    if LOG_LEVEL >= 1 then
        log(str, LOGPS2)
    end
    _G.c_announce(LOGPS2 .. str)
    print(LOGPS2 .. str)
end

-- 加载时打开日志文件
-- if LOG_LEVEL == 2 then
--     logopen()
-- end

_G.logopen = logopen
_G.logclose = logclose
_G.log = log
