
local EQUIPS_POWER = UGPOWERS.EQUIPS


local enhance_weapon_items = {
    { lv = 0  , it = { stinger = 20 } },
    { lv = 20 , it = { houndstooth = 25  } },
    { lv = 40 , it = { redgem = 80, bluegem = 80 } },
    { lv = 60 , it = { lightninggoathorn = 80, horn = 80 } },
    { lv = 80 , it = { purplegem = 50 } },
    { lv = 100, it = { orangegem = 20, yellowgem = 20, greengem = 20 } }
}

local enhance_armor_items  = {
    { lv = 0  , it = { goldnugget = 20 } },
    { lv = 20 , it = { marble = 20 } },
    { lv = 40 , it = { townportaltalisman = 20 } },
    { lv = 60 , it = { slurtle_shellpieces = 20, cookiecuttershell = 20 } },
    { lv = 80 , it = { thulecite = 50 } },
    { lv = 100, it = { steelwool = 20, dragon_scales = 50, armorskeleton = 100, armorsnurtleshell = 100 } }
}



local ENHANCE_EQUIP_POWER_ITEMS = {
    [EQUIPS_POWER.DAMAGE] = enhance_weapon_items,
    [EQUIPS_POWER.CRITER] = enhance_weapon_items,
    [EQUIPS_POWER.SPLASH] = enhance_weapon_items,
    [EQUIPS_POWER.VAMPIR] = enhance_weapon_items,
    [EQUIPS_POWER.BLINDR] = enhance_weapon_items,
    [EQUIPS_POWER.POISON] = enhance_weapon_items,
    [EQUIPS_POWER.SPEEDR] = enhance_weapon_items,

    [EQUIPS_POWER.THORNS] = enhance_armor_items ,
    [EQUIPS_POWER.ABSORB] = enhance_armor_items ,
    [EQUIPS_POWER.DODGER] = enhance_armor_items ,

    [EQUIPS_POWER.CHOPER] = { 
        { lv = 0  , it = { twigs = 10 } },
        { lv = 25 , it = { log = 10 } },
        { lv = 50 , it = { palmcone_scale = 25 } },
        { lv = 75 , it = { livinglog = 25 } },
        { lv = 100, it = { twigs = 1, log = 3, palmcone_scale = 10, livinglog = 25 } }
    },

    [EQUIPS_POWER.MINING] = {
        { lv = 0  , it = { rocks = 10 } },
        { lv = 25 , it = { goldnugget = 10 } },
        { lv = 50 , it = { marble = 50 } },
        { lv = 75 , it = { nitre = 50 } },
        { lv = 100, it = { rocks = 1, goldnugget = 3, marble = 10, nitre = 25 } }
    },

    [EQUIPS_POWER.PROOFR] = {
        { lv = 0  , it = { pigskin = 100 } },
        { lv = 25 , it = { manrabbit_tail = 100 } },
        { lv = 50 , it = { slurper_pelt = 100 } },
        { lv = 75 , it = { tentaclespots = 100 } },
        { lv = 100, it = { voidcloth_umbrella = 200 } }
    },

    [EQUIPS_POWER.DAPPER] = {
        { lv = 0  , it = { petals = 25 } },
        { lv = 25 , it = { cactus_flower = 50 } },
        { lv = 50 , it = { nightmarefuel = 25 } },
        { lv = 75 , it = { spiderhat = 100 } },
        { lv = 100, it = { walrushat = 100 } }
    },

    [EQUIPS_POWER.WARMER] = {
        { lv = 0  , it = { silk = 25 } },
        { lv = 25 , it = { beefalowool = 50 } },
        { lv = 50 , it = { trunk_summer = 100, trunk_winter = 250 } },
        { lv = 75 , it = { goose_feather = 25 } },
        { lv = 100, it = { bearger_fur = 100 } }
    },

    [EQUIPS_POWER.MAXUSE] = {
        { lv = 0  , it = { goldnugget = 10 } },
        { lv = 25 , it = { moonrocknugget = 100 } },
        { lv = 50 , it = { redgem = 50, bluegem = 50 } },
        { lv = 75 , it = { thulecite = 50 } },
        { lv = 100, it = { deerclops_eyeball = 100, bearger_fur = 100, dragon_scales = 100, shroom_skin = 200 } }
    },
}


local weapon_powers = { 
    EQUIPS_POWER.SPEEDR,
    EQUIPS_POWER.MAXUSE, 
    EQUIPS_POWER.DAMAGE, 
    EQUIPS_POWER.CRITER, 
    EQUIPS_POWER.SPLASH, 
    EQUIPS_POWER.VAMPIR,
    EQUIPS_POWER.BLINDR,
    EQUIPS_POWER.POISON,
    EQUIPS_POWER.CHOPER,
    EQUIPS_POWER.MINING,
}


local armor_powers = {
    EQUIPS_POWER.MAXUSE, 
    EQUIPS_POWER.THORNS,
    EQUIPS_POWER.ABSORB,
    EQUIPS_POWER.DODGER
}


local clothes_powers = {
    EQUIPS_POWER.MAXUSE,
    EQUIPS_POWER.DAPPER,
    EQUIPS_POWER.WARMER,
    EQUIPS_POWER.PROOFR,
}





local CAN_INLAY_GEMS_EQUIPS = {
    spear = weapon_powers,
    spear_wathgrithr = weapon_powers,
    spear_wathgrithr_lightning = weapon_powers,
    nightsword = weapon_powers,
    ruins_bat = weapon_powers,
    glasscutter = weapon_powers,

    ruinshat = armor_powers,
    armorwood = armor_powers,
    armordragonfly = armor_powers,
    armormarble = armor_powers,
    armorruins = armor_powers,
    wathgrithrhat = armor_powers,

    beefalohat = clothes_powers,
    winterhat = clothes_powers,
    eyebrellahat = clothes_powers,
    walrushat = clothes_powers,
    beargervest = clothes_powers,
    trunkvest_winter = clothes_powers,
}


return {
    enhance = {
        items = ENHANCE_EQUIP_POWER_ITEMS
    },

    equips  = CAN_INLAY_GEMS_EQUIPS,
}