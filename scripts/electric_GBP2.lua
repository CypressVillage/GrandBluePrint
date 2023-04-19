--[[
    这个文件用来维护全局的电路系统

    性能优化的版本，可读性差
    同时为了保证性能，将不会有传参是否合法的判断

    接口说明：
    1. getLinkedThings(GUID)：获取GUID导线的连接内容，返回一个table
        left：左边的导线GUID
        right：右边的导线GUID
        up：上边的导线GUID
        down：下边的导线GUID
        other：连接的电器GUID
    2. wireDeployed(wire)：导线被放置时调用，参数为导线实体
    3. wireRemoved(wire)：导线被移除时调用，参数为导线实体
    4. ShowElecInfo()：调试用，显示所有导线的信息
]]--

local _G = GLOBAL
local NWIRE = _G.CONFIGS_GBP.NWIRE

GBP_ELECTRIC = {}
setmetatable(GBP_ELECTRIC, {__index = _G})
setfenv(1, GBP_ELECTRIC)


-- 导线的所有信息，索引都是GUID
local LINK_L = {} LINK_L[NWIRE] = nil                       -- 左
local LINK_R = {} LINK_R[NWIRE] = nil                       -- 右
local LINK_U = {} LINK_U[NWIRE] = nil                       -- 上
local LINK_D = {} LINK_D[NWIRE] = nil                       -- 下
local POWERORCONSUMERS = {} POWERORCONSUMERS[NWIRE] = nil   -- 电器
local WIREINSYS = {} WIREINSYS[NWIRE] = nil                 -- 所在系统ID

-- 系统的所有信息，索引也为ID
local NEWSYSID = 0                                          -- 新系统ID
local SYSINFO = {}                                          -- 系统内容
-- SYSINFO = {
--     [id] = {
--         wires = {GUID, GUID, ...},
--         powers = {GUID, GUID, ...},
--         consumers = {GUID, GUID, ...},
--     },
--     ...
-- }

--[[ 接口，获取导线连接内容 ]]--
_G.getLinkedThings = function(GUID)
    return {
        left = LINK_L[GUID],
        right = LINK_R[GUID],
        up = LINK_U[GUID],
        down = LINK_D[GUID],
        other = POWERORCONSUMERS[GUID],
    }
end

--[[ 接口，获取用电器连接的第一根导线 ]]--
_G.getfirstWire = function(GUID)
    return table.indexof(POWERORCONSUMERS, GUID)
end

--[[ 接口，获取导线所在系统 ]]--
_G.wireInSys = function(GUID)
    return WIREINSYS[GUID]
end

-- [[ 接口，获取系统信息 ]]--
_G.getsysThings = function(sysID)
    return SYSINFO[sysID]
end

--[[ 注册一个新导线的一切，返回ID ]]--
local function regiWire(wire)
    local id = wire.GUID
    -- table.insert(GUIDT, id)

    local x, y, z = wire.Transform:GetWorldPosition()
    local elements = TheSim:FindEntities(x,0,z, 1, {}, {}, {'consumer', 'power'})
    if elements[1] then
        POWERORCONSUMERS[id] = elements[1].GUID
    end

    local neighbors = TheSim:FindEntities(x,0,z, 1, {'electricwire'})
    for i = 1, #neighbors do
        local nGUID = neighbors[i].GUID
        local nx, ny, nz = neighbors[i].Transform:GetWorldPosition()
        local dx, dz = nx-x, nz-z
        if dx == 1 and dz == 0 then
            LINK_D[id] = nGUID
            LINK_U[nGUID] = wire.GUID
        elseif dx == -1 and dz == 0 then
            LINK_U[id] = nGUID
            LINK_D[nGUID] = wire.GUID
        elseif dx == 0 and dz == 1 then
            LINK_R[id] = nGUID
            LINK_L[nGUID] = wire.GUID
        elseif dx == 0 and dz == -1 then
            LINK_L[id] = nGUID
            LINK_R[nGUID] = wire.GUID
        end
    end
    dbg(_G.ShowWireInfo(wire.GUID))
    return id
end

