local assets =
{
    Asset("ANIM", "anim/researchlab.zip"),
    Asset("ANIM", "anim/batterysm.zip"),
    Asset("ANIM", "anim/batterymed.zip"),
    Asset("ANIM", "anim/batterylg.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function MakeBattery(data)
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
            inst.AnimState:PlayAnimation("off")
            inst.AnimState:PushAnimation("off", false)
        end
    end

    local function onsave(inst, data)
        if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
            data.burnt = true
        end
    end

    local function onload(inst, data)
        if data ~= nil then
            if data.burnt then
                inst.components.burnable.onburnt(inst)
            end
        end
    end

    local function onbuiltsound(inst)
        inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_" .. 'lvl2' .. "_place")
    end

    local function onbuilt(inst, data)
        inst.AnimState:PlayAnimation("working_pre")
        inst.AnimState:PushAnimation("working_loop", false)
        inst.AnimState:PushAnimation("off", false)
        inst:DoTaskInTime(0, onbuiltsound, 'lvl2')
    end

    ---------------------------------------------------------------------------------
    local function OnFuelEmpty()

    end

    local function OnAddFuel()

    end

    local function onmachinetask(inst)
        inst.components.fueled:DoDelta(1)
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
        inst.MiniMapEntity:SetIcon(data.name .. '.tex')

        inst.AnimState:SetBank(data.name)
        inst.AnimState:SetBuild(data.name)
        inst.AnimState:SetScale(1.5, 1.5)
        inst.AnimState:PlayAnimation("off")

        inst:AddTag("structure")
        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst._activecount = 0 -- 有几个人使用
        inst._activetask = nil

        inst:AddComponent("inspectable")

        inst:ListenForEvent("onbuilt", onbuilt)
        inst:AddComponent("lootdropper")

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(8)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)

        inst:AddComponent("fueled")
        inst.components.fueled:SetDepletedFn(OnFuelEmpty)
        inst.components.fueled:SetTakeFuelFn(OnAddFuel)
        inst.components.fueled:InitializeFuelLevel(30 * 4)
        inst.components.fueled.fueltype = nil

        inst:AddTag("electricbattery")
        inst:AddComponent("electricmachine")
        inst.components.electricmachine:SetOnMachineTaskFn(onmachinetask)
        inst.components.electricmachine:SetOnRefreshStateFn(function(inst)
            local sysID = TheWorld.components.electricsystem:getSysIDbyMachine(inst)
            if not sysID then return end
            local sysinfo = TheWorld.components.electricsystem:getSysInfo(sysID)

            if sysinfo.haspower then
                inst.components.fueled.rate = -1
            else
                inst.components.fueled.rate = 1
            end

            if sysinfo.haspower then
                inst.components.fueled:StartConsuming()
            else
                inst.components.fueled:StopConsuming()
            end
            -- dbg(inst.components.fueled:GetDebugString())
        end)

        -- MakeSnowCovered(inst)

        inst.OnSave = onsave
        inst.OnLoad = onload

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        return inst
    end

    return unpack {
        Prefab(data.name, fn, assets, prefabs),
        MakePlacer(data.name .. "_placer", data.name, data.name, "off", nil, nil, nil, 1.5)
    }
end

local batteryprefabs = {}

local batterydata =
{
    { name = "batterysm",  cost = 1, fuel = 1, scale = 1.5 },
    { name = "batterymed", cost = 2, fuel = 2, scale = 2 },
    { name = "batterylg",  cost = 3, fuel = 3, scale = 2.5 },
}

for i, v in ipairs(batterydata) do
    local prefab, placer = MakeBattery(v)
    table.insert(batteryprefabs, prefab)
    table.insert(batteryprefabs, placer)
end

return unpack(batteryprefabs)
