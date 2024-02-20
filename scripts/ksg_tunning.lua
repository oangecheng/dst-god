
KSG_CONF = {
    IS_CH = true,
    LOG = true,
}


KSG_POWERS = {
    USER = {
        HUNGER = "hunger",
        SANITY = "sanity",
        HEALTH = "health",
        PICKER = "picker",
        FARMER = "farmer",
        HUNTER = "hunter",
    },

    ITEM = {
        -- 武器
        DAMAGE = "damage",
        SPEEDR = "speedr" ,
        AOEATK = "aoeatk",
        MAXUSE = "maxuse",
        BLOODR = "bloodr" ,
        -- 工具
        CHOPER = "choper",
        MINEER = "mineer",
        -- 衣服、护甲
        WATERR = "waterr",
        TMPRET = "tmpret",
        DAPNER = "dapner",
        ABSORB = "absorb",
    },

    MONS = {
        HEALTH = "mon_health",
        SPEEDR = "mon_speedr",
        CRTATK = "mon_crtatk",
        DAMAGE = "mon_damage",
        RELATK = "mon_relatk",
        ICEEPL = "mon_iceepl",
        SANAUR = "mon_sanaur",
        ABSORB = "mon_absorb",
        KNOCKR = "mon_konckr",
        STEALR = "mon_stealr",
        BLOODR = "mon_bloodr",
        THORNR = "mon_thornr",
    }
}



KSG_TASKS = {
    TYPE = {
        KILL = "kill",
        PICK = "pick",
        FISH = "fish",
        COOK = "cook",
        MINE = "mine",
        CHOP = "chop",
        DRY  = "dry" ,
    },

    NAME = {
        DAILY  = "daily",
        TRIAL  = "trial",
        BOUNTY = "bounty",
    },

    LIMIT = {
        NONE = "none", 
        TIME = "time",
        MOON = "fullmoon",
        HURT = "nohurt",
        AREA = "area",
    }
}



KSG_TAGS = {
    LEVEL = "KSG_TAG_LEVEL"
}

KSG_EVENTS = {
    POWER_REFRESH = "KSG_POWER_REFRESH",
    TASK_UPDATE   = "KSG_TASK_UPDATE",
    TASK_FINISH   = "KSG_TASK_FINISH" ,
}