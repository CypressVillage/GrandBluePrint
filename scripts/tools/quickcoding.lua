local _G = GLOBAL


--[ 地图图标注册 ]--  >>from Legion<<
_G.RegistMiniMapImage_legion = function(filename, fileaddresspre)
    local fileaddresscut = (fileaddresspre or "images/map_icons/")..filename

    table.insert(Assets, Asset("ATLAS", fileaddresscut..".xml"))
    table.insert(Assets, Asset("IMAGE", fileaddresscut..".tex"))

    AddMinimapAtlas(fileaddresscut..".xml")

    --  接下来就需要在prefab定义里添加：
    --      inst.entity:AddMiniMapEntity()
    --      inst.MiniMapEntity:SetIcon("图片文件名.tex")
end