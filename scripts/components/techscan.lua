local TechTree = require('techtree')

local techScan = Class(function(self, inst)
	self.inst = inst
	self.data = TechTree.Create()
end)

function techScan:ScanTech(act)
	-- TODO:把action里的东西写到这里
	local scanner = act.doer.components.inventory:RemoveItem(act.invobject)
    local techInfo = act.target.components.prototyper.trees
    local tecpaper = SpawnPrefab('techcarrier')
    tecpaper.techinfo = techInfo
    tecpaper.components.inspectable:SetDescription(STRINGS.CHARACTERS.GENERIC.DESCRIBE.TECHCARRIER(techInfo))
    act.doer.components.inventory:GiveItem(tecpaper)
end

return techScan