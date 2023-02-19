local assets =
{
    Asset("ANIM", "anim/researchlab.zip"),
    Asset("ANIM", "anim/computer.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function onhammered(inst, worker)
    -- 如果物体可以燃烧而且正在燃烧，那么把它扑灭
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small") -- 摧毁小东西的动画
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition()) -- 把动画放到合适的位置
    fx:SetMaterial("stone") -- 动画的效果是砸石头
    inst:Remove() -- 然后把自己去掉
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("off")
        if inst.components.prototyper.on then
            inst.AnimState:PushAnimation("working_loop", true)
        else
            inst.AnimState:PushAnimation("off", false)
        end
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
    -- data.techdata = inst.components.prototyper.trees
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        end
        -- inst.components.prototyper.trees = data.techdata
    end
end

local function doonact(inst)
    if inst._activecount > 1 then
        inst._activecount = inst._activecount - 1
    else
        inst._activecount = 0
        inst.SoundEmitter:KillSound("sound")
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..'lvl2'.."_ding")
end

local function onbuiltsound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..'lvl2'.."_place")
end

local function onturnon(inst)
    if inst._activetask == nil and not inst:HasTag("burnt") then
    if inst.AnimState:IsCurrentAnimation("working_loop")
            or inst.AnimState:IsCurrentAnimation("working_pre") then
            --NOTE: push again even if already playing, in case anidle was also pushed
            inst.AnimState:PushAnimation("working_loop", true)
        else
            inst.AnimState:PlayAnimation("working_pre", false)
            inst.AnimState:PushAnimation("working_loop", true)
        end
        if not inst.SoundEmitter:PlayingSound("idlesound") then
            inst.SoundEmitter:PlaySound("dontstarve/commonresearchmachine_"..'lvl2'.."_idle_LP", "idlesound")
        end
    end
end

local function onturnoff(inst)
    if inst._activetask == nil and not inst:HasTag("burnt") then
        inst.AnimState:PushAnimation("working_pst", false)
        inst.AnimState:PushAnimation("off", false)
        inst.SoundEmitter:KillSound("idlesound")
    end
end

local function doneact(inst)
    inst._activetask = nil
    if not inst:HasTag("burnt") then
        if inst.components.prototyper.on then
            onturnon(inst)
        else
            onturnoff(inst)
        end
    end
end

local function onactivate(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("working_pre")
        inst.AnimState:PushAnimation("working_loop", false)
        if not inst.SoundEmitter:PlayingSound("sound") then
            inst.SoundEmitter:PlaySound("dontstarve/commonresearchmachine_"..'lvl2'.."_run", "sound")
        end
        inst._activecount = inst._activecount + 1
        inst:DoTaskInTime(1.5, doonact)
        if inst._activetask ~= nil then
            inst._activetask:Cancel()
        end
        inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, doneact)
    end
end

local function onbuilt(inst, data)
    inst.AnimState:PlayAnimation("working_pre")
    inst.AnimState:PushAnimation("working_loop", false)
    inst:DoTaskInTime(0, onbuiltsound, 'lvl2')
end

local function ShouldAcceptItem(inst, item)
    if item.prefab == "techcarrier" then
        return true
    end
    return false
end

-- TODO：计算机自己不应该升级科技，而是将科技存起来
local function OnGetItemFromPlayer(inst, giver, item)
    --inst.components.inventory:GiveItem(item)
    for name, val in pairs(item.techinfo) do
        if inst.components.prototyper.trees[name] < val then
            inst.components.prototyper.trees[name] = val
        end
    end
end

local function OnRefuseItem(inst, giver, item)
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon('computer.tex')

    inst.AnimState:SetBank('computer')
    inst.AnimState:SetBuild('computer')
    inst.AnimState:SetScale(1.5, 1.5)
    inst.AnimState:PlayAnimation("off")

    inst:AddTag("structure")
    inst:AddTag("giftmachine")
    inst:AddTag("prototyper")
    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._activecount = 0 -- 有几个人使用
    inst._activetask = nil

    inst:AddComponent("inspectable")

    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.COMPUTER
    inst.components.prototyper.onactivate = onactivate

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(8)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent('trader')
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    -- inst.components.trader.deleteitemonaccept = false

    MakeSnowCovered(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    
    return inst
end

return Prefab('computer', fn, assets, prefabs), MakePlacer("computer_placer", "computer", "computer", "off", nil, nil, nil, 1.5)
