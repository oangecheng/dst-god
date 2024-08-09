
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
    UPGRADE       = "ugupgrade",
    ENERGY        = "ugbushenergy",
    ENERGY_TARGET = "ugenergy_target"
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
