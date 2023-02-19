local assets =
{
    Asset("ANIM", "anim/blueprint_rare.zip"),
}

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

local function fn()
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

return Prefab("techcarrier", fn, assets)
