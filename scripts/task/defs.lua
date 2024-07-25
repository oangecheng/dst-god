local STARS = UGTASKS.STARS
local AWARD = UGTASKS.AWARD


local MONSTER = {
    [STARS.D] = {
        rabbit    = { w = 1, num = 6 },
        killerbee = { w = 3, num = 10 },
        spider    = { w = 5, num = 10 },
        frog      = { w = 5, num = 10 },
        hound     = { w = 5, num = 6 },
    },

    [STARS.C] = {
        firehound      = { w = 3, num = 3 },
        icehound       = { w = 3, num = 3 },
        spider_warrior = { w = 5, num = 5 },
        pigman         = { w = 5, num = 5 },
        bunnyman       = { w = 5, num = 5 },
    },

    [STARS.B] = {
        walrus           = { w = 2, num = 1 },
        koalefant_summer = { w = 2, num = 1 },
        koalefant_winter = { w = 2, num = 1 },
        beefalo          = { w = 5, num = 3 },
        lightninggoat    = { w = 5, num = 3 },
        tentacle         = { w = 5, num = 3 },
        tallbird         = { w = 5, num = 2 },
    },

    [STARS.A] = {
        spat        = { w = 2, num = 1 },
        warg        = { w = 2, num = 1 },
        leif_sparse = { w = 3, num = 1 },
        leif        = { w = 5, num = 1 },
        spiderqueen = { w = 3, num = 1 }
    },

    [STARS.S] = {
        minotaur  = { w = 1, num = 1 },
        bearger   = { w = 5, num = 1 },
        dragonfly = { w = 5, num = 1 },
        deerclops = { w = 5, num = 1 },
        moose     = { w = 5, num = 1 },
        antlion   = { w = 5, num = 1 }
    }
}


local function random_monster(star)
    local mon, num = GetUgRandomItem(MONSTER[star])
    if num > 1 then
        local seed = math.floor(num * 0.5)
        num = math.random(seed, num)
    end
    return mon, num
end



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

local NORMAL_ITEMS = {
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
        [townstone]   = { w = 5, num = 8 },
        [colorgem]    = { w = 1, num = 1 },
        opalstaff     = { w = 1, num = 1 },
    }
}


local UGITEMS = {
    uggem_piece = { w = 5, num = 1 }
}

local function reward_fn(star)
    local key = math.min(star or 1, STARS.S)
    local normal_r = NORMAL_ITEMS[key]
    local r1, n1 = GetUgRandomItem(normal_r)
    local r2, n2 = GetUgRandomItem(UGITEMS)
    return {
        {
            type = AWARD.ITEM,
            target = r1,
            num = n1,
        },
        {
            type = AWARD.ITEM,
            target = r2,
            num = n2 ^ star,
        }
    }
end




local FISH_DEF = {
    [STARS.D] = {
        fish = { w = 5, num = 10 }
    },
    [STARS.C] = {
        eel             = { w = 5, num = 10 },
        wobster_sheller = { w = 5, num = 3 },
    },
    [STARS.B] = {
        wobster_moonglass     = { w = 2, num = 2 },
        oceanfish_small_1_inv = { w = 3, num = 1 },
        oceanfish_small_2_inv = { w = 3, num = 1 },
        oceanfish_small_3_inv = { w = 3, num = 1 },
        oceanfish_small_4_inv = { w = 3, num = 1 },
    },
    [STARS.A] = {
        oceanfish_small_5_inv = { w = 5, num = 1 },
        oceanfish_small_6_inv = { w = 5, num = 1 },
        oceanfish_small_7_inv = { w = 5, num = 1 },
        oceanfish_small_8_inv = { w = 5, num = 1 },
        oceanfish_small_9_inv = { w = 5, num = 1 }
    },
    [STARS.S] = {
        oceanfish_medium_1_inv = { w = 5, num = 1 },
        oceanfish_medium_2_inv = { w = 5, num = 1 },
        oceanfish_medium_3_inv = { w = 5, num = 1 },
        oceanfish_medium_4_inv = { w = 5, num = 1 },
        oceanfish_medium_5_inv = { w = 5, num = 1 },
        oceanfish_medium_6_inv = { w = 5, num = 1 },
        oceanfish_medium_7_inv = { w = 5, num = 1 },
        oceanfish_medium_8_inv = { w = 5, num = 1 },
    }
}


local function random_fish(star)
    local fish, num = GetUgRandomItem(FISH_DEF[star])
    return fish, num
end


return {
    monsterfn = random_monster,
    fishfn    = random_fish,
    rewardfn  = reward_fn,
}