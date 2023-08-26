GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local _G = GLOBAL
--[[
    游戏杂项修改
]]

-- AddPrefabPostInit('researchlab1', function(inst)
--     inst:AddTag('power')
-- end)

-- 为机器开关添加连接进电路的限制
-- AddComponentPostInit('machine', function(self)
--     local oldturnonfn = self.turnofffn
--     self.turnonfn = function(inst)
--         -- 检查只对拥有elecmachine组件的对象生效
--         local elecm = inst.components.elecmachine
--         if not elecm then
--             return oldturnonfn(inst)
--         else
--             if elecm:check() then
--                 return oldturnonfn(inst)
--             end
--         end
--     end

-- end)

-- 可靠的胶布可以修补烂电线
AddPrefabPostInit('sewing_tape', function(inst)
    inst:AddComponent('repair_broken_wire')
end)

AddPrefabPostInit('forest', function(inst)
    -- TODO:尝试判断主机
    if TheWorld.ismastersim then
        inst:AddComponent('electricsystem')
    end
end)

-- winona的聚光灯可以开启或关闭
-- TODO: 关闭的时候更改贴图动画
AddPrefabPostInit('winona_spotlight', function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent('electricmachine')
    inst.components.electricmachine.consumption = -1
    inst.components.electricmachine:SetOnMachineTask(function()
        inst:AddBatteryPower(0.5)
    end)
    inst.components.electricmachine:SetTurnOnFn(function(inst)
        inst.components.circuitnode:ConnectTo("engineeringbattery")
    end)
    inst.components.electricmachine:SetTurnOffFn(function(inst)
        inst.components.circuitnode:Disconnect()
    end)

    inst.components.machine:TurnOn()
end)

AddPrefabPostInit('winona_battery_low', function(inst)
    inst:AddTag('electricpower')
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent('electricmachine')
    inst.components.electricmachine.consumption = 2
    inst.components.electricmachine:SetOnMachineTask(function() end)
    inst.components.electricmachine:SetTurnOnFn(function(inst)
        inst.components.fueled:StartConsuming()
        inst.components.circuitnode:ConnectTo("engineering")
        inst.AnimState:PlayAnimation("idle_charge", true)
    end)
    inst.components.electricmachine:SetTurnOffFn(function(inst)
        inst.components.circuitnode:Disconnect()
        inst.components.fueled:StopConsuming()
        inst.AnimState:PlayAnimation("idle_empty", true)
        -- TODO: 这里并不能成功显示电池的数据
        local section  = inst.components.fueled:GetCurrentSection()
        inst.AnimState:OverrideSymbol("m2", "winona_battery_low", "m"..tostring(math.clamp(section + 1, 1, 7)))
        inst.AnimState:ClearOverrideSymbol("plug")
        dbg(section)
    end)

    inst.components.machine:TurnOn()
end)

AddPrefabPostInit('winona_battery_high', function(inst)
    inst:AddTag('electricpower')
    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddComponent('electricmachine')
    inst.components.electricmachine.consumption = 2
    inst.components.electricmachine:SetOnMachineTask(function() end)
    inst.components.electricmachine:SetTurnOnFn(function(inst)
        inst.components.fueled:StartConsuming()
        inst.components.circuitnode:ConnectTo("engineering")
        inst.AnimState:PlayAnimation("idle_charge", true)
    end)
    inst.components.electricmachine:SetTurnOffFn(function(inst)
        inst.components.circuitnode:Disconnect()
        inst.components.fueled:StopConsuming()
        inst.AnimState:PlayAnimation("idle_empty", true)
        local section  = inst.components.fueled:GetCurrentSection()
        inst.AnimState:OverrideSymbol("m2", "winona_battery_high", "m"..tostring(math.clamp(section + 1, 1, 7)))
        inst.AnimState:ClearOverrideSymbol("plug")
    end)

    inst.components.machine:TurnOn()
end)

-- AddPrefabPostInit('firesuppressor', )

-- 清洁扫把对自己施法改变自己的皮肤
AddPrefabPostInit('reskin_tool', function(inst)
    -- 清洁扫把可以在物品栏里换肤
    inst:AddTag('castfrominventory')

    -- 如果没有目标，那么目标设置为自己（手上的清洁扫把）
    local oldspell = inst.components.spellcaster.spell
    inst.components.spellcaster:SetSpellFn(function(tool, target, pos, caster)
        local newtarget = target or inst
        return oldspell(tool, newtarget, pos, caster)
    end)

    local oldonspellcast = inst.components.spellcaster.onspellcast
    inst.components.spellcaster:SetOnSpellCastFn(function(tool, target, pos, caster)
        if target == nil then
            tool:DoTaskInTime(0.1, function()
                local skin_build = inst:GetSkinBuild()
                if skin_build then
                    caster:PushEvent('equipskinneditem', tool:GetSkinName())
                    caster.AnimState:OverrideItemSkinSymbol('swap_object', skin_build, 'swap_reskin_tool', tool.GUID, 'swap_reskin_tool')
                else
                    caster.AnimState:OverrideSymbol('swap_object', 'swap_reskin_tool', 'swap_reskin_tool')
                end
            end)
        end

        if oldonspellcast then
            local oldonspellcastrtn = oldonspellcast(tool, target, pos, caster)
            if oldonspellcastrtn then
                return oldonspellcastrtn
            end
        end
    end)
end)

-- 导线不能重叠放置
-- AddComponent

-- Glassic API工具
if not CONFIGS_GBP.GLASSICAPITOOLS then
    
end