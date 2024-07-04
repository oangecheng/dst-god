---@diagnostic disable: undefined-field
local isch = UGCOFIG.CH

local IDS = {
    REPAIR = "UGREPAIR"
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
        str = isch and "修理" and "repair",
        state = "give",
        fn  = function (act)
            local sys = act.target and act.target.components.ugsystem
            if act.doer and sys and act.invobject then
                UgLog("修复测试", act.invobject.prefab)
            end
            return false
        end,
        actiondata = {
            priority = 10,
        } 
    }
}




local component_actions = {
    {
        type = "USEITEM",
        component = "inventoryitem",
        tests = {
            {
                action = IDS.REPAIR,
                testfn = function (inst, doer, target, acts, right)
                    return inst.prefab == "goldnugget"
                end
            }
        }
    }

}



local old_actions = {}





return {
	actions = actions,
	component_actions = component_actions,
	old_actions = old_actions,
}