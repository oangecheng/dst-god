

local hunger = {
    onbind = function (inst, owner)
        KsgLog("hunger bind")
    end,

    onrefresh = function (inst)
        KsgLog("hunger refresh")
    end,

    onunbind = function (inst, owner)
        KsgLog("hunger unbind")
    end,
}


return {
    [KSG_POWERS.USER.HUNGER] = hunger
}