--[[
    这个文件用来维护全局的电路系统

    性能优化的版本，可读性差
    同时为了保证性能，将不会有传参是否合法的判断

    接口说明：
    1. getLinkedThings(GUID)：获取GUID导线的连接内容
    2. getfirstWire(GUID)：获取GUID电器连接的第一根导线
    3. getSysID(GUID)：获取GUID导线所在的系统ID
    4. getSysInfo(sysID)：获取sysID系统的内容

    6. WireDeployed(wire)：导线被放置时调用，参数为导线实体
    7. WireRemoved(wire)：导线被移除时调用，参数为导线实体
    8. ShowElecInfo()：调试用，显示所有导线的信息
]]

local _G = GLOBAL
local NWIRE = _G.CONFIGS_GBP.NWIRE -- 初始化时按设置的导线数量分配内存
-- TODO: 验证Ents是否会随着_G.Ents的变化而变化
local Ents = _G.Ents

-- 导线的所有信息，索引是GUID
local LINK_L = {} LINK_L[NWIRE] = nil                       -- 左
local LINK_R = {} LINK_R[NWIRE] = nil                       -- 右
local LINK_U = {} LINK_U[NWIRE] = nil                       -- 上
local LINK_D = {} LINK_D[NWIRE] = nil                       -- 下
local POWERORCONSUMERS = {} POWERORCONSUMERS[NWIRE] = nil   -- 电器
local WIREINSYS = {} WIREINSYS[NWIRE] = nil                 -- 导线所在系统的ID

-- 系统的所有信息，索引为系统的sysID，从1开始
local NEWSYSID = 0                                          -- 新系统sysID
local SYSINFO = {}                                          -- 系统内容
-- SYSINFO = {
--     [wireGUID] = {
--         wires = {GUID, GUID, ...},
--         powers = {GUID, GUID, ...},
--         consumers = {GUID, GUID, ...},
--     },
--     ...
-- }

--[[ 获取导线连接内容 ]]
_G.getLinkedThings = function(wireGUID)
    return {
        left = LINK_L[wireGUID],
        right = LINK_R[wireGUID],
        up = LINK_U[wireGUID],
        down = LINK_D[wireGUID],
        other = POWERORCONSUMERS[wireGUID],
    }
end

--[[ 获取用电器连接的第一根导线，返回nil表示用电器没有和导线链接 ]]
_G.getfirstWire = function(GUID)
    return table.indexof(POWERORCONSUMERS, GUID)
end

--[[ 获取导线所在系统 ]]
_G.getSysID = function(wireGUID)
    return WIREINSYS[wireGUID]
end

--[[ 获取机器所在系统的ID ]]
_G.getSysIDbyMachine = function(inst)
    local wireGUID = _G.getfirstWire(inst.GUID)
    if wireGUID ~= nil then
        return _G.getSysID(wireGUID)
    end
    return nil
end

-- [[ 获取系统信息 ]]
_G.getSysInfo = function(sysID)
    return SYSINFO[sysID]
end

--[[ 注册一个新导线，返回ID。
    param: wire 导线实体
    return: wireGUID 导线的GUID
]]
local function regiWire(wire)
    local wireGUID = wire.GUID

    -- 注册新导线连接的用电器，只注册一个（一般不会注册一个以上。。。吧）
    local x, _, z = wire.Transform:GetWorldPosition()
    local elements = TheSim:FindEntities(x, 0, z, 1, {}, {}, {'consumer', 'power'})
    if elements[1] then
        POWERORCONSUMERS[wireGUID] = elements[1].GUID
    end

    -- 注册新导线连接的导线
    local neighbors = TheSim:FindEntities(x,0,z, 1, {'electricwire'})
    for i = 1, #neighbors do
        local neighborGUID = neighbors[i].GUID
        local nx, _, nz = neighbors[i].Transform:GetWorldPosition()
        local dx, dz = nx-x, nz-z
        if dx == 1 and dz == 0 then
            LINK_D[wireGUID] = neighborGUID
            LINK_U[neighborGUID] = wire.GUID
        elseif dx == -1 and dz == 0 then
            LINK_U[wireGUID] = neighborGUID
            LINK_D[neighborGUID] = wire.GUID
        elseif dx == 0 and dz == 1 then
            LINK_R[wireGUID] = neighborGUID
            LINK_L[neighborGUID] = wire.GUID
        elseif dx == 0 and dz == -1 then
            LINK_L[wireGUID] = neighborGUID
            LINK_R[neighborGUID] = wire.GUID
        end
    end
    -- dbg(_G.ShowWireInfo(wire.GUID))
    -- dbg('new wire '..wire.GUID)
    return wireGUID
