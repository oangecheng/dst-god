


local picklist = {
    ["grass"] = 1,   -- 草
    ["sapling"] = 1,  -- 树枝
    ["flower"] = 1, -- 花
    ["carrot_planted"] = 1, -- 胡萝卜

    ["reeds"] = 1, -- 芦苇
    ["flower_evil"] = 1,  -- 恶魔花

    ["berrybush"] = 2,  -- 浆果丛1
    ["berrybush2"] = 2, -- 浆果丛2
    ["berrybush_juicy"] = 2, -- 多汁浆果

    ["cactus"] = 2,  -- 仙人掌1
    ["oasis_cactus"] = 2, -- 仙人掌2
    ["red_mushroom"] = 2, -- 红蘑菇
    ["green_mushroom"] = 2, -- 绿蘑菇
    ["blue_mushroom"] = 2, -- 蓝蘑菇
    ["cave_fern"] = 1, -- 蕨类植物 
    ["cave_banana_tree"] = 2, -- 洞穴香蕉 
    ["lichen"] = 2,  -- 洞穴苔藓
    ["marsh_bush"] = 2, -- 荆棘丛
    ["flower_cave"] = 2, -- 荧光果
    ["flower_cave_double"] = 2, -- 荧光果2 
    ["flower_cave_triple"] = 2, -- 荧光果3 
    ["sapling_moon"] = 2, -- 月岛树枝
    ["succulent_plant"] = 2, -- 多肉植物
    ["bullkelp_plant"] = 2, -- 公牛海带
    ["wormlight_plant"] = 2, -- 荧光植物
    ["stalker_fern"] = 2, -- 蕨类植物
    ["rock_avocado_bush"] = 2, -- 石果树
    ["oceanvine"] = 2, -- 苔藓藤条
    ["bananabush"] = 2, -- 香蕉丛
}

local extra_picklist = {
    ["stalker_berry"] = 2, -- 神秘植物
    ["stalker_bulb"] = 2, -- 荧光果1，编织者召唤的
    ["stalker_bulb_double"] = 2, -- 荧光果2，编织者召唤的
    ["rosebush"] = 2, -- 棱镜蔷薇花
    ["orchidbush"] = 2, -- 棱镜兰草花
    ["lilybush"] = 2, -- 棱镜蹄莲花
    ["monstrain"] = 2, -- 棱镜雨竹
    ["shyerryflower"] = 2, -- 棱镜颤栗花
    ["mandrake_berry"] = 2, -- 勋章曼德拉果
}



return {
    pick = MergeMaps(picklist, extra_picklist)
}

