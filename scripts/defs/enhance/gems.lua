---@diagnostic disable: undefined-field
local EQUIPS = UGPOWERS.EQUIPS


local ITEMS = {}
ITEMS[EQUIPS.CRITER] = { bearger_fur = 100 }
ITEMS[EQUIPS.DODGER] = { shroom_skin = 100 }
ITEMS[EQUIPS.VAMPIR] = { mosquitosack = 20, spidergland = 10 }
ITEMS[EQUIPS.SPLASH] = { minotaurhorn = 200 }
ITEMS[EQUIPS.BLINDR] = { deerclops_eyeball = 100 }
ITEMS[EQUIPS.POISON] = { glommerfuel = 20 }
ITEMS[EQUIPS.THORNS] = { cactus_flower = 20 }
ITEMS[EQUIPS.DAMAGE] = { houndstooth = 5, stinger = 5, ruins_bat = 300, nightsword = 100, tentaclespike = 50 }
ITEMS[EQUIPS.MAXUSE] = { dragon_scales = 50 }
ITEMS[EQUIPS.WARMER] = { trunk_winter = 200, trunk_summer = 160, silk = 10, beefalowool = 10 }
ITEMS[EQUIPS.DAPPER] = { spiderhat = 10, walrushat = 30 }
ITEMS[EQUIPS.PROOFR] = { pigskin = 10, tentaclespots = 100 }
ITEMS[EQUIPS.CHOPER] = { livinglog = 10, log = 1 }
ITEMS[EQUIPS.MINING] = { marble = 50, nitre = 100, flint = 10, rocks = 10, goldnugget = 20 }
ITEMS[EQUIPS.SPEEDR] = { walrus_tusk = 300 }
ITEMS[EQUIPS.ABSORB] = { steelwool = 100 }


local weapon_powers = {
    EQUIPS.BLINDR,
    EQUIPS.CHOPER,
    EQUIPS.CRITER,
    EQUIPS.DAMAGE,
    EQUIPS.MAXUSE,
    EQUIPS.MINING,
    EQUIPS.POISON,
    EQUIPS.SPEEDR,
    EQUIPS.SPLASH,
    EQUIPS.VAMPIR
}


local clothes_powers = {
    EQUIPS.DAPPER,
    EQUIPS.MAXUSE,
    EQUIPS.PROOFR,
    EQUIPS.WARMER,
}


local armor_powers = {
    EQUIPS.ABSORB,
    EQUIPS.DODGER,
    EQUIPS.THORNS,
    EQUIPS.DAPPER,
    EQUIPS.MAXUSE,
    EQUIPS.PROOFR,
    EQUIPS.WARMER,
}


local weapons = {
    "spear",
    "spear_wathgrithr",
    "spear_wathgrithr_lightning",
    "ruins_bat",
    "nightsword",
}


local clothes = {
    "beefalohat",
    "winterhat",
    "eyebrellahat",
    "walrushat",
}


local armors = {
    "ruinshat",
    "armorwood",
    "armordragonfly",
    "armormarble",
    "armorruins",
    "wathgrithrhat",
}


local function can_inlay_fn(target, power)
    local prefab = target ~= nil and target.prefab or nil
    if prefab == nil then
        return false
    end

    local powers = {}
    if table.contains(weapons, prefab) then
        powers = weapon_powers
    elseif table.contains(clothes, prefab) then
        powers = clothes_powers
    elseif table.contains(armors, prefab) then
        powers = armor_powers
    end

    if table.contains(powers, power) then
        return true
    end

    return false
end


local function enhance_fn(gem, item, name)
    local items = ITEMS[name]
    if not (item ~= nil and items ~= nil) then
        return false
    end
    local xp = items[item.prefab]
    if xp == nil then
        return false
    end
    if item.components.stackable ~= nil then
        xp = xp * item.components.stackable:StackSize()
    end
    gem.components.uglevel:XpDelta(xp)
    return true
end


return {
    caninlayfn = can_inlay_fn,
    enhancefn  = enhance_fn,
    equips     = JoinArrays(weapons, armors, clothes)
}
