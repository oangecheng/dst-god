
UGCOFIG = {
    CH  = true,
    LOG = true,
    TEST = true,
}


UGENTITY_TYPE = {
    POWER = 1,
    TASK = 2,
}


UGTAGS = {
    LEVEL = "uglevel"
}


UGEVENTS = {
    POWER_UPDATE = "ugpower_update",
    HARVEST_SELF_FOOD = "ugharvest_self_food",
    HARVEST_DRY = "ugharvest_dry",
    PICK_STH = "ugpick_something",
    FISH_SUCCESS = "ugfish_success",
}


local player = "ugplayer_"
local equips = "ugequips_" 
UGPOWERS = {
    PLAYER = {
        HUNGER = player.."hunger",
        HEALTH = player.."health",
        SANITY = player.."sanity",
        COOKER = player.."cooker",
        DRYERR = player.."dryerr" ,
        PICKER = player.."picker",
        FARMER = player.."farmer",
        FISHER = player.."fisher",
        RUNNER = player.."runner",
    },

    EQUIPS = {
        --- 攻击类型
        VAMPIR = equips.."vampir",
        SPLASH = equips.."splash",
        CRITER = equips.."criter",
        BLINDR = equips.."blindr",
        POISON = equips.."poison",
        ---被攻击类型
        DODGER = equips.."dodger",

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


UGMARK = {
    COOK_MULTI = "cook_multi",
    DRY_MULTI  = "dry_multi" ,
    FISH_MULTI = "fish_multi",
    ATK_MISS   = "atk_miss",
}
