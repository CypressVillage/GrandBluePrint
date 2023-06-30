local _G = GLOBAL

--[[
    添加自定义科技
]]

-- 注册物品科技树，表示有这种科技
local TechTree = require('techtree')
table.insert(TechTree.AVAILABLE_TECH, 'COMPUTERSCIENCE')
table.insert(TechTree.AVAILABLE_TECH, 'ELECTRICENGINEERING')

-- 加入自己的制作等级，表示这种科技有几个等级
_G.TECH.NONE.COMPUTERSCIENCE = 0
_G.TECH.NONE.ELECTRICENGINEERING = 0
_G.TECH.COMPUTERSCIENCE_ONE = { COMPUTERSCIENCE = 1 }
_G.TECH.COMPUTERSCIENCE_TWO = { COMPUTERSCIENCE = 2 }
_G.TECH.ELECTRICENGINEERING_ONE = { ELECTRICENGINEERING = 1 }
_G.TECH.ELECTRICENGINEERING_TWO = { ELECTRICENGINEERING = 2 }

-- 解锁等级中加入自己的部分
for _, v in pairs(TUNING.PROTOTYPER_TREES) do
    v.COMPUTERSCIENCE = 0
    v.ELECTRICENGINEERING = 0
end

-- 制作站可以解锁几级科技
TUNING.PROTOTYPER_TREES.COMPUTER = TechTree.Create({
    COMPUTERSCIENCE = 1,
    SCIENCE = 2
})
TUNING.PROTOTYPER_TREES.TRIDPRINTER = TechTree.Create({
    ELECTRICENGINEERING = 1,
    SCIENCE = 3
})


-- 这里是新制作栏的兼容，靠近科技会弹出哪个制作栏
AddPrototyperDef(
    'computer', -- prefab名
    {
        icon_atlas = 'images/crafting_menu_icons.xml',
        icon_image = 'filter_events.tex',
        filter_text = 'COMPUTERSCIENCE'
    }
)

AddPrototyperDef(
    'tridprinter', -- prefab名
    {
        icon_atlas = 'images/crafting_menu_icons.xml',
        icon_image = 'filter_events.tex',
        action_str = 'TRIDPRINTER', -- 指STRINGS.ACTIONS.OPEN_CRAFTING.TRIDPRINTER
        filter_text = 'ELECTRICENGINEERING'
    }
)


--[[
    为新版制作栏添加远古、天体等常驻选项
    其中制作栏标签要在STRINGS.UI.CRAFTING_FILTERS里定义
]]--
AddRecipeFilter({
    name = 'ANCIENT',
    atlas = "images/crafting_menu_icons.xml",
    image = "station_crafting_table.tex"
})

AddRecipeFilter({
    name = 'CELESTIAL',
    atlas = "images/crafting_menu_icons.xml",
    image = "station_celestial.tex"
})

AddRecipeFilter({
    name = 'SHADOWFORGING',
    atlas = "images/crafting_menu_icons.xml",
    image = "station_shadow_forge.tex"
})

AddRecipeFilter({
    name = 'LUNARFORGING',
    atlas = "images/crafting_menu_icons.xml",
    image = "station_lunar_forge.tex"
})

AddRecipeFilter({
    name = 'CARTOGRAPHY',
    atlas = "images/crafting_menu_icons.xml",
    image = "station_cartography.tex"
})

AddRecipeFilter({
    name = 'HERMITCRABSHOP',
    atlas = "images/crafting_menu_icons.xml",
    image = "station_hermitcrab_shop.tex"
})

AddRecipeFilter({
    name = 'COMPUTERSCIENCE',
    atlas = "images/avatars.xml",
    image = "avatar_server.tex"
})

AddRecipeFilter({
    name = 'ELECTRICENGINEERING',
    atlas = "images/button_icons.xml",
    image = "mods.tex"
})


for _, recipe in _G.pairsByKeys(AllRecipes) do
    -- 首先把这个物品的科技补全，这是因为定义新的AVAILABLE_TECH之前已经注册过prefab了，tectree.Create()没有注册COMPUTERSCIENCE科技
	if recipe.level.COMPUTERSCIENCE == nil then
		recipe.level.COMPUTERSCIENCE = 0
	end
    if recipe.level.ELECTRICENGINEERING == nil then
		recipe.level.ELECTRICENGINEERING = 0
	end

    
    -- 向新的制作栏里增加内容
    if recipe.level.ANCIENT ~= 0 and recipe.level.ANCIENT <= 4 then
        AddRecipeToFilter(recipe.name, 'ANCIENT')
    end
    if recipe.level.CELESTIAL ~= 0 and recipe.level.CELESTIAL <= 3 then
        AddRecipeToFilter(recipe.name, 'CELESTIAL')
    end
    if recipe.level.SHADOWFORGING ~= 0 then
        AddRecipeToFilter(recipe.name, 'SHADOWFORGING')
    end
    if recipe.level.LUNARFORGING ~= 0 then
        AddRecipeToFilter(recipe.name, 'LUNARFORGING')
    end
    if recipe.level.CARTOGRAPHY ~= 0 then
        AddRecipeToFilter(recipe.name, 'CARTOGRAPHY')
    end
    if recipe.level.HERMITCRABSHOP ~= 0 then
        AddRecipeToFilter(recipe.name, 'HERMITCRABSHOP')
    end
    if recipe.level.COMPUTERSCIENCE ~= 0 then
        AddRecipeToFilter(recipe.name, 'COMPUTERSCIENCE')
    end
    if recipe.level.ELECTRICENGINEERING ~= 0 then
        AddRecipeToFilter(recipe.name, 'ELECTRICENGINEERING')
    end
end

--[[
    升级科技是否兼容所有制作站
]]--
if _G.CONFIGS_GBP.ALLPROTOTYPERUPGRADE then
    local prototyperBuildings = {
        'researchlab',
        'researchlab2',
        'researchlab3',
        'researchlab4',
        'bookstation',
        'seafaring_prototyper',
        'tacklestation',
        'cartographydesk',
        'madscience_lab'
    }
    for _, v in pairs(prototyperBuildings) do
        AddPrefabPostInit(v, function(inst)
            inst:AddComponent('trader')
            inst.components.trader:SetAcceptTest(function (inst, item)
                if item.prefab == "techcarrier" then
                    return true
                end
                return false
            end)
            inst.components.trader.onaccept = function (inst, giver, item)
                for name, val in pairs(item.techinfo) do
                    if inst.components.prototyper.trees[name] < val then
                        inst.components.prototyper.trees[name] = val
                    end
                end
            end
            inst.components.trader.onrefuse = function () end

            local OnSave_old = inst.OnSave
            inst.OnSave = function(inst, data)
                OnSave_old(inst, data)
                data.techdata = inst.components.prototyper.trees
            end

            local OnLoad_old = inst.OnLoad
            inst.OnLoad = function(inst, data)
                OnLoad_old(inst, data)
                if data ~= nil then
                    inst.components.prototyper.trees = data.techdata
                end
            end
        end)
    end
end