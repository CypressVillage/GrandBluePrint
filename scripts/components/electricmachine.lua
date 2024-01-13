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
        if self.turnonfn then
            self.turnonfn(self.inst)
        end
        self.machine.ison = true
        self:NotifySystemChanged()
    end
    self.machine.turnofffn = function()
        if self.turnofffn then
            self.turnofffn(self.inst)
        end
        self.machine.ison = false
        self:NotifySystemChanged()
    end

    self.turnonfn = nil
    self.turnofffn = nil
    self.isvalidfn = nil

    self.consumption = 0
    self.PERIOD = 0.5
    self._machinetask = nil
    self.OnMachineTask = nil
    self.OnRefreshState = nil
end)

function ElectricMachine:IsValid()
    if self.isvalidfn then
        return self.isvalidfn()
    else
        return true
    end
end

function ElectricMachine:IsOn()
    return self.machine:IsOn()
end

function ElectricMachine:OnBuilt()
    TheWorld.components.electricsystem:OnDeployEleAppliance(self.inst)
end

function ElectricMachine:OnSave()
    return { ison = self:IsOn() }
end

function ElectricMachine:OnLoad(data)
    TheWorld.components.electricsystem:OnDeployEleAppliance(self.inst)
    if data.ison then
        self.machine:TurnOn()
    else
        self.machine:TurnOff()
    end
end

function ElectricMachine:OnRemoveEntity()
    TheWorld.components.electricsystem:OnRemoveEleAppliance(self.inst)
end

-- 接口，在Entity层实现
function ElectricMachine:SetOnMachineTaskFn(fn)
    self.OnMachineTask = fn
end

function ElectricMachine:SetOnRefreshStateFn(fn)
    self.OnRefreshState = fn
end

function ElectricMachine:SetTurnOnFn(fn)
    self.turnonfn = fn
end

function ElectricMachine:SetTurnOffFn(fn)
    self.turnofffn = fn
end

function ElectricMachine:SetIsValidFn(fn)
    self.isvalidfn = fn
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

-- 我通知system
function ElectricMachine:NotifySystemChanged()
    local sysID = TheWorld.components.electricsystem:getSysIDbyMachine(self.inst)
    if sysID ~= nil then
        TheWorld.components.electricsystem:OnElectricSysChanged(sysID, self)
    end
end

-- system通知我
function ElectricMachine:RefreshState(systemstate)
    if self.OnRefreshState then
        self.OnRefreshState(self.inst)
    end
    if systemstate == 'fine' and self:IsOn() and self:IsValid() then
        self:StartMachineTask()
    else
        self:StopMachineTask()
    end
end

return ElectricMachine