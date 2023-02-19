local L = locale ~= "zh" and locale ~= "zhr"

name = L and 'Grand Blueprint' or '宏伟蓝图'
author = "Cypress"
version = "V0.0.0"
description = "Make Science Great Again!"

forumthread = ""
api_version = 10

dst_compatible = true
all_clients_require_mod = true
client_only_mod = false

-- icon_atlas = "modicon.xml"
-- icon = "modicon.tex"

-- server_filter_tags = L and { "LEGION", } or { "棱镜", }

configuration_options = {
    {name = "Title", label = L and "Language" or "语言", options = {{description = "", data = ""},}, default = "",},
    L and {
        name = "Language",
        label = "Set Language",
        hover = "Choose your language",
        options =
        {
            -- {description = "Auto", data = "auto"},
            {description = "English", data = "english"},
            {description = "Chinese", data = "chinese"},
        },
        default = "english",
    } or {
        name = "Language",
        label = "设置语言",
        hover = "设置mod语言。",
        options =
        {
            -- {description = "自动", data = "auto"},
            {description = "英文", data = "english"},
            {description = "中文", data = "chinese"},
        },
        default = "chinese",
    },


    {name = "Title", label = "", options = {{description = "", data = ""},}, default = "",},
    {
        name = "Title",
        label = L and "NewTechTrees" or "新科技树",
        options = {{description = "", data = ""},},
        default = "",
    },
    L and {
        name = "allPrototyperUpgrade",
        label = "所有科技站可升级",
        hover = "是否允许所有科技站像3D打印机一样学习科技（这样你就可以给“3D打印机”更换皮肤了”）",
        options = 
        {
            {description = "Yes", data = true},
            {description = "No", data = false},
        },
        default = true,
    } or {
        name = "allPrototyperUpgrade",
        label = "所有科技站可升级",
        hover = "是否允许所有科技站像3D打印机一样学习科技",
        options = 
        {
            {description = "是", data = true},
            {description = "否", data = false},
        },
        default = true,
    },


    {name = "Title", label = "", options = {{description = "", data = ""},}, default = "",},
    {
        name = "Title",
        label = L and "Advance Options" or "高级设置",
        options = {{description = "", data = ""},},
        default = "",
    },
    L and {
        name = "nwire",
        label = "电路系统预分配内存",
        hover = "这里是你世界的导线数目",
        options = 
        {
            {description = "64", data = 64},
            {description = "128", data = 128},
            {description = "256", data = 256},
            {description = "512", data = 512},
        },
        default = 64,
    } or {
        name = "nwire",
        label = "电路系统预分配内存",
        hover = "这里是你世界的导线数目",
        options = 
        {
            {description = "64", data = 64},
            {description = "128", data = 128},
            {description = "256", data = 256},
            {description = "512", data = 512},
        },
        default = 64,
    },
}