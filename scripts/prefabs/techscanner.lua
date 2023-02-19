local assets =
{
    Asset("ANIM", "anim/wagstaff_tools.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wagstaff_tools_all")
    inst.AnimState:SetBuild("wagstaff_tools")
    inst.AnimState:PlayAnimation("multitool")
    inst.AnimState:SetErosionParams(0, -0.136, -1.0)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.techinfo = nil

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = 'images/inventoryimages2.xml'
    inst.components.inventoryitem.imagename = 'wagstaff_tool_4'

    inst:AddComponent('techscan')

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("techscanner", fn, assets)
