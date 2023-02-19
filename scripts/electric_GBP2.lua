--[[
    性能优化的版本，可读性差
    同时为了保证性能，将不会有传参是否合法的判断
]]--

local _G = GLOBAL
local NWIRE = _G.CONFIGS_GBP.NWIRE

-- 导线的所有信息，除反向表外索引都是ID
local GUIDT = {} GUIDT[NWIRE] = nil                         -- GUID
local GUID2ID = {} GUID2ID[NWIRE] = nil                     -- GUID反向表
local LINK_L = {} LINK_L[NWIRE] = nil                       -- 左
local LINK_R = {} LINK_R[NWIRE] = nil                       -- 右
local LINK_U = {} LINK_U[NWIRE] = nil                       -- 上
local LINK_D = {} LINK_D[NWIRE] = nil                       -- 下
local POWERORCONSUMERS = {} POWERORCONSUMERS[NWIRE] = nil   -- 电器
local WIREINSYS = {} WIREINSYS[NWIRE] = nil                 -- 所在系统ID
local WIREINVALID = {} WIREINVALID[NWIRE] = nil             -- 是否移除

-- 系统的所有信息，索引也为ID
local SYSINFO = {}                                          -- 系统内容
local SYSINVALID = {}                                       -- 是否移除

local function regi()
    
end

--[[
    注册一个新导线的一切，返回ID
]]
local function regiWire(wire)
    GUIDT[#GUIDT+1] = wire.GUID
    local id = #GUIDT
    GUID2ID[wire.GUID] = id
    WIREINVALID[id] = false

    local x, y, z = wire.Transform:GetWorldPosition()
    local elements = TheSim:FindEntities(x,0,z, 1, {}, {}, {'consumer', 'power'})
    if elements then
        POWERORCONSUMERS[id] = elements[1].GUID
    end

    local neighbors = TheSim:FindEntities(x,0,z, 1, {'wire'})
    for i = 1, #neighbors do
        local nGUID = neighbors[i].GUID
        local nx, ny, nz = neighbors[i].Transform:GetWorldPosition()
        local dx, dz = nx-x, nz-z
        if dx == 1 and dz == 0 then
            LINK_D[id] = nGUID
        elseif dx == -1 and dz == 0 then
            LINK_U[id] = nGUID
        elseif dx == 0 and dz == 1 then
            LINK_R[id] = nGUID
        elseif dx == 0 and dz == -1 then
            LINK_L[id] = nGUID
        end
    end
    return id
end
_G.RegiWire = regiWire

--[[
    寻找导线连接的系统
]]
local function getLinkSys(wire)
    local id = GUID2ID[wire.GUID]
    local links = {nil, nil, nil, nil}
    if LINK_L[id] then
        links[#links+1] = WIREINSYS[GUID2ID[LINK_L[id]]]
    end
    if LINK_R[id] then
        links[#links+1] = WIREINSYS[GUID2ID[LINK_R[id]]]
    end
    if LINK_U[id] then
        links[#links+1] = WIREINSYS[GUID2ID[LINK_U[id]]]
    end
    if LINK_D[id] then
        links[#links+1] = WIREINSYS[GUID2ID[LINK_D[id]]]
    end
    return table.DeleteEqualElement(links)
end


local function wireDeployed(wire)
    local id = regiWire(wire)
    local linkt = getLinkSys(wire)
    local newSysID = #SYSINFO+1
    if next(linkt) ~= nil then -- 合并系统
        local newsys = {
            wires = {wire.GUID},
            consumers = {wire:HasTag('consumer') or nil},
            powers = {wire:HasTag('power') or nil},
        }
        for i, oldsysID in pairs(linkt) do
            SYSINVALID[oldsysID] = true
            table.insert(newsys.wires, )
        end
    else -- 新建系统
        SYSINFO[newSysID] = {
            wires = {
                wire,
            }
        }
        SYSINVALID[newSysID] = false
        WIREINSYS[id] = newSysID
    end
end
_G.WireDeployed = wireDeployed