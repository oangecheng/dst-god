GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
require("utils/ugtuning")
require("utils/ugfns")
require("utils/uglog")


modimport("scripts/strings/power.lua")


--- 导入物品文件
PrefabFiles = {
    "ugpower",
}



if GLOBAL.TheNet:GetIsServer() then
    modimport("scripts/mods/hook.lua")
    modimport("scripts/mods/hookuser.lua")
    modimport("scripts/mods/hookatk.lua")
end



