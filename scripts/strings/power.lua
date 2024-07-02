
local ch = UGCOFIG.CH
local PLAYER = UGPOWERS.PLAYER

local function register_name(name, chstr, enstr)
    STRINGS.NAMES[string.upper(name)] = ch and chstr or enstr
end


register_name(PLAYER.SANITY, "造物者", "Creator")
register_name(PLAYER.HUNGER, "大胃王", "Eater")
register_name(PLAYER.HEALTH, "狂战士", "Berserker")
register_name(PLAYER.COOKER, "料理王", "Chef")
register_name(PLAYER.DRYER , "晾晒者", "Dryer")
register_name(PLAYER.PICKER, "采集者", "Picker")
register_name(PLAYER.FARMER, "农场主", "Farmer")
register_name(PLAYER.FISHER, "钓鱼佬", "Fisher")
register_name(PLAYER.RUNNER, "风行者", "Runner")