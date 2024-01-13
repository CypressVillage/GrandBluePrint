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
    --     [sysID] = {
    --         wires = {GUID, GUID, ...},
    --         machines = {GUID, GUID, ...},
    --         consumption = 0,
    --         state = fine | undervoltage | overvoltage,
    --         hasbattery = false,
    --         haspower = false,
    --         batteries = {},
    --         powers = {},
    --     },
    --     ...
    -- }
end)

-- 获取导线连接内容
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

-- 获取用电器连接的第一根导线，返回nil表示用电器没有和导线链接
function ElectricSystem:getfirstWire(GUID)
    return table.indexof(self.MACHINES, GUID)
end

-- 获取导线所在系统
function ElectricSystem:getSysID(wireGUID)
    return self.WIREINSYS[wireGUID]
end

-- 获取机器所在系统的ID
function ElectricSystem:getSysIDbyMachine(inst)
    local wireGUID = self:getfirstWire(inst.GUID)
    if wireGUID ~= nil then
        return self:getSysID(wireGUID)
    end
    return nil
end

-- 获取系统信息
function ElectricSystem:getSysInfo(sysID)
    return self.SYSINFO[sysID]
end

--[[ 注册一个新导线，返回ID。这个函数同时更新了新导线的连接状态，但是没有更新系统中的状态

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
        powers = {},
        batteries = {},
        consumption = 0,
        state = 'fine',
        hasbattery = false,
        haspower = false,
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

    self:OnElectricSysChanged(newSysID)
    -- dbg('wire '..wire.GUID..' deployed')
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
    -- dbg(obj.name..'deploying!')
    local x, _, z = obj.Transform:GetWorldPosition()
    local elements = TheSim:FindEntities(x, 0, z, 0.5, {'electricwire'})
    local sysID
    if elements[1] then
        for _, wire in pairs(elements) do
            -- dbg('find a wire around')
            local wireGUID = wire.GUID
            self.MACHINES[wireGUID] = obj.GUID
            sysID = self.WIREINSYS[wireGUID]
            table.insert(self.SYSINFO[sysID].machines, obj.GUID)
        end

        self.SYSINFO[sysID].machines = table.unique(self.SYSINFO[sysID].machines)
        self:OnElectricSysChanged(sysID)
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
            end
        end

        local sysID = self.WIREINSYS[wireGUID]
        if sysID ~= nil then
            local index = table.indexof(self.SYSINFO[sysID].machines, obj.GUID)
            if index ~= nil then -- 奇奇怪怪
                table.remove(self.SYSINFO[sysID].machines, index)
            end
        end

        self:OnElectricSysChanged(sysID)
    end
end

function ElectricSystem:ReCalculateSysInfo(sysID, machine)
    local system = self.SYSINFO[sysID]
    if table.size(system.machines) == 0 then return end

    local powers = {}
    local batteries = {}
    local consumption = 0
    -- 计算consumption，更新batteries和powers列表
    -- TODO: 全更新一遍性能可能不太好，最好改掉
    for _, machineID in pairs(system.machines) do
        local machine = Ents[machineID].components.electricmachine
        if machine:IsOn() and machine:IsValid() then
            if machine.inst:HasTag('electricbattery') then
                table.insert(batteries, machine.inst.GUID)
            elseif machine.inst:HasTag('electricpower') then
                table.insert(powers, machine.inst.GUID)
            end
            consumption = consumption + machine.consumption
        end
    end
    system.powers = powers
    system.batteries = batteries
    system.haspower = #powers ~= 0
    system.hasbattery = #batteries ~= 0
    system.consumption = consumption

    if consumption >= 0 then
        system.state = 'fine'
    elseif consumption < 0 then
        system.state = 'undervoltage'
    end

    -- dbg('consumption now:')
    -- dbg(consumption)
    -- TODO: 重构使得电路一改变，所有的电器就更新状态
end

function ElectricSystem:getSystemState(sysID)
    return self.SYSINFO[sysID].state
end

--[[
    首先调用ReCalculateSysInfo，收集系统中所有电器的信息，得到系统的状态
    ，再对所有电器进行状态更新
]]
function ElectricSystem:OnElectricSysChanged(sysID, machine)
    self:ReCalculateSysInfo(sysID, machine)
    local state = self:getSystemState(sysID)
    for _, machineID in pairs(self.SYSINFO[sysID].machines) do
        Ents[machineID].components.electricmachine:RefreshState(state)
    end
end

return ElectricSystem