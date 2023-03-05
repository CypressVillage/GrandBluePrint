local _G = GLOBAL
local STRINGS = _G.STRINGS

-- 新制作栏名字
STRINGS.UI.CRAFTING_FILTERS.ANCIENT = STRINGS.UI.CRAFTING_STATION_FILTERS.ANCIENT -- 远古
STRINGS.UI.CRAFTING_FILTERS.CELESTIAL = STRINGS.UI.CRAFTING_STATION_FILTERS.CELESTIAL -- 天体
STRINGS.UI.CRAFTING_FILTERS.CARTOGRAPHY = STRINGS.UI.CRAFTING_STATION_FILTERS.CARTOGRAPHY -- 制图
STRINGS.UI.CRAFTING_FILTERS.HERMITCRABSHOP = STRINGS.UI.CRAFTING_STATION_FILTERS.HERMITCRABSHOP -- 瓶罐交易
STRINGS.UI.CRAFTING_FILTERS.COMPUTERSCIENCE = "Computer Science"
STRINGS.UI.CRAFTING_FILTERS.ELECTRICENGINEERING = "Electric Engineering"

-- Action名字
STRINGS.ACTIONS_GBP = {
    SCAN_TECH = 'try scan', -- 扫描科技
    REPAIR_BROKEN_WIRE = 'repatch', -- 修补烂电线
}

STRINGS.ACTIONS.OPEN_CRAFTING.TRIDPRINTER = '操作' -- 靠近3D打印机

-- 用于检查复制科技 <techcarrier>
STRINGS.TECHNAMES_GBP = {
    COMPUTERSCIENCE = 'CS',
    ELECTRICENGINEERING = 'EE',

    ELECOURMALINE = 'ELECOURMALINE',
}

-- prefab描述
STRINGS.NAMES.TRIDPRINTER = '3D printer'
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TRIDPRINTER = '从更高的维度理解永恒大陆的科技'
STRINGS.RECIPE_DESC.TRIDPRINTER = '你想来点什么？'

STRINGS.NAMES.COMPUTER = '埃尼阿克'
STRINGS.CHARACTERS.GENERIC.DESCRIBE.COMPUTER = '难以置信他会出现'
STRINGS.RECIPE_DESC.COMPUTER = '人类最伟大的发明之一'

STRINGS.NAMES.TECHCARRIER = '宝贵的资料'
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TECHCARRIER = function (tectree)
    local rtn = '这份资料里记载了\n'
    for name, val in pairs(tectree) do
        if val and val ~= 0 then
            rtn = rtn..tostring(val)..'级'..(STRINGS.TECHNAMES_GBP[name] or name)..'科技\n'
        end
    end
    return rtn
end

STRINGS.NAMES.TECHSCANNER = '科技扫描仪'
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TECHSCANNER = '科学无国界，不是吗'
STRINGS.RECIPE_DESC.TECHSCANNER = '偷窃科学'

STRINGS.NAMES.ELECTRICWIRE_ITEM = '电线'
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ELECTRICWIRE_ITEM = '一段电线'
STRINGS.RECIPE_DESC.ELECTRICWIRE_ITEM = '你的数电学得怎么样？'

STRINGS.NAMES.ELECTRICWIRE = '电线'
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ELECTRICWIRE = '你有灵感吗？反正我没有'

STRINGS.NAMES.BATTERYSM = '小型电池'
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BATTERYSM = '希望它还有电'
STRINGS.RECIPE_DESC.BATTERYSM = '支撑你的电路'