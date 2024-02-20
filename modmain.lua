GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
require("ksg_tunning")
require("ksg_fns")


modimport("scripts/strings/powerstr.lua")


--- 导入物品文件
PrefabFiles = {
    "ksg_powers",
    "ksg_tasks",
}



if GLOBAL.TheNet:GetIsServer() then
    modimport("scripts/mods/inituser.lua")
end



