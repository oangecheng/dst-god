GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
require("utils/ugtuning")
require("utils/ugfns")
require("utils/uglog")

--- 导入物品文件
AddReplicableComponent("ugsync")
PrefabFiles = {
    "ugpower",
    "ugitems"
}
Assets = {
    Asset("ANIM", "images/items/uggems.xml"),
    Asset("ANIM", "images/items/uggems.tex"),
}

modimport("scripts/strings/power.lua")
modimport("scripts/mods/hookaction.lua")
modimport("scripts/ui/ugui.lua")



if GLOBAL.TheNet:GetIsServer() then
    modimport("scripts/mods/hook.lua")
    modimport("scripts/mods/hookuser.lua")
    modimport("scripts/mods/hookatk.lua")
end



