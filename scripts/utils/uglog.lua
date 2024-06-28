
---comment 日志函数
---@param msg string
---@param v1 any
---@param v2 any
---@param v3 any
function UgLog(msg, v1, v2, v3)
    if UGCOFIG.LOG then
        print("UgLog: "..msg.." v1="..tostring(v1).." v2="..tostring(v2).." v3="..tostring(v3))
    end
    
end