end

--[[ 
    寻找导线连接的系统，返回系统的不重复ID。
    因为此时正在合并系统，所以导线可能找到多个系统
]]
local function getLinkSys(wire)
    local wireGUID = wire.GUID
    local links = {}
    if LINK_L[wireGUID] then
        table.insert(links, WIREINSYS[LINK_L[wireGUID]])
    end
    if LINK_R[wireGUID] then
        table.insert(links, WIREINSYS[LINK_R[wireGUID]])
    end
    if LINK_U[wireGUID] then
        table.insert(links, WIREINSYS[LINK_U[wireGUID]])
    end
    if LINK_D[wireGUID] then
        table.insert(links, WIREINSYS[LINK_D[wireGUID]])
    end
    return table.unique(links)
end

--[[
    导线被放置时对系统的更改
    注册导线，新建系统，合并系统（如果有的话）
    可能改变的内容：
        新导线的链接状态（在regiWire()中更改）
        旧导线的链接状态不用更改（在regiWire()中，相关旧导线的链接状态已经更改）
        新系统中加入新导线的部分
        新系统中加入旧导线的部分
        旧导线所在系统要更改

    TODO: 是否可以将regiWire和这个函数分开，保证这个函数执行的时候，导线的链接关系永远是正确的？
]]
local function wireDeployed(wire)
    local wireGUID = regiWire(wire)

    NEWSYSID = NEWSYSID+1
    local newSysID = NEWSYSID

    WIREINSYS[wireGUID] = newSysID
    SYSINFO[newSysID] = { -- 不管有没有连接的系统都要新建一个系统
        wires = {
            wire.GUID,
        },
        consumers = {},
        powers = {},
    }

    -- 如果新导线连接了电器就将其加入系统中
    if POWERORCONSUMERS[wireGUID] and Ents[POWERORCONSUMERS[wireGUID]] then
        if Ents[POWERORCONSUMERS[wireGUID]]:HasTag('power') then
            table.insert(SYSINFO[newSysID].powers, POWERORCONSUMERS[wireGUID])
        elseif Ents[POWERORCONSUMERS[wireGUID]]:HasTag('consumer') then
            table.insert(SYSINFO[newSysID].consumers, POWERORCONSUMERS[wireGUID])
        end
    end

    -- 将旧系统合并到新系统中
    local linkt = getLinkSys(wire)
    if linkt then
        for _, oldsysID in pairs(linkt) do
            if SYSINFO[oldsysID] then -- 加这层判断是因为有可能合并过程中已经被移除了，其实是getLinkSys可能有重复元素的锅，现在已经修复，这是一层保险。
                for _, itemID in pairs(SYSINFO[oldsysID].wires) do
                    table.insert(SYSINFO[newSysID].wires, itemID)
                    WIREINSYS[itemID] = newSysID
                end
                for _, itemID in pairs(SYSINFO[oldsysID].powers) do
                    table.insert(SYSINFO[newSysID].powers, itemID)
                end
                for _, itemID in pairs(SYSINFO[oldsysID].consumers) do
                    table.insert(SYSINFO[newSysID].consumers, itemID)
                end
                SYSINFO[oldsysID] = nil
            end
        end
    end

    -- 保险
    SYSINFO[newSysID].powers = table.unique(SYSINFO[newSysID].powers)
    SYSINFO[newSysID].consumers = table.unique(SYSINFO[newSysID].consumers)

    -- dbg(ShowElecInfo())
end

