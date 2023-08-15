--[==[ 工具函数库
    _G.pairsByKeys(t)
    table.tostr
]==]

local _G = GLOBAL

-- 顺序遍历表
_G.pairsByKeys = function(t)
    local a = {}
    for n in pairs(t) do
        a[#a + 1] = n
    end
    table.sort(a)

    local i = 0
    return function()
        i = i + 1
        return a[i], t[a[i]]
    end
end

-- 打印整张表，2个参数，level是展开几级子表
local TAB = '  '
table.tostr = function (t, level, newline, pre, tab, lv)
    local level = level or 10
    local tab = tab or ''
    local rtn = pre or ('{')
    local lv = lv or 0

    for index, value in pairs(t) do
        if newline then rtn = rtn..'\n'..tab..TAB else rtn = rtn..' ' end
        if type(value) == 'table' then
            if lv < level then
                rtn = rtn..tostring(index)..' = '..table.tostr(value, level, newline, pre, tab..TAB, lv+1)..','
            else
                rtn = rtn..tostring(index)..' = { ... },'
            end
        else
            rtn = rtn..tostring(index)..' = '..tostring(value)..','
        end
    end
    if newline then rtn = rtn..'\n'..tab..'}' else rtn = rtn..' '..'}' end
    return rtn
end

-- 返回元素在表中的位置，返回nil表示没找到
table.indexof = function(table, val)
    for id, v in pairs(table) do
        if val == v then return id end
    end
    dbg('table.indexof: '..tostring(val)..' not found in table')
    return nil
end

-- 获取表中元素个数，不包括nil但包括空表
table.size = function(tab)
    local num = 0
    for _, v in pairs(tab) do
        if v ~= nil then
            num = num + 1
        end
    end
    return num
end

-- 删除表中的重复元素，能处理空表
table.unique = function(t)
    local hash = {}
    local res = {}
    for _,v in ipairs(t) do
        if (not hash[v]) then
            res[#res+1] = v
            hash[v] = true
        end
    end
    return res
end
