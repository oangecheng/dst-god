
---comment 日志函数
---@param msg string
---@param v1 any
---@param v2 any
---@param v3 any
function KsgLog(msg, v1, v2, v3)
    if KSG_CONF.LOG then
        print("KsgLog: "..msg.." v1="..tostring(v1).." v2="..tostring(v2).." v3"..tostring(v3))
    end
end