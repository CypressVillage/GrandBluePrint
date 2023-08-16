local _G = GLOBAL
--[[
    扫描科技
]]
local SCAN_TECH = Action({ priority = 2 })
SCAN_TECH.id = 'SCAN_TECH'
SCAN_TECH.str = STRINGS.ACTIONS_GBP.SCAN_TECH
SCAN_TECH.fn = function(act)
    -- act.target.components.techscan:ScanTech(act)
    local scanner = act.doer.components.inventory:RemoveItem(act.invobject)
    local techInfo = act.target.components.prototyper.trees
    local tecpaper = SpawnPrefab('techcarrier')
    tecpaper.techinfo = techInfo
    tecpaper.components.inspectable:SetDescription(STRINGS.CHARACTERS.GENERIC.DESCRIBE.TECHCARRIER(techInfo))
    act.doer.components.inventory:GiveItem(tecpaper)
    return true
end
AddAction(SCAN_TECH)
-- 动作选择器
AddComponentAction('USEITEM', 'techscan', function (inst, doer, target, actions, right)
    if target:HasTag('prototyper') then
        table.insert(actions, ACTIONS.SCAN_TECH)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.SCAN_TECH, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.SCAN_TECH, "dolongaction"))


--[[
    修补旧电线
]]
local REPAIR_BROKEN_WIRE = Action({ priority = 2 })
REPAIR_BROKEN_WIRE.id = 'REPAIR_BROKEN_WIRE'
REPAIR_BROKEN_WIRE.str = STRINGS.ACTIONS_GBP.REPAIR_BROKEN_WIRE
REPAIR_BROKEN_WIRE.fn = function(act)
    -- local slot = act.doer.components.inventory:GetItemSlot(act.target)
    act.doer.components.inventory:tryconsume(act.target, 1)
    act.doer.components.inventory:tryconsume(act.invobject, 1)

    -- act.doer.components.inventory:ConsumeByName(act.invobject.prefab, 1)
    -- act.doer.components.inventory:ConsumeByName(act.target.prefab, 1)


    local wire = SpawnPrefab('electricwire_item')
    act.doer.components.inventory:GiveItem(wire)

    return true
end
AddAction(REPAIR_BROKEN_WIRE)
AddComponentAction('USEITEM', 'repair_broken_wire', function (inst, doer, target, actions, right)
    if right and target.prefab == 'trinket_6' then
        table.insert(actions, ACTIONS.REPAIR_BROKEN_WIRE)
    end
end)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.REPAIR_BROKEN_WIRE, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.REPAIR_BROKEN_WIRE, "dolongaction"))

-- --[[
--     电器action
-- ]]
-- local CONSUMERSON = Action({ priority = 2 })
-- CONSUMERSON.id = 'CONSUMERSON'
-- CONSUMERSON.str = STRINGS.ACTIONS_GBP.CONSUMERSON
-- CONSUMERSON.fn = function(act)
--     act.doer.components.inventory:ConsumeByName(act.invobject.prefab, 1)
--     act.doer.components.inventory:ConsumeByName(act.target.prefab, 1)
    

--     local wire = SpawnPrefab('electricwire_item')
--     act.doer.components.inventory:GiveItem(wire)

--     return true
-- end
-- AddAction(CONSUMERSON)
-- AddComponentAction('SCENE', 'repair_broken_wire', function (inst, doer, target, actions, right)
--     if right and target.prefab == 'trinket_6' then
--         table.insert(actions, ACTIONS.CONSUMERSON)
--     end
-- end)
-- AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.CONSUMERSON, "dolongaction"))
-- AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.CONSUMERSON, "dolongaction"))
