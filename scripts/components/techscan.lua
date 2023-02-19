local TechTree = require('techtree')

local techScan = Class(function(self, inst)
	self.inst = inst
	self.data = TechTree.Create()
end)

function techScan:GiveTech()
	-- TODO:把action里的东西写到这里
end

return techScan