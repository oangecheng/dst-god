
local ch = UGCOFIG.CH

local function register_name(name, chstr, enstr)
    STRINGS.NAMES[string.upper(name)] = ch and chstr or enstr
end

--- 角色
local PLAYER = UGPOWERS.PLAYER
register_name(PLAYER.SANITY, "造物者", "Creator")
register_name(PLAYER.HUNGER, "大胃王", "Eater")
register_name(PLAYER.HEALTH, "狂战士", "Berserker")
register_name(PLAYER.COOKER, "料理王", "Chef")
register_name(PLAYER.DRYERR, "晾晒者", "Dryer")
register_name(PLAYER.PICKER, "采集者", "Picker")
register_name(PLAYER.FARMER, "农场主", "Farmer")
register_name(PLAYER.FISHER, "钓鱼佬", "Fisher")
register_name(PLAYER.RUNNER, "风行者", "Runner")
register_name(PLAYER.DOCTOR, "药剂师", "Pharmacist")
register_name(PLAYER.HUNTER, "狩猎人", "Hunter")


---物品，装备
local EQUIPS = UGPOWERS.EQUIPS
register_name(EQUIPS.CRITER, "暴击", "Crit")
register_name(EQUIPS.DODGER, "闪避", "Dodge")
register_name(EQUIPS.VAMPIR, "吸血", "Vampire")
register_name(EQUIPS.SPLASH, "溅射", "Aoe")
register_name(EQUIPS.BLINDR, "致盲", "Blind")
register_name(EQUIPS.POISON, "毒素", "Posion")
register_name(EQUIPS.THORNS, "荆棘", "Thorns")
register_name(EQUIPS.DAMAGE, "攻击", "ATK")
register_name(EQUIPS.MAXUSE, "耐久", "Durable")
register_name(EQUIPS.WARMER, "恒温", "Insulator")
register_name(EQUIPS.DAPPER, "精神", "Spirit")
register_name(EQUIPS.PROOFR, "雨水", "Rain")
register_name(EQUIPS.CHOPER, "伐木", "Chop")
register_name(EQUIPS.MINING, "矿石", "Mining")
register_name(EQUIPS.SPEEDR, "移速", "Speed")
register_name(EQUIPS.ABSORB, "守护", "Absorb")

for _, v in pairs(EQUIPS) do
    local powername = string.upper(v)
    local name = STRINGS.NAMES[powername]
    register_name(v.."_gem", name.."宝石", name.." Gem")
end


for _, v in pairs(PLAYER) do
    local powername = string.upper(v)
    local name = STRINGS.NAMES[powername]
    register_name(v.."_potion", name.."药剂", name.." Potion")
end