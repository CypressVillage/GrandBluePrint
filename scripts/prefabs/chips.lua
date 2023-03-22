local assets =
{
    Asset("ANIM", "anim/staff_purple_base_ground.zip"),
}

local prefabs =
{
    "gemsocket",
    "collapse_small",
}



local function MakeChip(data)
    local function makePin(x, z)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("pin")
        inst.AnimState:SetBuild('pin')
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetFinalOffset(1)

        inst:AddTag("DECOR")
        inst:AddTag("NOBLOCK")

        return inst
    end

    local function createPins(x, z, rot)

    end

    local function ondeploychip(inst, pt, deployer, rot)
        local chip = SpawnPrefab(data.name)
        if chip ~= nil then
            local x = math.floor(pt.x) + .5
            local z = math.floor(pt.z) + .5
            chip.Transform:SetPosition(x,0,z)
            chip.Transform:SetRotation(rot)
            chip.components.savedrotation:SetFixed(true)

            local pins = createPins(x, z, rot)
        end
        
    end

    local function onhammered(inst)
        inst:Remove()
    end

    local function commonfn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()
        -- inst.entity:AddMiniMapEntity()

        -- inst.MiniMapEntity:SetIcon("")

        inst.AnimState:SetBank(data.package)
        inst.AnimState:SetBuild(data.package)
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)

        inst:AddTag("chip")
        inst:AddTag("NOBLOCK")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        -- inst.components.inspectable.
        inst:AddComponent("lootdropper")

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnFinishCallback(onhammered)

        inst:AddComponent("savedrotation")

        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
    end

    local function itemfn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(data.package)
        inst.AnimState:SetBuild(data.package)
        inst.AnimState:PlayAnimation("")
        inst.AnimState:SetScale(1.5, 1.5)

        inst:AddTag("eyeturret")

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryimages/"..data.package..".xml"
        inst.inventoryitem.imagename = data.package

        inst:AddComponent("deployable")
        inst.components.deployable.ondeploy = ondeploychip

        return inst
    end

    return unpack{
        Prefab(data.name, commonfn, assets, prefabs),
        Prefab(data.name..'_item', itemfn, assets, prefabs),
        MakePlacer(data.name..'_placer', data.package, data.package, "idle"),
    }
end

_G.CHIPINFO = {
    {
        name = 'convertor',
        package = '8x2',
        pins = {
            {num = 0, type = "in", posx = -1, posz = -1, name = 'P1', desc = "输入"},
            {num = 1, type = "out", posx = 1, posz = -1, name = 'P2', desc = "输出"},
        },
        fn = function(...) return ... end,
    },
}

local chipPrefabs = {}
for k, v in pairs(_G.CHIPINFO) do
    local p, pl = MakeChip(v)
    table.insert(chipPrefabs, p)
    table.insert(chipPrefabs, pl)
end

return unpack(chipPrefabs)