--[[ 寻找导线连接的系统，返回系统的可重复ID ]]--
local function getLinkSys(wire)
    local id = wire.GUID
    local links = {}
    if LINK_L[id] then
        table.insert(links, WIREINSYS[LINK_L[id]])
    end
    if LINK_R[id] then
        table.insert(links, WIREINSYS[LINK_R[id]])
    end
    if LINK_U[id] then
        table.insert(links, WIREINSYS[LINK_U[id]])
    end
    if LINK_D[id] then
        table.insert(links, WIREINSYS[LINK_D[id]])
    end
    return links
end

--[[ 注册导线，新建系统，合并系统（如果有的话）]]--
local function wireDeployed(wire)
    local id = regiWire(wire)

    NEWSYSID = NEWSYSID+1
    local newSysID = NEWSYSID
    WIREINSYS[id] = newSysID

    SYSINFO[newSysID] = { -- 不管有没有连接的系统都要新建一个系统
        wires = {
            wire.GUID,
        },
        consumers = {},
        powers = {},
    }

    if POWERORCONSUMERS[id] then -- 如果连接了电器就加入
        if Ents[POWERORCONSUMERS[id]]:HasTag('power') then
            table.insert(SYSINFO[newSysID].powers, POWERORCONSUMERS[id])
        elseif Ents[POWERORCONSUMERS[id]]:HasTag('consumer') then
            table.insert(SYSINFO[newSysID].consumers, POWERORCONSUMERS[id])
        end
    end

    local linkt = getLinkSys(wire)
    if linkt then -- 如果连接了其他就合并过来
        for i, oldsysID in pairs(linkt) do
            if SYSINFO[oldsysID] then -- 加这层判断是因为有可能合并过程中已经被移除了，其实是getLinkSys可能有重复元素的锅
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

    SYSINFO[newSysID].powers = table.unique(SYSINFO[newSysID].powers)
    SYSINFO[newSysID].consumers = table.unique(SYSINFO[newSysID].consumers)

    dbg(ShowElecInfo())
end

--[[ 注销系统，重新注册系统中的导线 ]]--
local function removeWire(wire)
    local id = wire.GUID
    local sysID = WIREINSYS[id]
    local wire2reset = {}

    if LINK_L[id] then
        LINK_R[LINK_L[id]] = nil
    end
    if LINK_R[id] then
        LINK_L[LINK_R[id]] = nil
    end
    if LINK_U[id] then
        LINK_D[LINK_U[id]] = nil
    end
    if LINK_D[id] then
        LINK_U[LINK_D[id]] = nil
    end
    if POWERORCONSUMERS[id] then
        POWERORCONSUMERS[id] = nil
    end

    for _, itemID in pairs(SYSINFO[sysID].wires) do
        if itemID ~= id and Ents[itemID] then
            table.insert(wire2reset, itemID) -- 记录需要重新注册的导线
            WIREINSYS[itemID] = nil
        end
    end
    WIREINSYS[id] = nil
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

--[[ 显示全局电路信息 ]]--
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
    local x, y, z = obj.Transform:GetWorldPosition()
    local elements = TheSim:FindEntities(x,0,z, 0.5, {'electricwire'})
    if elements[1] then
        local id = elements[1].GUID
        POWERORCONSUMERS[id] = obj.GUID

        local sysID = WIREINSYS[id]
        if obj:HasTag('power') then
            table.insert(SYSINFO[sysID].powers, obj.GUID)
        elseif obj:HasTag('consumer') then
            table.insert(SYSINFO[sysID].consumers, obj.GUID)
        end
    end
end

_G.OnRemoveEleAppliance = function(obj)
    local x, y, z = obj.Transform:GetWorldPosition()
    local elements = TheSim:FindEntities(x,0,z, 0.5, {'electricwire'})
    if elements[1] then
        local id = elements[1].GUID
        if POWERORCONSUMERS[id] == obj.GUID then
            POWERORCONSUMERS[id] = nil
        end

        local sysID = WIREINSYS[id]
        if obj:HasTag('power') then
            table.remove(SYSINFO[sysID].powers, table.indexof(SYSINFO[sysID].powers, obj.GUID))
        elseif obj:HasTag('consumer') then
            table.remove(SYSINFO[sysID].consumers, table.indexof(SYSINFO[sysID].consumers, obj.GUID))
        end
    end
end

_G.WireDeployed = wireDeployed
_G.wireRemoved = removeWire

setfenv(1, _G)