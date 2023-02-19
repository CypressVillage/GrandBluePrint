local _G = GLOBAL
--[[
    游戏杂项修改
]]--


-- 可靠的胶布可以修补烂电线
AddPrefabPostInit('sewing_tape', function(inst)
    inst:AddComponent('repair_broken_wire')
end)

-- 修改放置导线的语句
