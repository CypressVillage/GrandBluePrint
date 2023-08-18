local NWIRE = CONFIGS_GBP.NWIRE

local ElectricSystem = Class(function(self, inst)
    self.inst = inst

    self.LINK_L = {} self.LINK_L[NWIRE] = nil
    self.LINK_R = {} self.LINK_R[NWIRE] = nil
    self.LINK_U = {} self.LINK_U[NWIRE] = nil
    self.LINK_D = {} self.LINK_D[NWIRE] = nil
    self.MACHINES = {} self.MACHINES[NWIRE] = nil
    self.WIREINSYS = {} self.WIREINSYS[NWIRE] = nil

    self.NEWSYSID = 0
    self.SYSINFO = {}
    -- 系统内容
    -- SYSINFO = {
    --     [wireGUID] = {
    --         wires = {GUID, GUID, ...},
    --         machines = {GUID, GUID, ...},
    --     },
    --     ...
    -- }
end,
nil,
{})

--[[ 获取导线连接内容 ]]
function ElectricSystem:getLinkedThings(wireGUID)
    return {
        left = self.LINK_L[wireGUID],
        right = self.LINK_R[wireGUID],
        up = self.LINK_U[wireGUID],
        down = self.LINK_D[wireGUID],
        other = self.MACHINES[wireGUID],
        -- TODO: other名字难听，换掉
    }
end

--[[ 获取用电器连接的第一根导线，返回nil表示用电器没有和导线链接 ]]
function ElectricSystem:getfirstWire(GUID)
    return table.indexof(self.MACHINES, GUID)
end

--[[ 获取导线所在系统 ]]
function ElectricSystem:getSysID(wireGUID)
    return self.WIREINSYS[wireGUID]
end

--[[ 获取机器所在系统的ID ]]
function ElectricSystem:getSysIDbyMachine(inst)
    local wireGUID = self:getfirstWire(inst.GUID)
    if wireGUID ~= nil then
        return self:getSysID(wireGUID)
    end
    return nil
end

-- [[ 获取系统信息 ]]
function ElectricSystem:getSysInfo(sysID)
    return self.SYSINFO[sysID]
end

--[[ 注册一个新导线，返回ID。
    param: wire 导线实体
    return: wireGUID 导线的GUID
]]
function ElectricSystem:regiWire(wire)
    local wireGUID = wire.GUID

    -- 注册新导线连接的用电器，只注册一个（一般不会注册一个以上。。。吧）
    local x, _, z = wire.Transform:GetWorldPosition()
    local elements = TheSim:FindEntities(x, 0, z, 1, {}, {}, {'electricmachine'})
    if elements[1] then
        self.MACHINES[wireGUID] = elements[1].GUID
    end

    -- 注册新导线连接的导线
    local neighbors = TheSim:FindEntities(x,0,z, 1, {'electricwire'})
    for i = 1, #neighbors do
        local neighborGUID = neighbors[i].GUID
        local nx, _, nz = neighbors[i].Transform:GetWorldPosition()
        local dx, dz = nx-x, nz-z
        if dx == 1 and dz == 0 then
            self.LINK_D[wireGUID] = neighborGUID
            self.LINK_U[neighborGUID] = wire.GUID
        elseif dx == -1 and dz == 0 then
            self.LINK_U[wireGUID] = neighborGUID
            self.LINK_D[neighborGUID] = wire.GUID
        elseif dx == 0 and dz == 1 then
            self.LINK_R[wireGUID] = neighborGUID
            self.LINK_L[neighborGUID] = wire.GUID
        elseif dx == 0 and dz == -1 then
            self.LINK_L[wireGUID] = neighborGUID
            self.LINK_R[neighborGUID] = wire.GUID
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
function ElectricSystem:getLinkSys(wire)
    local wireGUID = wire.GUID
    local links = {}
    if self.LINK_L[wireGUID] then
        table.insert(links, self.WIREINSYS[self.LINK_L[wireGUID]])
    end
    if self.LINK_R[wireGUID] then
        table.insert(links, self.WIREINSYS[self.LINK_R[wireGUID]])
    end
    if self.LINK_U[wireGUID] then
        table.insert(links, self.WIREINSYS[self.LINK_U[wireGUID]])
    end
    if self.LINK_D[wireGUID] then
        table.insert(links, self.WIREINSYS[self.LINK_D[wireGUID]])
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
function ElectricSystem:wireDeployed(wire)
    local wireGUID = self:regiWire(wire)

    self.NEWSYSID = self.NEWSYSID+1
    local newSysID = self.NEWSYSID

    self.WIREINSYS[wireGUID] = newSysID
    self.SYSINFO[newSysID] = { -- 不管有没有连接的系统都要新建一个系统
        wires = {
            wire.GUID,
        },
        machines = {},
    }

    -- 如果新导线连接了电器就将其加入系统中
    if self.MACHINES[wireGUID] and Ents[self.MACHINES[wireGUID]] then
        table.insert(self.SYSINFO[newSysID].machines, self.MACHINES[wireGUID])
    end

    -- 将旧系统合并到新系统中
    local linkt = self:getLinkSys(wire)
    if linkt then
        for _, oldsysID in pairs(linkt) do
            if self.SYSINFO[oldsysID] then -- 加这层判断是因为有可能合并过程中已经被移除了，其实是getLinkSys可能有重复元素的锅，现在已经修复，这是一层保险。
                for _, itemID in pairs(self.SYSINFO[oldsysID].wires) do
                    table.insert(self.SYSINFO[newSysID].wires, itemID)
                    self.WIREINSYS[itemID] = newSysID
                end
                for _, itemID in pairs(self.SYSINFO[oldsysID].machines) do
                    table.insert(self.SYSINFO[newSysID].machines, itemID)
                end
                self.SYSINFO[oldsysID] = nil
            end
        end
    end

    -- 保险
    self.SYSINFO[newSysID].machines = table.unique(self.SYSINFO[newSysID].machines)

    -- dbg(ShowElecInfo())
