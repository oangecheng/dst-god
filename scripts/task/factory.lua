local bush2 = "dug_berrybush2"
local bush3 = "dug_berrybush_juicy"
local bush4 = "bullkelp_root"
local bush5 = "waterplant_planter"
local stone1 = "moonrocknugget"
local goathornkey = "lightninggoathorn"
local armorsanity = "armor_sanity"
local eyeballkey = "deerclops_eyeball"
local townstone = "townportaltalisman"
local colorgem = "opalpreciousgem"


-- 任务的数据结构按照如下定义
-- {
--     type = TYPES.KILL,
--     name = NAMES.DAILY,
--     star = STARS.S
--     time = 0
--     demands = {
--        {
--             type   = KSG_TASKS.TYPE.KILL
--             target = "spider" | nil
--             tag    = "tree" | nil
--             finish = false
--             num    = 1,
--             limit  = 1,
--             extra  = {} | nil
--         }
--     },
--     奖励可能是随机生成的，也可能一开始就给定了
--     rewards = {
--        {
--             type = 1,
--             num  = 1,
--             name = "cutgrass"
--        }
--      }
--     punish = {
--         type = 1
--      }
-- }
local TYPES = UGTASKS.TYPES
local LIMIT = UGTASKS.LIMIT
local NAMES = UGTASKS.NAMES
local AWARD = UGTASKS.AWARD
local STARS = UGTASKS.STARS



local ITEMS = {
    [STARS.D] = {
        cutgrass      = { w = 5, num = 8 },
        twigs         = { w = 5, num = 8 },
        flint         = { w = 5, num = 8 },
        rocks         = { w = 5, num = 8 },
        log           = { w = 5, num = 6 },
        poop          = { w = 5, num = 6 },
        cutreeds      = { w = 5, num = 6 },
        charcoal      = { w = 5, num = 6 },
        spidergland   = { w = 4, num = 4 },
        silk          = { w = 4, num = 4 },
        pigskin       = { w = 4, num = 4 },
        houndstooth   = { w = 4, num = 4 },
        stinger       = { w = 4, num = 4 },
        beefalowool   = { w = 4, num = 4 },
        goldnugget    = { w = 4, num = 4 },
        dug_grass     = { w = 4, num = 4 },
        dug_sapling   = { w = 4, num = 4 },
        dug_berrybush = { w = 3, num = 3 },
        [bush2]       = { w = 3, num = 3 },
        marble        = { w = 3, num = 2 },
        nitre         = { w = 3, num = 2 },
        boneshard     = { w = 3, num = 2 },
    },

    [STARS.C] = {
        livinglog     = { w = 5, num = 3 },
        waxpaper      = { w = 5, num = 3 },
        saltrock      = { w = 5, num = 3 },
        nightmarefuel = { w = 5, num = 3 },
        honeycomb     = { w = 5, num = 2 },
        [stone1]      = { w = 5, num = 3 },
        [bush3]       = { w = 5, num = 2 },
        [bush4]       = { w = 3, num = 2 },
        [bush5]       = { w = 3, num = 2 },
    },

    [STARS.B] = {
        [goathornkey] = { w = 5, num = 2 },
        redgem        = { w = 5, num = 2 },
        bluegem       = { w = 5, num = 2 },
        trunk_summer  = { w = 5, num = 2 },
        trunk_winter  = { w = 5, num = 2 },
        fossil_piece  = { w = 5, num = 2 },
        gears         = { w = 5, num = 3 },
        walrus_tusk   = { w = 5, num = 1 },
        purplegem     = { w = 5, num = 3 },
        thulecite     = { w = 5, num = 2 },
        steelwool     = { w = 5, num = 2 },

    },

    [STARS.A] = {
        slurtlehat    = { w = 5, num = 1 },
        greengem      = { w = 5, num = 1 },
        orangegem     = { w = 5, num = 1 },
        yellowgem     = { w = 5, num = 1 },
        nightsword    = { w = 2, num = 1 },
        [armorsanity] = { w = 2, num = 1 },
        ruins_bat     = { w = 2, num = 1 },
        ruinshat      = { w = 2, num = 1 },
        armorruins    = { w = 2, num = 1 },
        greenstaff    = { w = 1, num = 1 },
        orangestaff   = { w = 1, num = 1 },
        yellowstaff   = { w = 1, num = 1 },
        orangeamulet  = { w = 1, num = 1 },
        yellowamulet  = { w = 1, num = 1 },
        greenamulet   = { w = 1, num = 1 },
    },

    [STARS.S] = {
        [eyeballkey]  = { w = 5, num = 1 },
        dragon_scales = { w = 5, num = 1 },
        minotaurhorn  = { w = 5, num = 1 },
        shroom_skin   = { w = 4, num = 1 },
        shadowheart   = { w = 5, num = 1 },
        hivehat       = { w = 3, num = 1 },
        [townstone]   = { w = 5, num = 6 },
        [colorgem]    = { w = 1, num = 1 },
        opalstaff     = { w = 1, num = 1 },
    }
}


local UGITEMS = {
    uggem_piece = { w = 5, num = 1 }
}


local function create_reward(star)
    local key = math.min(star or 1, STARS.S)
    local r_normals = ITEMS[key]
    local ret1, num1 = GetUgRandomItem(r_normals)
    local ret2, num2 = GetUgRandomItem(UGITEMS)

    return {
        {
            type = AWARD.ITEM,
            target = ret1,
            num = num1,
        },
        {
            type = AWARD.ITEM,
            target = ret2,
            num = num2 * star,
        }
    }
end


local function task_kill(player, name, star)
    return {
        name = NAMES.DAILY,
        rewards = create_reward(star),
        demands = {
            {
                type = TYPES.KILL,
                target = "spider",
                num = 1,
            }
        },
    }
end



local FISH_DEF = {
    "wobster_moonglass",
    "wobster_sheller",
    "eel",
}
local function task_fish(player, name, star)
    return {
        name = NAMES.DAILY,
        type = TYPES.FISH,
        demands = {
            {
                target = "eel",
                limit = LIMIT.MOON,
                num = 1,
            }
        }
    }
end


return {
    taskfn = task_kill
}