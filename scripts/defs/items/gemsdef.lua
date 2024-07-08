
local GEMS = {}
for k, v in pairs(UGPOWERS.EQUIPS) do
    GEMS[v.."_gem"] = {
        power = v,
    }
end






return GEMS