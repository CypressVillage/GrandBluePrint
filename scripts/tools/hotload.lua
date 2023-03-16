local _G = GLOBAL or _G
local MODROOT = MODROOT or ''
local USERFUNPATH = MODROOT..'scripts/userscripts/'

if not log then
    log = print
end

log('USERFUNPATH: '..USERFUNPATH)


-- 将字符串分割为table
GBP_split = function(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

-- 用一种难看的方法来实现io.dir
io.dir = function(path)
    local f = io.open(USERFUNPATH..'dir.txt', 'r')
    if f then
        log('io.dir success')
        local str = f:read('*a')
        log('dir.txt:'..str)
        f:close()
        print(str)
        local rtn = GBP_split(str, '\n')
        table.remove(rtn) -- 去掉最后一个空字符串
        return rtn
    else
        log('io.dir failed')
        return {}
    end
end

-- 加载用户定义的脚本
local function loadUserFun()
    local files = io.dir(USERFUNPATH)
    for _, file in ipairs(files) do
        log('filename: '..file)
        -- if file:sub(-4) == '.lua' then
            log('find a lua file: '..file)
            local path = USERFUNPATH..file
            -- d = assert(loadfile(path, "bt", _G))
            local d = require(file)
            -- if d then
                log('load user script: '..file)
            --     d()
            -- end
        -- end
    end
end

-- 热加载，并将用户定义的函数写到文件中
local function hotload(str, name)
    local d = loadstring(str, name)
    if d then
        d()
    end
    
    local f = io.open(USERFUNPATH..name, 'w')
    f:write(str)
    f:close()
    
end

loadUserFun()
-- d.GBPtest()
log('almost win')

-- function eval(equation, variables)
--     if(type(equation) == "string") then
--         local eval = loadstring("return "..equation);
--         if(type(eval) == "function") then
--             setfenv(eval, variables or {});
--             return eval();
--         end
--     end
-- end