---@diagnostic disable: undefined-field
local isch = UGCOFIG.CH

local IDS = {
    REPAIR  = "UGREPAIR",
    INLAY   = "UGINLAY",
    ENHANCE = "UGENHANCE", 
    DRINK   = "UGDRINK",
    ACTIVE  = "UGACTIVE",
    SWICTH  = "UGSWITCH",
    MAGIC   = "UGMAGIC",
}


STRINGS.ACTIONS[IDS.MAGIC] = {
    GENERIC = isch and "升级" or "Upgrade",
    PLANT   = isch and "生机焕发" or "NewLife"
}



--移除预制物(预制物,数量)
local function removeItem(item, num)
	if item.components.stackable then
		item.components.stackable:Get(num):Remove()
	else
		item:Remove()
	end
end




local actions = {
    {
        id  = IDS.REPAIR,
        str = isch and "修理" or "Repair",
        state = "give",
        fn  = function (act)
            local repair = act.target and act.target.ugrepairfn
            if act.doer and repair and act.invobject then
                if repair(act.target, act.invobject, act.doer) then
                    removeItem(act.invobject)
                    return true
                end
            end
            return false
        end,
        actiondata = {
            priority = 10,
        } 
    }, 
    {
        id  = IDS.INLAY,
        str = isch and "镶嵌" or "Inlay",
        state = "dolongaction",
        fn = function (act)
            local sys = act.target and act.target.components.ugsystem
            if sys and act.target and act.target.ugload_gem then
                if act.target.ugload_gem(act.doer, act.target, act.invobject) then
                   removeItem(act.invobject)
                   return true
                end 
            end
            return false
        end
    },

    {
        id  = IDS.ENHANCE,
        str = isch and "强化" or "Enhance",
        state = "dolongaction",
        fn = function (act)
            if act.invobject and act.target and act.target.enhancefn then
                if act.target.enhancefn(act.invobject) then
                    act.invobject:Remove()
                    return true
                end
            end
            return false
        end
    },

    {
        id    = IDS.DRINK,
        str   = isch and "服下" or "Drink",
        state = "dolongaction",
        fn    = function(act)
            if act.doer and act.invobject and act.invobject.drinkfn then
                if act.invobject.drinkfn(act.doer) then
                    removeItem(act.invobject)
                    return true
                end
            end
            return false
        end
    },
    {
        id    = IDS.ACTIVE,
        str   = isch and "激活" or "Activate",
        state = "dolongaction",
        fn    = function(act)
            if act.doer and act.target and act.target.ugactivefn then
                if act.target.ugactivefn(act.doer, {}) then
                    removeItem(act.invobject)
                    return true
                end
            end
            return false
        end,
        actiondata = {
            priority = 10,
        } 
    },
    {
        id    = IDS.SWICTH,
        str   = isch and "切换" or "Switch",
        state = "dolongaction",
        fn    = function(act)
            if act.doer and act.target and act.target.ugactivefn then
                if act.target.ugswitchfn(act.doer, act.invobject) then
                    removeItem(act.invobject)
                    return true
                end
            end
            return false
        end,
        actiondata = {
            priority = 10,
        } 
    },

    {
        id    = IDS.MAGIC,
        str   = STRINGS.ACTIONS[IDS.MAGIC],
        state = "dolongaction", 
        fn    = function(act)
            if act.doer and act.invobject and act.invobject.GiveToFn then
                if act.invobject.GiveToFn(act.invobject, act.target, act.doer) then
                    removeItem(act.invobject)
                    return true
                end
            end
            return false
        end,
        actiondata = {
            strfn = function (act)
                if act.invobject and act.invobject.prefab == "ugmagic_plant_energy" then
                    return "PLANT"
                end
                return "GENERIC"
            end,
        }
    },
}




local component_actions = {
    {
        type = "USEITEM",
        component = "inventoryitem",
        tests = {
            {
                action = IDS.REPAIR,
                testfn = function (inst, doer, target, acts, right)
                    return inst.prefab == "goldnugget" and target:HasTag(UGTAGS.REPAIR)
                end
            },
            {
                action = IDS.INLAY,
                testfn = function (inst, doer, target, acts, right)
                    return inst:HasTag(UGTAGS.GEM)
                end
            },
            {
                action = IDS.ENHANCE,
                testfn = function (inst, doer, target, acts, right)
                    return target:HasTag(UGTAGS.GEM)
                end
            },
            {
                action = IDS.ACTIVE,
                testfn = function (inst, doer, target, acts, right)
                    return target:HasTag(UGTAGS.ACTIVE) and inst.prefab == "purplegem"
                end
            },
            {
                action = IDS.SWICTH,
                testfn = function (inst, doer, target, acts, right)
                    return target:HasTag(UGTAGS.SWICTH)
                end
            },
            {
                action = IDS.MAGIC,
                testfn = function (inst, doer, target, acts, right)
                    return inst:HasTag(UGTAGS.MAGIC_ITEM) and target:HasTag(UGTAGS.MAGIC_TARGET)
                end
            },
        }
    },

    {
        type = "INVENTORY",
        component = "inventoryitem",
        tests = {
            {
                action = IDS.DRINK,
                testfn = function(inst, doer, actions, right)
                    return inst:HasTag(UGTAGS.POTION)
                end
            },
        }
    }

}



local old_actions = {}





return {
	actions = actions,
	component_actions = component_actions,
	old_actions = old_actions,
}