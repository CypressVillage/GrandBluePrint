GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local _G = GLOBAL

PrefabFiles = {
    'batteries',
    'computer',
    'techtools',
    'tridprinter',
    'wires',
}

Assets = {}

_G.CONFIGS_GBP = {
    ALLPROTOTYPERUPGRADE = GetModConfigData('allPrototyperUpgrade'),
    NWIRE = GetModConfigData('nwire'),
    GLASSICAPITOOLS = GetModConfigData('GlassicPrefabOn')
}

modimport('scripts/tools/tabletools.lua')
modimport('scripts/tools/log.lua')
modimport('scripts/tools/quickcoding.lua')
-- modimport('scripts/tools/hotload.lua')

modimport('scripts/global_GBP.lua')
modimport('scripts/languages/language_zh_GBP.lua')
modimport('scripts/tech_GBP.lua')
modimport('scripts/actions_GBP.lua')
-- modimport('scripts/electric_GBP.lua')
modimport('scripts/electric_GBP2.lua')
modimport('scripts/logic_GBP.lua')
modimport('scripts/recipes_GBP.lua')
modimport('scripts/misc_GBP.lua')

-- modimport('uii.lua')
log('all parts imported')