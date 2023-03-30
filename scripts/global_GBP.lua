local _G = GLOBAL
_G.GBP = {}

setmetatable(_G.GBP, {__index = _G})
setfenv(1, _G.GBP)


--[[
    CHIPS
--]]
CHIPPACKAGES = {
    ['1X2'] = {
        {num = 0, dx = 0, dy = 0},
        {num = 1, dx = 0, dy = 1},
    },
    ['2X2'] = {
        {num = 0, dx = -1, dy = 0},
        {num = 1, dx = 1, dy = 0},
        {num = 2, dx = -1, dy = 1},
        {num = 3, dx = 1, dy = 1},
    },
    ['4x2'] = {
        {num = 0, dx = -1, dy = 0},
        {num = 1, dx = 1, dy = 0},
        {num = 2, dx = -1, dy = 1},
        {num = 3, dx = 1, dy = 1},
        {num = 4, dx = -1, dy = 2},
        {num = 5, dx = 1, dy = 2},
        {num = 6, dx = -1, dy = 3},
        {num = 7, dx = 1, dy = 3},
    },
}

CHIPINFO = {
    {
        name = 'convertor',
        package = '8x2',
        pins = {
            {num = 0, type = "in", posx = -1, posz = -1, name = 'kkk', desc = "输入"},
            {num = 1, type = "out", posx = 1, posz = -1, name = '', desc = "输出"},
        },
        fn = function(...) return ... end,
    },
}
