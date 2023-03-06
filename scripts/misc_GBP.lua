GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local _G = GLOBAL
--[[
    游戏杂项修改
]]--


-- 可靠的胶布可以修补烂电线
AddPrefabPostInit('sewing_tape', function(inst)
    inst:AddComponent('repair_broken_wire')
end)

-- winona的聚光灯可以开启或关闭
AddPrefabPostInit('winona_spotlight', function(inst)
    inst:AddTag('consumer')

    inst:AddComponent('machine')

    inst.components.machine.turnonfn = function(inst)
        if inst._lightdist:value() > 0 then
            EnableHum(inst, true)
        end
        EnableLight(inst, true)
    end
    inst.components.machine.turnofffn = function(inst)
        EnableHum(inst, false)
        EnableLight(inst, false)
    end
    -- inst.components.maching.turnonfn = function (inst)
    --     if not inst._wired then
    --         inst._wired = true
    --         inst.AnimState:ClearOverrideSymbol("wire")
    --         if not POPULATING then
    --             DoWireSparks(inst)
    --         end
    --     end
    --     OnCircuitChanged(inst)
    -- end
    inst.components.machine.cooldowntime = 0
end)

-- winona的发电机可以开启或关闭
AddPrefabPostInit('winona_battery_low', function(inst)
    inst:AddTag('consumer')

    inst:AddComponent('machine')

    inst.components.machine.turnonfn = function(inst)
        if not inst.components.fueled.consuming then
            inst.components.fueled:StartConsuming()
            -- BroadcastCircuitChanged(inst)
            -- StartBattery(inst)
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/together/battery/up")
        if not inst:IsAsleep() then
        --    StartIdleChargeSounds(inst)
        --    StartSoundLoop(inst)
        end
    end
    inst.components.machine.turnofffn = function(inst)
        EnableHum(inst, false)
        EnableLight(inst, false)
    end
    inst.components.machine.cooldowntime = 0
end)

-- 清洁扫把对自己施法改变自己的皮肤
AddPrefabPostInit('reskin_tool', function(inst)
    inst:AddTag('castfrominventory')
    
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