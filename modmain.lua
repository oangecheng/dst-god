GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
require("utils/ugtuning")
require("utils/ugfns")
require("utils/uglog")

--- 导入物品文件
AddReplicableComponent("ugsync")
PrefabFiles = {
    "ugplayerfox",
    "ugpower",
    "uggems",
    "ugtasks",
    "ugitems",
    "ugpotions",
}

Assets = {
    Asset("ATLAS", "images/inventoryimages/uggems.xml"),
    Asset("IMAGE", "images/inventoryimages/uggems.tex"),

    Asset("ATLAS", "images/names_ugfoxgirl.xml"),
    Asset("IMAGE", "images/names_ugfoxgirl.tex"),
    Asset("IMAGE", "images/saveslot_portraits/ugfoxgirl.tex"),
    Asset("ATLAS", "images/saveslot_portraits/ugfoxgirl.xml"),
    Asset("ATLAS", "bigportraits/ugfoxgirl.xml"),
    Asset("IMAGE", "bigportraits/ugfoxgirl.tex"),
    Asset("IMAGE", "images/selectscreen_portraits/ugfoxgirl.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/ugfoxgirl.xml"),
    Asset("IMAGE", "images/selectscreen_portraits/ugfoxgirl_silho.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/ugfoxgirl_silho.xml"),
    Asset("IMAGE", "images/avatars/avatar_ugfoxgirl.tex"),
    Asset("ATLAS", "images/avatars/avatar_ugfoxgirl.xml"),
    Asset("IMAGE", "images/avatars/avatar_ghost_ugfoxgirl.tex"),
    Asset("ATLAS", "images/avatars/avatar_ghost_ugfoxgirl.xml"),
    Asset( "IMAGE", "images/map_icons/ugfoxgirl.tex" ),
	Asset( "ATLAS", "images/map_icons/ugfoxgirl.xml" ),

}

modimport("scripts/strings/strings.lua")
modimport("scripts/strings/power.lua")
modimport("scripts/mods/hookaction.lua")
modimport("scripts/ui/ugui.lua")
modimport("scripts/mods/rpc.lua")
modimport("scripts/mods/hookuser.lua")
modimport("scripts/mods/recipes.lua")



AddMinimapAtlas("images/map_icons/ugfoxgirl.xml")
AddModCharacter("ugfoxgirl","FEMALE")



if GLOBAL.TheNet:GetIsServer() then
    modimport("scripts/mods/hook.lua")
    modimport("scripts/mods/hookatk.lua")
end



