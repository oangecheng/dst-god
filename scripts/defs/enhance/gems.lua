local EQUIPS = UGPOWERS.EQUIPS


local ITEMS = {}
ITEMS[EQUIPS.CRITER] = { bearger_fur = 100 }
ITEMS[EQUIPS.DODGER] = { shroom_skin = 100 }
ITEMS[EQUIPS.VAMPIR] = { mosquitosack = 20, spidergland = 10 }
ITEMS[EQUIPS.SPLASH] = { minotaurhorn = 200 }
ITEMS[EQUIPS.BLINDR] = { deerclops_eyeball = 100 }
ITEMS[EQUIPS.POISON] = { glommerfuel = 20 }
ITEMS[EQUIPS.THORNS] = { cactus_flower = 20 }
ITEMS[EQUIPS.DAMAGE] = { houndstooth = 5, stinger = 5 }
ITEMS[EQUIPS.MAXUSE] = { dragon_scales = 30 }
ITEMS[EQUIPS.WARMER] = { trunk_winter = 100, trunk_summer = 80, silk = 5, beefalowool = 5 }
ITEMS[EQUIPS.DAPPER] = { spiderhat = 10,  walrushat = 30 }
ITEMS[EQUIPS.PROOFR] = { pigskin = 1, tentaclespots = 10 }
ITEMS[EQUIPS.CHOPER] = { livinglog = 50, log = 10 }
ITEMS[EQUIPS.MINING] = { marble = 50, nitre = 100,  flint = 10, rocks = 10, goldnugget = 20 }
ITEMS[EQUIPS.SPEEDR] = { walrus_tusk = 300 }
ITEMS[EQUIPS.ABSORB] = { steelwool = 100 }


return {
    enhancefn = function(inst, item, name)
        local items = ITEMS[name]
        if not (item ~= nil and items ~= nil) then
            return false
        end
        local xp = items[item.prefab]
        if item.components.stackable ~= nil then
            xp = xp * item.components.stackable:StackSize()
        end
        GainUgPowerXp(inst, name, xp)
        return true
    end
}
