
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


local PLAYER_INFO = {}


PLAYER_INFO[PLAYER.SANITY] = {
    name = "造物者",
    recp = "制造万物，增加精神上限",
    desc = "神奇的药剂",
    gain = "制作物品",
    info = function (lv)
        return "精神上限 +"..tostring(lv) .. "%"
    end
}


PLAYER_INFO[PLAYER.HUNGER] = {
    name = "大胃王",
    recp = "尝遍世间美食，增加饱食上限",
    desc = "神奇的药剂",
    gain = "吃东西",
    info = function (lv)
        return "饱食上限 +"..tostring(lv) .. "%"
    end
}


PLAYER_INFO[PLAYER.HEALTH] = {
    name = "狂战士",
    recp = "打遍天下无敌手，增加生命上限",
    desc = "神奇的药剂",
    gain = "制作物品",
    info = function (lv)
        return "生命上限 +"..tostring(lv) .. "%"
    end
}


PLAYER_INFO[PLAYER.COOKER] = {
    name = "小厨神",
    recp = "为食物注入灵魂，提升烹饪的各项能力",
    desc = "神奇的药剂",
    gain = "收获料理",
    info = function (lv)
        local v = math.min(lv * 0.005, 0.5)
        return "烹饪速率 +"..tostring(v * 100) .. "%"
    end
}


PLAYER_INFO[PLAYER.DRYERR] = {
    name = "干货师",
    recp = "干货的风味很独特，提升制备干货的能力",
    desc = "神奇的药剂",
    gain = "收获晾肉架",
    info = function (lv)
        local v = 1 - math.max(1 - lv * 0.01, 0.3)
        return "风干速率 +"..tostring(v * 100) .. "%"
    end
}


PLAYER_INFO[PLAYER.PICKER] = {
    name = "采集者",
    recp = "采集各种植物，提升植物亲和力",
    desc = "神奇的药剂",
    gain = "采集植物",
    info = function (lv)
        local v = math.min(math.floor(lv * 0.05), 5)
        local str1 = "最高额外收获 +"..tostring(v)
        if lv >= 5 then
            str1 = str1.."\n快速采集"
        end
        return str1
    end
}


PLAYER_INFO[PLAYER.FARMER] = {
    name = "农场主",
    recp = "收获各种农作物，提升农作物亲和力",
    desc = "神奇的药剂",
    gain = "收获农作物",
    info = function (lv)
        local v = math.min(math.floor(lv * 0.05), 5)
        return "最高额外收获 +"..tostring(v)
    end
}



PLAYER_INFO[PLAYER.FISHER] = {
    name = "钓鱼佬",
    recp = "没有什么是钓鱼佬钓不到的，提升钓鱼能力",
    desc = "神奇的药剂",
    gain = "钓各种鱼",
    info = function (lv)
        local v = 1 - math.max(1 - lv * 0.01, 0.2)
        return "钓鱼速度 +"..tostring(v * 100) .. "%"
    end
}


PLAYER_INFO[PLAYER.RUNNER] = {
    name = "漫步者",
    recp = "闲逛也能升级，提升跑图能力",
    desc = "神奇的药剂",
    gain = "走路就完事了",
    info = function (lv)
        local v = math.max(lv * 0.0025, 0.25)
        return "移动速度 +"..tostring(v * 100) .. "%"
    end
}


PLAYER_INFO[PLAYER.DOCTOR] = {
    name = "药剂师",
    recp = "药到病除，提升治疗能力",
    desc = "神奇的药剂",
    gain = "使用回血物品",
    info = function (lv)
        return "治疗效率 +"..tostring(lv) .. "%"
    end
}


PLAYER_INFO[PLAYER.HUNTER] = {
    name = "狩猎人",
    recp = "适者生存，提升杀怪能力",
    desc = "神奇的药剂",
    gain = "击杀血量>200的怪物",
    info = function (lv)
        return "治疗效率 +"..tostring(lv) .. "%"
    end
}



local EQUIPS_INFO = {}
local GEMS_DEF = require("defs/uggems_def").items


local function get_equip_item(name)
    local is = GEMS_DEF[name]
    local str = ""
    if is ~= nil then
        for k, v in pairs(is) do
            local prefab_name = STRINGS.NAMES[string.upper(k)]
            str = str.." "..prefab_name.." "
        end
    end
    return str
end


EQUIPS_INFO[EQUIPS.CRITER] = {
    name = "暴击",
    recp = "多倍伤害，恐怖的输出",
    desc = "狂暴的能量",
    info = function (lv)
        local v = math.floor(2 + lv * 0.01)
        return "25%概率造成"..tostring(v) .. "倍伤害"
    end
}


