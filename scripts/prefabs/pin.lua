local assets =
{
    Asset("ANIM", "anim/pin.zip"),
}

local prefabs =
{
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .4)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon('pin.tex')

    inst.AnimState:SetBank('pin')
    inst.AnimState:SetBuild('pin')
    inst.AnimState:SetScale(1.5, 1.5)
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("giftmachine")
    inst:AddTag("prototyper")
    inst:AddTag("power")
    inst.getLinkedThings = getLinkedThings(inst)
    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    return inst  
end

return Prefab('pin', fn, assets, prefabs), MakePlacer("pin_placer", "pin", "pin", "idle", nil, nil, nil, nil)
