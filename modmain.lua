GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local _G = GLOBAL

PrefabFiles = {
    'tridprinter',
    'computer',
    'techscanner',
    'techcarrier',
    'electricwire',
    'batterys'
}

Assets = {}

_G.CONFIGS_GBP = {
    ALLPROTOTYPERUPGRADE = GetModConfigData('allPrototyperUpgrade'),
    NWIRE = GetModConfigData('nwire')
}

modimport('scripts/tools_GBP.lua')
modimport('scripts/languages/language_zh_GBP.lua')
modimport('scripts/tech_GBP.lua')
modimport('scripts/actions_GBP.lua')
modimport('scripts/electric_GBP.lua')
modimport('scripts/recipes_GBP.lua')
modimport('scripts/misc_GBP.lua')