end

--[[ 注销系统，重新注册系统中的导线 ]]
function ElectricSystem:wireRemoved(wire)
    local wireGUID = wire.GUID
    local sysID = self.WIREINSYS[wireGUID]
    local wire2reset = {}

    -- 删干净这个导线的链接情况，也包括相邻导线
    if self.LINK_L[wireGUID] then
        self.LINK_R[self.LINK_L[wireGUID]] = nil
        self.LINK_L[wireGUID] = nil
    end
    if self.LINK_R[wireGUID] then
        self.LINK_L[self.LINK_R[wireGUID]] = nil
        self.LINK_R[wireGUID] = nil
    end
    if self.LINK_U[wireGUID] then
        self.LINK_D[self.LINK_U[wireGUID]] = nil
        self.LINK_U[wireGUID] = nil
    end
    if self.LINK_D[wireGUID] then
        self.LINK_U[self.LINK_D[wireGUID]] = nil
        self.LINK_D[wireGUID] = nil
    end
    if self.MACHINES[wireGUID] then
        self.MACHINES[wireGUID] = nil
    end

    for _, itemID in pairs(self.SYSINFO[sysID].wires) do
        if itemID ~= wireGUID and Ents[itemID] then
            table.insert(wire2reset, itemID) -- 记录需要重新注册的导线
            self.WIREINSYS[itemID] = nil
        end
    end
    self.WIREINSYS[wireGUID] = nil
    self.SYSINFO[sysID] = nil

    for _, itemID in pairs(wire2reset) do
        self:wireDeployed(Ents[itemID])
    end

end

function ElectricSystem:ShowWireInfo(GUID)
    local str = ''
    str = str..'导线['..GUID..']: '
    if self.LINK_L[GUID] then
        str = str..'左:'..self.LINK_L[GUID]..','
    end
    if self.LINK_R[GUID] then
        str = str..'右:'..self.LINK_R[GUID]..','
    end
    if self.LINK_U[GUID] then
        str = str..'上:'..self.LINK_U[GUID]..','
    end
    if self.LINK_D[GUID] then
        str = str..'下:'..self.LINK_D[GUID]..',\n'
    end
    if self.MACHINES[GUID] then
        str = str..'连接的用电器:'..self.MACHINES[GUID]..','
    end
    if self.WIREINSYS[GUID] then
        str = str..'所属系统:'..self.WIREINSYS[GUID]..','
    end
    str = str..'\n'
    return str
end

--[[ 显示全局电路信息 ]]
function ElectricSystem:ShowElecInfo()
    local str = '全局电路信息:\n'
    for k, v in pairs(self.SYSINFO) do
        str = str..'电路['..tostring(k)..']:'
        str = str..'\n          导线:'
        for kk, vv in pairs(v.wires) do
            str = str..tostring(vv)..','
        end
        str = str..'\n          用电器:'
        for kk, vv in pairs(v.machines) do
            str = str..tostring(vv)..'('..vv.prefab..'),'
        end
        str = str..'\n'
    end
    return str
end

function ElectricSystem:OnDeployEleAppliance(obj)
    local x, _, z = obj.Transform:GetWorldPosition()
    local elements = TheSim:FindEntities(x, 0, z, 0.5, {'electricwire'})
    if elements[1] then
        local wireGUID = elements[1].GUID
        self.MACHINES[wireGUID] = obj.GUID

        local sysID = self.WIREINSYS[wireGUID]
        table.insert(self.SYSINFO[sysID].machines, obj.GUID)
    end
end

function ElectricSystem:OnRemoveEleAppliance(obj)
    local x, y, z = obj.Transform:GetWorldPosition()
    local wires = TheSim:FindEntities(x,0,z, 0.5, {'electricwire'})
    if wires[1] then
        -- TODO: 我如何确保我一定能找到这个用电器？寻找用电器的算法糟糕透了
        local wireGUID
        for _, wire in pairs(wires) do
            if self.MACHINES[wire.GUID] == obj.GUID then
                self.MACHINES[wire.GUID] = nil
                wireGUID = wire.GUID
                break
            end
        end

        local sysID = self.WIREINSYS[wireGUID]
        table.remove(self.SYSINFO[sysID].machines, table.indexof(self.SYSINFO[sysID].machines, obj.GUID))
        dbg('wire '..wireGUID..'s '..obj.GUID..' removed')
    end
end

_G.ReCalculateSysInfo = function(sysID)

end

return ElectricSystem