EQUIPS_INFO[EQUIPS.DODGER] = {
    name = "闪避",
    recp = "躲避攻击，保全自己",
    desc = "无休止的躲闪",
    info = function (lv)
        local v = math.min(lv * 0.003, 0.3) * 100
        return tostring(v) .. "%概率躲避一次任意攻击"
    end
}


EQUIPS_INFO[EQUIPS.VAMPIR] = {
    name = "吸血",
    recp = "汲取血液，恢复自身",
    desc = "浓烈的血腥气",
    info = function (lv)
        local v = math.min(math.floor(lv * 0.05 + 1.5), 10)
        return "攻击生命恢复 +"..tostring(v)
    end
}


EQUIPS_INFO[EQUIPS.SPLASH] = {
    name = "溅射",
    recp = "高贵的群伤",
    desc = "难以置信的能力",
    info = function (lv)
        return "造成范围伤害"
    end
}


EQUIPS_INFO[EQUIPS.BLINDR] = {
    name = "致盲",
    recp = "打不着我的怪物一点都不可怕",
    desc = "漆黑的光芒蒙蔽的敌人的眼睛",
    info = function (lv)
        return "概率造成敌人致盲2秒"
    end
}


EQUIPS_INFO[EQUIPS.POISON] = {
    name = "毒素",
    recp = "能让怪物中毒",
    desc = "敌人走不动道了",
    info = function (lv)
        return "概率造成敌人3秒内减速75%"
    end
}


EQUIPS_INFO[EQUIPS.THORNS] = {
    name = "荆棘",
    recp = "快点打我",
    desc = "有点扎手",
    info = function (lv)
        local v =  math.floor( lv * 0.1)
        return "被攻击时反弹" .. tostring(v).."+(0~5)点伤害"
    end
}


EQUIPS_INFO[EQUIPS.DAMAGE] = {
    name = "攻击",
    recp = "提升基础攻击力",
    desc = "真香",
    info = function (lv)
        return "基础攻击 +" .. tostring(lv)
    end
}



EQUIPS_INFO[EQUIPS.MAXUSE] = {
    name = "耐久",
    recp = "物品变得更耐用，也能维修了",
    desc = "质量真好",
    info = function (lv)
        return "增加物品使用次数，\n使用金块维修武器和护甲"
    end
}


EQUIPS_INFO[EQUIPS.WARMER] = {
    name = "保暖",
    recp = "冬暖夏凉，自由切换",
    desc = "有点神奇",
    info = function (lv)
        local v = lv * 10
        return "保暖/隔热 +"..tostring(v)
    end
}


EQUIPS_INFO[EQUIPS.DAPPER] = {
    name = "精神",
    recp = "再也不担心掉san了",
    desc = "查理不见了",
    info = function (lv)
        local v = lv * 10
        return "提升精神回复"
    end
}


EQUIPS_INFO[EQUIPS.PROOFR] = {
    name = "防水",
    recp = "让身体不再潮湿",
    desc = "它喜欢干燥的环境",
    info = function(lv)
        return "防水 +" .. tostring(lv * 100) .. "%"
    end
}


EQUIPS_INFO[EQUIPS.CHOPER] = {
    name = "伐木",
    recp = "武器也能砍树了",
    desc = "真方便",
    info = function(lv)
        return "提升砍树效率"
    end
}



EQUIPS_INFO[EQUIPS.MINING] = {
    name = "挖矿",
    recp = "武器也能挖矿了",
    desc = "真方便",
    info = function(lv)
        return "提升挖矿效率"
    end
}


EQUIPS_INFO[EQUIPS.SPEEDR] = {
    name = "移速",
    recp = "移速是不可多得的属性",
    desc = "天下武功唯快不破",
    info = function(lv)
        return "移速 +" .. tostring(lv) .. "%"
    end
}


EQUIPS_INFO[EQUIPS.ABSORB] = {
    name = "防御",
    recp = "坚不可摧",
    desc = "满满的安全感",
    info = function(lv)
        return "提升伤害减免，不超过90%"
    end
}


for k, v in pairs(EQUIPS_INFO) do
    local gain_str = get_equip_item(k)
    v.gain = "使用 "..gain_str.." 进行升级"
end


STRINGS.UGPOWERS_STR = {}
for k, v in pairs(PLAYER_INFO) do
    STRINGS.UGPOWERS_STR[k] = v
end
for k, v in pairs(EQUIPS_INFO) do
    STRINGS.UGPOWERS_STR[k] = v
end
