local _G = GLOBAL

assets = {
    Asset("ATLAS", "images/inventoryimages/electricwire.xml"),
    Asset("IMAGE", "images/inventoryimages/electricwire.tex"),
    Asset("ATLAS", "images/inventoryimages/computer.xml"),
    Asset("IMAGE", "images/inventoryimages/computer.tex"),
    Asset("ATLAS", "images/inventoryimages/batterysm.xml"),
    Asset("IMAGE", "images/inventoryimages/batterysm.tex"),
}

for _, v in pairs(assets) do
    table.insert(Assets, v)
end

-- 注册地图图标
_G.RegistMiniMapImage_legion("tridprinter")
_G.RegistMiniMapImage_legion("computer")
_G.RegistMiniMapImage_legion("batterysm")

AddRecipe2(
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
)

AddRecipe2(
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
)

AddRecipe2(
    'techscanner',
    {
        Ingredient('moonglass', 5),
        Ingredient('nightmarefuel', 5),
    },
    TECH.ELECTRICENGINEERING_ONE,
    {
        atlas = 'images/inventoryimages2.xml',
        image = 'wagstaff_tool_4.tex',
        -- nounlock = true
    },
    { 'PROTOTYPERS', 'COMPUTERSCIENCE' }
)

AddRecipe2(
    'electricwire_item',
    {
        Ingredient('cutgrass', 5),
    },
    TECH.ELECTRICENGINEERING_ONE,
    {
        numtogive = 6,
        atlas = 'images/inventoryimages/electricwire.xml',
        image = 'electricwire.tex',
    },
    { 'ELECTRICENGINEERING' }
)

AddRecipe2(
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
    { 'PROTOTYPERS', 'COMPUTERSCIENCE' }
)