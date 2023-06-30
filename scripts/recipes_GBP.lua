local _G = GLOBAL

-- 贴图资源文件
local assets = {
    Asset("ATLAS", "images/inventoryimages/electricwire.xml"),
    Asset("IMAGE", "images/inventoryimages/electricwire.tex"),
    Asset("ATLAS", "images/inventoryimages/logicwire.xml"),
    Asset("IMAGE", "images/inventoryimages/logicwire.tex"),
    Asset("ATLAS", "images/inventoryimages/computer.xml"),
    Asset("IMAGE", "images/inventoryimages/computer.tex"),
    Asset("ATLAS", "images/inventoryimages/batterysm.xml"),
    Asset("IMAGE", "images/inventoryimages/batterysm.tex"),
    Asset("ATLAS", "images/inventoryimages/batterymed.xml"),
    Asset("IMAGE", "images/inventoryimages/batterymed.tex"),
    Asset("ATLAS", "images/inventoryimages/batterylg.xml"),
    Asset("IMAGE", "images/inventoryimages/batterylg.tex"),
}

-- 在地图上能显示图标的预制物
local MiniMapVisible = {
    "tridprinter",
    "computer",
    "batterysm",
    "batterymed",
    "batterylg",
}

-- 可制作物品配方
local Recipes_GBP = {
    {
        'tridprinter',
        {
            Ingredient('moonglass', 10),
            Ingredient('nightmarefuel', 10),
            Ingredient('thulecite', 10),
        },
        TECH.SCIENCE_TWO,
        {
            atlas = 'images/inventoryimages2.xml',
            image = 'researchlab2_pod.tex',
            placer = 'tridprinter_placer',
            min_spacing = 2,
        },
        { 'PROTOTYPERS', 'ELECTRICENGINEERING' }
    },
    {
        'computer',
        {
            Ingredient('moonglass', 10),
        },
        TECH.SCIENCE_TWO,
        {
            atlas = 'images/inventoryimages/computer.xml',
            image = 'computer.tex',
            placer = 'computer_placer',
            min_spacing = 2,
        },
        { 'PROTOTYPERS', 'COMPUTERSCIENCE' }
    },
    {
        'techscanner',
        {
            Ingredient('moonglass', 5),
            Ingredient('nightmarefuel', 5),
        },
        TECH.ELECTRICENGINEERING_ONE,
        {
            atlas = 'images/inventoryimages2.xml',
            image = 'wagstaff_tool_4.tex',
            nounlock = true
        },
        { 'PROTOTYPERS', 'COMPUTERSCIENCE' }
    },
    {
        'electricwire_item',
        {
            Ingredient('cutgrass', 5),
        },
        TECH.ELECTRICENGINEERING_ONE,
        {
            numtogive = 6,
            atlas = 'images/inventoryimages/electricwire.xml',
            image = 'electricwire.tex',
            -- testfn = PlacerTest_wire,
        },
        { 'ELECTRICENGINEERING' }
    },
    {
        'logicwire_item',
        {
            Ingredient('cutgrass', 5),
        },
        TECH.ELECTRICENGINEERING_ONE,
        {
            numtogive = 6,
            atlas = 'images/inventoryimages/logicwire.xml',
            image = 'logicwire.tex',
        },
        { 'ELECTRICENGINEERING' }
    },
    {
        'batterysm',
        {
            Ingredient('moonglass', 10),
        },
        TECH.SCIENCE_TWO,
        {
            atlas = 'images/inventoryimages/batterysm.xml',
            image = 'batterysm.tex',
            placer = 'batterysm_placer',
        },
        { 'ELECTRICENGINEERING' }
    },
    {
        'batterymed',
        {
            Ingredient('moonglass', 10),
            Ingredient('nightmarefuel', 10),
            Ingredient('thulecite', 10),
        },
        TECH.SCIENCE_TWO,
        {
            atlas = 'images/inventoryimages/batterymed.xml',
            image = 'batterymed.tex',
            placer = 'batterymed_placer',
        },
        { 'ELECTRICENGINEERING' }
    },
    {
        'batterylg',
        {
            Ingredient('moonglass', 10),
            Ingredient('nightmarefuel', 10),
            Ingredient('thulecite', 10),
        },
        TECH.SCIENCE_TWO,
        {
            atlas = 'images/inventoryimages/batterylg.xml',
            image = 'batterylg.tex',
            placer = 'batterylg_placer',
        },
        { 'ELECTRICENGINEERING' }
    }
}

-- 注册贴图资源文件
for _, v in pairs(assets) do
    table.insert(Assets, v)
end

-- 注册地图图标
for _, v in pairs(MiniMapVisible) do
    _G.RegistMiniMapImage_legion(v)
end

-- 注册物品配方
for _, v in pairs(Recipes_GBP) do
    AddRecipe2(unpack(v))
end
