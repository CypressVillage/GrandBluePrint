--[[
    建造类似石墙
    贴图机制类似白木地垫
    有component，叫electrocircuit
    也许需要强加载？
    md，好像为了能正常显示我得做8个面，而电线这个东西有9种连接状态，听起来就很刺激
    longfei教程里有贴靠地面的函数，电线素材就不用进一步加工了👍
]]--

local function MakeWire(data)
    local assets =
    {
        Asset("ANIM", "anim/"..data.name..".zip"),
    }

    local prefabs =
    {
        "collapse_small",
    }

    local function onhammered(inst, worker)

        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial('metal')

        inst.components.lootdropper:SpawnLootPrefab('trinket_6')

        -- RemoveObjFromSys(inst)
        if data.type == 'electric' then
            _G.wireRemoved(inst)
        elseif data.type == 'logic' then
            _G.LogicWireRemoved(inst)
        end
        if inst then inst:Remove() end
    end

    local function refreshState(obj, isexpand)
        local linkThings
        if data.type == 'electric' then
            linkThings = _G.getLinkedThings(obj.GUID)
        elseif data.type == 'logic' then
            linkThings = _G.getLogicLinkedThings(obj.GUID)
        end
        local Animstr = ''
        if linkThings.left then Animstr = Animstr..'L' end
        if linkThings.right then Animstr = Animstr..'R' end
        if linkThings.up then Animstr = Animstr..'U' end
        if linkThings.down then Animstr = Animstr..'D' end

        if Animstr ~= '' then
            obj.AnimState:PlayAnimation(Animstr)
        else
            obj.AnimState:PlayAnimation('None')
        end

        if isexpand then
            for i, v in pairs(linkThings) do
                if i ~= 'other' then 
                    refreshState(Ents[v], false)
                end
            end
        end
    end

    -- local function refreshState(obj, isexpand)
    --     local linkThings = getLinkedThings(obj).wires
    --     local Animstr = ''
    --     if linkThings.left and linkThings.left:HasTag('wire') then   Animstr = Animstr..'L' end
    --     if linkThings.right and linkThings.right:HasTag('wire') then     Animstr = Animstr..'R' end
    --     if linkThings.up and linkThings.up:HasTag('wire') then Animstr =     Animstr..'U' end
    --     if linkThings.down and linkThings.down:HasTag('wire') then   Animstr = Animstr..'D' end

    --     if Animstr ~= '' then
    --         obj.AnimState:PlayAnimation(Animstr)
    --     else
    --         obj.AnimState:PlayAnimation('None')
    --     end

    --     if isexpand then
    --         for _, v in pairs(linkThings) do
    --             if v:HasTag('wire') then
    --                 refreshState(v, false)
    --             end
    --         end
    --     end
    -- end

    local function ondeploywire(inst, pt, deployer, rot )
        local wire = SpawnPrefab(data.name)
        if wire ~= nil then
            local x = math.floor(pt.x) + .5
            local z = math.floor(pt.z) + .5
            wire.Transform:SetPosition(x,0,z)

            inst.components.stackable:Get():Remove()

            -- wire.SoundEmitter:PlaySound("dontstarve/common/  place_structure_wood")

            if data.type == 'electric' then
                _G.WireDeployed(wire)
            elseif data.type == 'logic' then
                _G.LogicWireDeployed(wire)
            end
            refreshState(wire, true)
            -- refreshState(wire, true)
            -- RefreshElectricSys(wire)
            -- listElectricSysInfo()
        end
    end

    local function onsave(inst, data)
    end

    local function onload(inst, data)
        _G.WireDeployed(inst)
        refreshState(inst, true)
        -- refreshState(inst, true)
        -- RefreshElectricSys(inst)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank(data.name)
        inst.AnimState:SetBuild(data.name)
        inst.AnimState:SetScale(1.5, 1.5)
        inst.AnimState:PlayAnimation("None")
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(3)

        MakeInventoryFloatable(inst, "med", 0.3, 0.8)
        local OnLandedClient_old = inst.components.floater.OnLandedClient
        inst.components.floater.OnLandedClient = function(self)
            OnLandedClient_old(self)
            inst.AnimState:SetFloatParams(0.1, 1, self.bob_percent)
        end

        inst:AddTag("NOBLOCK")
        inst:AddTag('wire')
        inst:AddTag(data.type..'wire')

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end


        inst:AddComponent("inspectable")
        inst:AddComponent("lootdropper")

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnFinishCallback(onhammered)

        -- inst:AddComponent('wire')

        inst.OnSave = onsave
        inst.OnLoad = onload

        -- MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        -- MakeSmallPropagator(inst)
        MakeHauntableLaunchAndIgnite(inst)


        return inst
    end

    local function itemfn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(data.name)
        inst.AnimState:SetBuild(data.name)
        inst.AnimState:PlayAnimation("ui")
        inst.AnimState:SetScale(1.5, 1.5)

        -- MakeInventoryFloatable(inst)

        inst:AddTag("eyeturret") --眼球塔的专属标签，但为了deployable组件的摆放 名字而使用（显示为“放置”）

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = 'images/inventoryimages/'..data.name..'.xml'
        inst.components.inventoryitem.imagename = data.name

        inst:AddComponent("deployable")
        inst.components.deployable.ondeploy = ondeploywire
        inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)
        inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
        inst.components.deployable._custom_candeploy_fn = function(inst, pt, mouseover, deployer, rot)
            local oldresult = TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover)
            local x = math.floor(pt.x) + .5
            local z = math.floor(pt.z) + .5
            local ents = TheSim:FindEntities(x, 0, z, 0.1, {}, {  'player', 'FX' }, { 'wire', 'logicparts' })
            if #ents > 0 then
                return false and oldresult
            end
            return true and oldresult
        end

        return inst
    end

    return Prefab(data.name, fn, assets, prefabs), Prefab  (data.name.."_item", itemfn, assets, { data.name, data.name..'_item_placer'}), MakePlacer(data.name.."_item_placer",  data.name, data.name, "None", true, false, true, 1.5, nil, nil, nil)
end

local wireprefabs = {}
local wiredata = {
    { name = 'electricwire', type = 'electric' },
    { name = 'logicwire', type = 'logic' },
}

for i, v in ipairs(wiredata) do
    local prefab, itemprefab, placer = MakeWire(v)
    table.insert(wireprefabs, prefab)
    table.insert(wireprefabs, itemprefab)
    table.insert(wireprefabs, placer)
end

return unpack(wireprefabs)