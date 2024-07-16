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
    Asset("ANIM", "images/items/uggems.xml"),
    Asset("ANIM", "images/items/uggems.tex"),
}

modimport("scripts/strings/strings.lua")
modimport("scripts/strings/power.lua")
modimport("scripts/mods/hookaction.lua")
modimport("scripts/ui/ugui.lua")
modimport("scripts/mods/rpc.lua")


AddMinimapAtlas("images/map_icons/carney.xml")
AddModCharacter("ugfoxgirl","FEMALE")



if GLOBAL.TheNet:GetIsServer() then
    modimport("scripts/mods/hook.lua")
    modimport("scripts/mods/hookuser.lua")
    modimport("scripts/mods/hookatk.lua")
end



