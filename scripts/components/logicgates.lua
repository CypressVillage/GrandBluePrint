local logicGates = Class(function(self, inst)
    self.inst = inst
    self.inst:AddTag("logicgates")

    self.logicfn = nil
end

function logicGates:logicfn(ninput, ...) end