
UGCOFIG = {
    CH  = true,
    LOG = true,
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
UGPOWERS = {
    PLAYER = {
        HUNGER = player.."hunger",
        HEALTH = player.."health",
        SANITY = player.."sanity",
        COOKER = player.."cooker",
        DRYER  = player.."dryer" ,
        PICKER = player.."picker",
        FARMER = player.."farmer",
        FISHER = player.."fisher",
        RUNNER = player.."runner",
    },
}


UGDATA_KEY = {
    COOK_MULTI = "cook_multi",
    DRY_MULTI  = "dry_multi" ,
    FISH_MULTI = "fish_multi",
}

