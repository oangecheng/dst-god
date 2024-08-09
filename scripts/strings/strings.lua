local ch = UGCOFIG.CH

--- 角色相关
STRINGS.CHARACTER_TITLES.ugfoxgirl = ch and "狐梦璃" or "Cute Fox"
STRINGS.CHARACTER_NAMES.ugfoxgirl = ch and "狐梦璃" or "Cute Fox"
STRINGS.CHARACTER_DESCRIPTIONS.ugfoxgirl = ch and "能够不停的升级" or "Level up"
STRINGS.CHARACTER_QUOTES.ugfoxgirl = ch and "正在到处旅行着" or "happy life"


-- 特殊名称处理
STRINGS.UGNAMES = {
    ["koalefant_summer"]   = STRINGS.NAMES[string.upper("koalefant_summer")].."(夏)",
    ["koalefant_winter"]   = STRINGS.NAMES[string.upper("koalefant_summer")].."(冬)",
    ["leif_sparse"]        = STRINGS.NAMES[string.upper("leif_sparse")].."(常青)",
    ["cactus"]             = STRINGS.NAMES[string.upper("cactus")].."(球形)",
    ["oasis_cactus"]       = STRINGS.NAMES[string.upper("cactus")].."(叶形)",
    ["berrybush2"]         = STRINGS.NAMES[string.upper("berrybush")].."(多叶)", -- 浆果丛2
    ["flower_cave"]        = STRINGS.NAMES[string.upper("flower_cave")].."(1果)",
    ["flower_cave_double"] = STRINGS.NAMES[string.upper("flower_cave")].."(2果)", 
    ["flower_cave_triple"] = STRINGS.NAMES[string.upper("flower_cave")].."(3果)",
    ["pond_cave"]          = STRINGS.NAMES[string.upper("pond")].."(洞穴)",
    ["pond_mos"]           = STRINGS.NAMES[string.upper("pond")].."(蚊子)",
    ["moose"]              = "麋鹿鹅",
    ["gears_blueprint"]    = STRINGS.NAMES[string.upper("gears")].."蓝图",
    ["rock1"]              = STRINGS.NAMES[string.upper("rock1")].."(硝石)",
    ["rock2"]              = STRINGS.NAMES[string.upper("rock2")].."(金矿)",
    ["rock_moon"]          = STRINGS.NAMES[string.upper("rock_moon")].."(月石)",
}


local function register_name(name, chstr, enstr)
    STRINGS.NAMES[string.upper(name)] = ch and chstr or enstr
end

register_name("uggem_piece", "宝石碎片", "Gem Piece")
register_name("ugmagic_plant_energy","植物精华", "Plant Energy")


STRINGS.UGTASK_STRS = {
    DEMAND = ch and "任务要求" or "Task Demand",
    KILL   = ch and "狩猎" or "Kill",
    TARGET = ch and "目标" or "Target",
    NUMBER = ch and "数量" or "Number",
}
