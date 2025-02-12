
local PLAYER = UGPOWERS.PLAYER

local potions = {

}

for k, v in pairs(PLAYER) do
    potions[v.."_potion"] = {
        loop = true,
        power = v,
    }
end




return potions