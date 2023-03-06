--[[
    逻辑系统
]]

local LINK_L = {} LINK_L[NWIRE] = nil                       -- 左
local LINK_R = {} LINK_R[NWIRE] = nil                       -- 右
local LINK_U = {} LINK_U[NWIRE] = nil                       -- 上
local LINK_D = {} LINK_D[NWIRE] = nil                       -- 下
local MACHINES = {} MACHINES[NWIRE] = nil                   -- 机器
local WIREINSYS = {} WIREINSYS[NWIRE] = nil                 -- 所在系统ID
-- 系统的所有信息，索引也为ID
local NEWSYSID = 0                                          -- 新系统ID
local SYSINFO = {}                                          -- 系统内容
-- SYSINFO = {
--     [id] = {
--         wires = {GUID, GUID, ...},
--         machines = {GUID, GUID, ...},
--         inputs = {GUID, GUID, ...},
--         outputs = {GUID, GUID, ...},
--     },
--     ...
-- }

-- [[ 注册信号线 ]] --
local function regiLogicWire(wire)
    local GUID = wire.GUID
    
    local x, y, z = wire.Transform:GetWorldPosition()
    local elements = TheSim:FindEntities(x,0,z, 1, {}, {}, { 'machine' })
    if elements[1] then
        POWERORCONSUMERS[id] = elements[1].GUID
    end

    local neighbors = TheSim:FindEntities(x,0,z, 1, {'logicwire'})
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
    dbg(_G.ShowLogicWireInfo(wire.GUID))
    return id
end

-- [[ 寻找导线连接的系统，返回系统的可重复ID ]] --
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

-- [[ 注册导线，新建系统，合并系统（如果有的话） ]] --
local function wireDeployed(wire)
    local id = regiLogicWire(wire)
    
    NEWSYSID = NEWSYSID+1
    local newSysID = NEWSYSID
    WIREINSYS[id] = newSysID
    
    SYSINFO[newSysID] = { -- 不管有没有连接的系统都要新建一个系统
        wires = {
            wire.GUID,
        },
        inputs = {},
        outputs = {},
    }

    if MACHINES[id] then
        table.insert(SYSINFO[newSysID].machines, MACHINES[id])
    end

    local links = getLinkSys(wire)
    if links then
        for i, oldsysID in ipairs(links) do
            if SYSINFO[oldsysID] then
                for _, wid in ipairs(SYSINFO[oldsysID].wires) do
                    WIREINSYS[wid] = newSysID
                    table.insert(SYSINFO[newSysID].wires, wid)
                end
                SYSINFO[oldsysID] = nil
            end
        end
    end
end

--[[ 注销系统，重新注册系统中的导线 ]]--
local function wireRemoved(wire)
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
    if MACHINES[id] then
        MACHINES[id] = nil
    end

    for _, wid in ipairs(SYSINFO[sysID].wires) do
        if wid ~= id and Ents[wid] then
            table.insert(wire2reset, wid)
            WIREINSYS[wid] = nil
        end
    end
    SYSINFO[sysID] = nil
    WIREINSYS[id] = nil

    for _, wid in ipairs(wire2reset) do
        wireDeployed(Ents[wid])
    end
end