--[[ 注销系统，重新注册系统中的导线 ]]
local function removeWire(wire)
    local wireGUID = wire.GUID
    local sysID = WIREINSYS[wireGUID]
    local wire2reset = {}

    -- 删干净这个导线的链接情况，也包括相邻导线
    if LINK_L[wireGUID] then
        LINK_R[LINK_L[wireGUID]] = nil
        LINK_L[wireGUID] = nil
    end
    if LINK_R[wireGUID] then
        LINK_L[LINK_R[wireGUID]] = nil
        LINK_R[wireGUID] = nil
    end
    if LINK_U[wireGUID] then
        LINK_D[LINK_U[wireGUID]] = nil
        LINK_U[wireGUID] = nil
    end
    if LINK_D[wireGUID] then
        LINK_U[LINK_D[wireGUID]] = nil
        LINK_D[wireGUID] = nil
    end
    if POWERORCONSUMERS[wireGUID] then
        POWERORCONSUMERS[wireGUID] = nil
    end

    for _, itemID in pairs(SYSINFO[sysID].wires) do
        if itemID ~= wireGUID and Ents[itemID] then
            table.insert(wire2reset, itemID) -- 记录需要重新注册的导线
            WIREINSYS[itemID] = nil
        end
    end
    WIREINSYS[wireGUID] = nil
    SYSINFO[sysID] = nil

    for _, itemID in pairs(wire2reset) do
        wireDeployed(Ents[itemID])
    end

end

_G.ShowWireInfo = function(GUID)
    local str = ''
    str = str..'导线['..GUID..']: '
    if LINK_L[GUID] then
        str = str..'左:'..LINK_L[GUID]..','
    end
    if LINK_R[GUID] then
        str = str..'右:'..LINK_R[GUID]..','
    end
    if LINK_U[GUID] then
        str = str..'上:'..LINK_U[GUID]..','
    end
    if LINK_D[GUID] then
        str = str..'下:'..LINK_D[GUID]..',\n'
    end
    if POWERORCONSUMERS[GUID] then
        str = str..'连接的用电器:'..POWERORCONSUMERS[GUID]..','
    end
    if WIREINSYS[GUID] then
        str = str..'所属系统:'..WIREINSYS[GUID]..','
    end
    str = str..'\n'
    return str
end

--[[ 显示全局电路信息 ]]
_G.ShowElecInfo = function()
    local str = '全局电路信息:\n'
    for k, v in pairs(SYSINFO) do
        str = str..'电路['..tostring(k)..']:'
        str = str..'电源:'
        for kk, vv in pairs(v.powers) do
            str = str..tostring(vv)..','
        end
        str = str..'\n          导线:'
        for kk, vv in pairs(v.wires) do
            str = str..tostring(vv)..','
        end
        str = str..'\n          用电器:'
        for kk, vv in pairs(v.consumers) do
            str = str..tostring(vv)..'('..vv.prefab..'),'
        end
        str = str..'\n'
    end
    return str
end

_G.OnDeployEleAppliance = function(obj)
    local x, _, z = obj.Transform:GetWorldPosition()
    local elements = TheSim:FindEntities(x, 0, z, 0.5, {'electricwire'})
    if elements[1] then
        local wireGUID = elements[1].GUID
        POWERORCONSUMERS[wireGUID] = obj.GUID

        local sysID = WIREINSYS[wireGUID]
        if obj:HasTag('power') then
            table.insert(SYSINFO[sysID].powers, obj.GUID)
        elseif obj:HasTag('consumer') then
            table.insert(SYSINFO[sysID].consumers, obj.GUID)
        end
    end
end

_G.OnRemoveEleAppliance = function(obj)
    local x, y, z = obj.Transform:GetWorldPosition()
    local wires = TheSim:FindEntities(x,0,z, 0.5, {'electricwire'})
    if wires[1] then
        -- TODO: 我如何确保我一定能找到这个用电器？
        local wireGUID
        for _, wire in pairs(wires) do
            if POWERORCONSUMERS[wire.GUID] == obj.GUID then
                POWERORCONSUMERS[wire.GUID] = nil
                wireGUID = wire.GUID
                break
            end
        end

        local sysID = WIREINSYS[wireGUID]
        if obj:HasTag('power') then
            table.remove(SYSINFO[sysID].powers, table.indexof(SYSINFO[sysID].powers, obj.GUID))
        elseif obj:HasTag('consumer') then
            table.remove(SYSINFO[sysID].consumers, table.indexof(SYSINFO[sysID].consumers, obj.GUID))
        end
        dbg('wire '..wireGUID..'s '..obj.GUID..' removed')
    end
end

_G.WireDeployed = wireDeployed
_G.WireRemoved = removeWire


_G.ReCalculateSysInfo = function(sysID)
    
end