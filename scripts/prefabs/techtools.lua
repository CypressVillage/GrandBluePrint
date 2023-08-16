local assets =
{
    Asset("ANIM", "anim/wagstaff_tools.zip"),
    Asset("ANIM", "anim/blueprint_rare.zip"),
}

local function tecscannerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wagstaff_tools_all")
    inst.AnimState:SetBuild("wagstaff_tools")
    inst.AnimState:PlayAnimation("multitool")
    -- inst.AnimState:SetErosionParams(0, -0.136, -1.0) -- 侵蚀参数

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.techinfo = nil

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = 'images/inventoryimages3.xml'
    inst.components.inventoryitem.imagename = 'wagstaff_tool_4'

    inst:AddComponent('techscan')

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

----------------------------------------------------------------------------------------------------------------------------
local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
    data.techdata = inst.techinfo
    data.inspect = STRINGS.CHARACTERS.GENERIC.DESCRIBE.TECHCARRIER(inst.techinfo)
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        end
        inst.techinfo = data.techdata
        inst.components.inspectable:SetDescription(data.inspect)
    end
end

local function techcarrierfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("blueprint_rare")
    inst.AnimState:SetBuild("blueprint_rare")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.techinfo = require('techtree').Create()

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = 'images/inventoryimages.xml'
    inst.components.inventoryitem.imagename = 'blueprint_rare'

    inst:AddComponent("inspectable")
    inst.components.inspectable:SetDescription(STRINGS.CHARACTERS.GENERIC.DESCRIBE.TECHCARRIER(inst.techinfo))

    inst:AddComponent("tradable")

    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("techscanner", tecscannerfn, assets), Prefab("techcarrier", techcarrierfn, assets)
