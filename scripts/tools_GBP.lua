--[[
    存放工具函数
]]--

local _G = GLOBAL
_G.DEBUG_GBP = true

-- 计算时间开销
_G.tim1 = os.clock
_G.tim2 = function (str)
    return string.format(str..'total time: %.2fms\n', (os.clock() - _G.tim1())*1000)
end

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
_G.ShowTable = function (t, level, newline, pre, tab, lv)
    local level = level or 10
    local tab = tab or ''
    local rtn = pre or ('{')
    local lv = lv or 0

    for index, value in pairs(t) do
        if newline then rtn = rtn..'\n'..tab..TAB else rtn = rtn..' ' end
        if type(value) == 'table' then
            if lv < level then
                rtn = rtn..tostring(index)..' = '..ShowTable(value, level, newline, pre, tab..TAB, lv+1)..','
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

-- 全局DEBUG
_G.dbg = function(str)
    local rtn = '[GBP DEBUG] '..str
    print(rtn)
    if DEBUG_GBP then
        c_announce(rtn)
    end
end

-- 判断元素是否在表中，返回位置，返回nil表示没找到
table.indexof = function(table, val)
    for id, v in pairs(table) do
        if val == v then return id end
    end
    dbg('table.indexof: '..tostring(val)..' not found in table')
    return nil
end
-- _G.findIndex = function(val, table)
--     for id, v in pairs(table) do
--         if val == v then return id end
--     end
--     return 0
-- end

-- 获取表中元素个数，不包括nil但包括空表
_G.getTableSize = function(tab)
    local num = 0
    for _, v in pairs(tab) do
        if v ~= nil then
            num = num + 1
        end
    end
    return num
end

-- 删除表中的重复元素，能处理空表
_G.delRepeat = function(tab)
    local rtn = {}
    for _, v in pairs(tab) do
        if 0 ~= _G.findIndex(v, rtn) then
            rtn[#rtn+1] = v
        end
    end
    return rtn
end

--[ 地图图标注册 ]--  >>from Legion<<
_G.RegistMiniMapImage_legion = function(filename, fileaddresspre)
    local fileaddresscut = (fileaddresspre or "images/map_icons/")..filename
    
    table.insert(Assets, Asset("ATLAS", fileaddresscut..".xml"))
    table.insert(Assets, Asset("IMAGE", fileaddresscut..".tex"))
    
    AddMinimapAtlas(fileaddresscut..".xml")

    --  接下来就需要在prefab定义里添加：
    --      inst.entity:AddMiniMapEntity()
    --      inst.MiniMapEntity:SetIcon("图片文件名.tex")
end