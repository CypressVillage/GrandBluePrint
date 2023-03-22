local _G = GLOBAL
--[[
    添加此组件让机器可以连接到电路里
--]]

local function check(self, inst)
    local wire = _G.getfirstWire(inst.GUID)
    local sysID = _G.wireInSys(wire)
    local powers = _G.getsysThings(sysID)
    if powers then
        return true
    end
    return false
end

local elecmachine = Class(function(self, inst)
	self.inst = inst
    self.checkfn = nil
end,
nil,
{
    checkfn = check,
})

function elecmachine:check(inst)
    return self.checkfn(self, inst)
end

return elecmachine
