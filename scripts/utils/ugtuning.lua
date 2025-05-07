
UGCOFIG = {
    TEST = false,
    CH   = true,
    LOG  = true,
}


UGENTITY_TYPE = {
    POWER = 1,
    TASK = 2,
}

UGTAGS = {
    LEVEL         = "uglevel",
    BLUEPRINTS    = "ugblueprints",
    GEM           = "uggems",
    REPAIR        = "ugrepair",
    POTION        = "ugpotion",
    SWICTH        = "ugswitch",
    ACTIVE        = "ugactive",
    MAGIC_ITEM    = "ugmagic_item",
    MAGIC_TARGET  = "ugmagic_target"
}

UGEVENTS = {
    POWER_UPDATE = "ugpower_update",
    HARVEST_SELF_FOOD = "ugharvest_self_food",
    HARVEST_DRY = "ugharvest_dry",
    PICK_STH = "ugpick_something",
    FISH_SUCCESS = "ugfish_success",
    HEAL = "ugheal",
    TASK_FINISH = "ugtask_finish"
}


local player = "ugplayer_"
local equips = "ugequips_" 
UGPOWERS = {
    PLAYER = {
        HUNGER = player.."hunger",
        HEALTH = player.."health",
        SANITY = player.."sanity",
        COOKER = player.."cooker",
        DRYERR = player.."dryerr",
        PICKER = player.."picker",
        FARMER = player.."farmer",
        FISHER = player.."fisher",
        RUNNER = player.."runner",
        DOCTOR = player.."doctor",
        HUNTER = player.."hunter",
    },

    EQUIPS = {
        ---伤害类型
        CRITER = equips.."criter",
        DODGER = equips.."dodger",

        ---攻击效果
        VAMPIR = equips.."vampir",
        SPLASH = equips.."splash",
        BLINDR = equips.."blindr",
        POISON = equips.."poison",

        ---被攻击效果
        THORNS = equips.."thorns", --荆棘

        ---固定类型
        DAMAGE = equips.."damage",
        MAXUSE = equips.."maxuse",
        WARMER = equips.."warmer",
        DAPPER = equips.."dapper",
        PROOFR = equips.."proofr",
        CHOPER = equips.."choper",
        MINING = equips.."mining",
        SPEEDR = equips.."speedr",
        ABSORB = equips.."absorb",
    }
}


UGMAGICS = {
    PLANT_BUSH = "ugmagic_plant_bush",
    MEAT_RACK  = "ugmagic_meat_rack" ,
    
}


UGSTARS = {
    D = 1,
    C = 2,
    B = 3,
    A = 4,
    S = 5,
}


UGTASKS = {

    NAMES = {
        BOUNTY = "ugtask_bounty"
    },

    TYPES = {
        KILL = 1,
        FISH = 2,
    },

    LIMIT = {
        NONE = 0,
        TIME = 1,
        MOON = 2,
        AREA = 3,
    },

    AWARD = {
        ITEM = 1,
    },

    PUNISH = {

    }
}


UGMARK = {
    COOK_MULTI = "cook_multi",
    DRY_MULTI  = "dry_multi" ,
    FISH_MULTI = "fish_multi",
    ATK_MISS   = "atk_miss",
    HEAL_MULTI = "heal_multi",
    FULE_MULTI = "fule_multi";
}



UGTUNNING = {

    ENHANCE_WEAPON_ITEMS = {
        { lv = 0  , it = { stinger = 20 } },
        { lv = 20 , it = { houndstooth = 25  } },
        { lv = 40 , it = { redgem = 80, bluegem = 80 } },
        { lv = 60 , it = { lightninggoathorn = 80, horn = 80 } },
        { lv = 80 , it = { purplegem = 50 } },
        { lv = 100, it = { orangegem = 20, yellowgem = 20, greengem = 20 } }
    },

    ENHANCE_ARMOR_ITEMS  = {
        { lv = 0  , it = { goldnugget = 20 } },
        { lv = 20 , it = { marble = 20 } },
        { lv = 40 , it = { townportaltalisman = 20 } },
        { lv = 60 , it = { slurtle_shellpieces = 20, cookiecuttershell = 20 } },
        { lv = 80 , it = { thulecite = 50 } },
        { lv = 100, it = { steelwool = 20, dragon_scales = 50, armorskeleton = 100, armorsnurtleshell = 100 } }
    },


    ENHANCE_CLOTHES_ITEMS = {
        
    }

}