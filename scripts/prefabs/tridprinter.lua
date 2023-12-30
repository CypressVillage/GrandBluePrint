local assets =
{
    Asset("ANIM", "anim/researchlab2.zip"),
    Asset("ANIM", "anim/tridprinter.zip"),
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
    local fx = SpawnPrefab("collapse_small")                    -- 摧毁小东西的动画
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition()) -- 把动画放到合适的位置
    fx:SetMaterial("stone")                                     -- 动画的效果是砸石头
    inst:Remove()                                               -- 然后把自己去掉
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("working_pst")
        if inst.components.prototyper.on then
            inst.AnimState:PushAnimation("working_loop", true)
        else
            inst.AnimState:PushAnimation("idle", false)
        end
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
    data.techdata = inst.components.prototyper.trees
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        end
        inst.components.prototyper.trees = data.techdata
    end
end

local function doonact(inst)
    if inst._activecount > 1 then
        inst._activecount = inst._activecount - 1
    else
        inst._activecount = 0
        inst.SoundEmitter:KillSound("sound")
    end
    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_" .. 'lvl2' .. "_ding")
end

local function onbuiltsound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_" .. 'lvl2' .. "_place")
end

local function onturnon(inst)
    if inst._activetask == nil and not inst:HasTag("burnt") then
        if inst.AnimState:IsCurrentAnimation("working_loop")
            or inst.AnimState:IsCurrentAnimation("place") then
            --NOTE: push again even if already playing, in case anidle was also pushed
            inst.AnimState:PushAnimation("working_loop", true)
            -- inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PlayAnimation("working_loop", true)
            -- inst.AnimState:PlayAnimation("proximity_loop", true)
        end
        if not inst.SoundEmitter:PlayingSound("idlesound") then
            inst.SoundEmitter:PlaySound("dontstarve/commonresearchmachine_" .. 'lvl2' .. "_idle_LP", "idlesound")
        end
    end
end

local function onturnoff(inst)
    if inst._activetask == nil and not inst:HasTag("burnt") then
        inst.AnimState:PushAnimation("idle", false)
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
        -- inst.AnimState:PlayAnimation("use")
        inst.AnimState:PlayAnimation("working_loop")
        inst.AnimState:PushAnimation("idle", false)
        if not inst.SoundEmitter:PlayingSound("sound") then
            inst.SoundEmitter:PlaySound("dontstarve/commonresearchmachine_" .. 'lvl2' .. "_run", "sound")
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
    -- inst.AnimState:PlayAnimation("place")
    inst.AnimState:PlayAnimation("working_pre")
    inst.AnimState:PushAnimation("idle", false)
    inst:DoTaskInTime(0, onbuiltsound, 'lvl2')
    -- AwardPlayerAchievement("build_researchlab2", data.builder)
end

-- TODO：如果这一部分完成了，那么tech的部分要相应更改

local function refreshonstate(inst)
    --V2C: if "burnt" tag, prototyper cmp should've been removed *see standardcomponents*
    if not inst:HasTag("burnt") and inst.components.prototyper.on then
        onturnon(inst)
    end
end

local function ongiftopened(inst)
    if not inst:HasTag("burnt") then
        -- inst:_PlayAnimation("gift")
        -- inst:_PushAnimation("upgrade", false)
        inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_" .. 'alchemy' .. "_gift_recieve")
        if inst._activetask ~= nil then
            inst._activetask:Cancel()
        end
        inst._activetask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, doneact)
    end
end

local function getLinkedThings(obj)
    local linkThings = {
        up = nil,
        down = nil,
        left = nil,
        right = nil
    }
    local x, y, z = obj:GetPosition():Get()

    local neighbors = TheSim:FindEntities(x, 0, z, 3, { 'wire' })

    for key, neighbor in pairs(neighbors) do
        -- 旁边的物体坐标
        local nx, ny, nz = neighbor:GetPosition():Get()
        -- 排除自己
        if neighbor.GUID ~= obj.GUID then
            local dx, dz = nx - x, nz - z
            if dx == 1 and dz == 0 then
                linkThings.down = neighbor
            elseif dx == -1 and dz == 0 then
                linkThings.up = neighbor
            elseif dx == 0 and dz == 1 then
                linkThings.right = neighbor
            elseif dx == 0 and dz == -1 then
                linkThings.left = neighbor
            end
        end
    end

    return linkThings
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
    inst.MiniMapEntity:SetIcon('tridprinter.tex')

    inst.AnimState:SetBank('tridprinter')
    inst.AnimState:SetBuild('tridprinter')
    inst.AnimState:SetScale(1.5, 1.5)
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("giftmachine")
    inst:AddTag("prototyper")
    -- inst:AddTag("power")
    inst.getLinkedThings = getLinkedThings(inst)
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
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.TRIDPRINTER
    inst.components.prototyper.onactivate = onactivate

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(8)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    MakeSnowCovered(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    -- 可以用来开礼物
    inst:ListenForEvent("ms_addgiftreceiver", refreshonstate)
    inst:ListenForEvent("ms_removegiftreceiver", refreshonstate)
    inst:ListenForEvent("ms_giftopened", ongiftopened)

    return inst
end

return Prefab('tridprinter', fn, assets, prefabs),
    MakePlacer("tridprinter_placer", "tridprinter", "tridprinter", "idle", nil, nil, nil, 1.5)
