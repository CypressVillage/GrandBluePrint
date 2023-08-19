--[[
    相当于machine和circuitnode的结合体
    包含了machine component，为其增加限制
    同时尝试处理导线链接
]]

local ElectricMachine = Class(function(self, inst)
    self.inst = inst
    self.inst:AddTag("electricmachine")

    self.inst:AddComponent("machine")
    self.machine = self.inst.components.machine
    self.machine.cooldowntime = 0
    self.machine.turnonfn = function()
        self.machine.ison = true
        self:NotifySystemChanged()
    end
    self.machine.turnofffn = function()
        self.machine.ison = false
        self:NotifySystemChanged()
    end

    self.consumption = 0
    self.PERIOD = 0.5
    self._machinetask = nil
    self.OnMachineTask = function(inst) end
end,
nil,
{})

-- function ElectricMachine:OnSave()
--     return {
--         -- ison = self.ison
--     }
-- end

-- function ElectricMachine:OnLoad(data)

-- end

function ElectricMachine:IsOn()
    return self.machine:IsOn()
end

function ElectricMachine:OnBuilt()
    TheWorld.components.electricsystem:OnDeployEleAppliance(self.inst)
end

-- 接口，在Entity层实现
function ElectricMachine:SetOnMachineTask(fn)
    self.OnMachineTask = fn
end

function ElectricMachine:StartMachineTask()
    if self._machinetask == nil then
        self._machinetask = self.inst:DoPeriodicTask(self.PERIOD, self.OnMachineTask, 0)
    end
end

function ElectricMachine:StopMachineTask()
    if self._machinetask ~= nil then
        self._machinetask:Cancel()
        self._machinetask = nil
    end
end

function ElectricMachine:NotifySystemChanged()
    local sysID = TheWorld.components.electricsystem:getSysIDbyMachine(self.inst)
    if sysID ~= nil then
        TheWorld.components.electricsystem:ReCalculateSysInfo(sysID)
    end
end

return ElectricMachine