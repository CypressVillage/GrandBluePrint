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

-- 打印整张表，level是展开几级子表
local TAB = '....'
_G.ShowTable = function (t, level, pre, tab, lv)
    local level = level or 10
    local tab = tab or ''
    local rtn = pre or ('{')
    local lv = lv or 0
    for index, value in ipairs(t) do
        if type(value) == 'table' then
            if lv < level then
                rtn = rtn..'\n'..tab..TAB.._G.ShowTable(value, level, pre, tab..TAB, lv+1)..','
            else
                rtn = rtn..'\n'..tab..TAB..'{ ... }'..','    
            end
        else
            rtn = rtn..'\n'..tab..TAB..tostring(index)..' = '..tostring(value)..','
        end
    end
    rtn = rtn..'\n'..tab..'}'
    return rtn
end

-- 全局DEBUG
_G.dbg = function(str)
    local rtn = 'GBP_DEBUG_INFO>>>'..str
    print(rtn)
    if DEBUG_GBP then
        c_announce(rtn)
    end
end

-- 判断元素是否在表中，返回位置，返回0表示没找到
_G.findIndex = function(val, table)
    for id, v in pairs(table) do
        if val == v then return id end
    end
    return 0
end

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

-- 删除表中重复元素
_G.table:DeleteEqualElement = function(table)
    local exist = {}
    --把相同的元素覆盖掉
    for v, k in pairs(table) do
        exist[k] = true
    end
    --重新排序表
    local newTable = {}
    for v, k in pairs(exist) do
        table.insert(newTable, v)
    end
    return newTable
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