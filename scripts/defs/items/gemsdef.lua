

local EQUIPS = UGPOWERS.EQUIPS
local STARS  = UGSTARS

local POWER_RARITY = {
    [EQUIPS.CHOPER] = STARS.D,
    [EQUIPS.MINING] = STARS.D,
    [EQUIPS.PROOFR] = STARS.D,
    
    [EQUIPS.ABSORB] = STARS.C,
    [EQUIPS.MAXUSE] = STARS.C,
    [EQUIPS.THORNS] = STARS.C,
    [EQUIPS.WARMER] = STARS.C,

    [EQUIPS.BLINDR] = STARS.B,
    [EQUIPS.DODGER] = STARS.B,
    [EQUIPS.POISON] = STARS.B,

    [EQUIPS.CRITER] = STARS.A,
    [EQUIPS.DAMAGE] = STARS.A,
    [EQUIPS.DAPPER] = STARS.A,
    [EQUIPS.SPEEDR] = STARS.A,
    [EQUIPS.VAMPIR] = STARS.A,
    
    [EQUIPS.SPLASH] = STARS.S,
}


local GEMS = {}
for k, v in pairs(EQUIPS) do
    local data = {
        power = v,
        rarity = POWER_RARITY[v],
    }
 
    if v == EQUIPS.CHOPER or v == EQUIPS.MINING or v == EQUIPS.PROOFR then
        data["xpfn"] = function (lv)
            return 10
        end
    end
    GEMS[v.."_gem"] = data
end

return GEMS