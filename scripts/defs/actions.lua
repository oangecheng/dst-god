local IDS = STRINGS.ZXACTION_DEF.IDS
local STR_DEFS = STRINGS.ZXACTION_DEF.NAMES



local STATES = {
    S = "give",
    M = "domediumaction",
    L = "dolongaction"
}

local TYPES = {
    TO = 1,
    BY = 2,
}



---生成一个使用物品的动作，把A物品对B目标使用
---@param action_id string id
---@param state string 动作
---@param fn_type number 类型，区分使用函数在哪定义的
---@param ext table|nil 扩展字段
---@return table 动作列表
local function useitem_action_data(action_id, state, fn_type, ext)
    local str = STR_DEFS[action_id]
    return {
        id = action_id,
        str = str,
        state = state,
        actiondata = ext or nil,
        fn = function(act)
            local obj, target, doer = act.invobject, act.target, act.doer
            if obj and target and doer then
                if fn_type == TYPES.TO and obj.GiveToFn ~= nil then
                    return obj.GiveToFn(obj, target, doer)
                end
                if fn_type == TYPES.BY and target.GiveByFn ~= nil then
                    return target.GiveByFn(obj, target, doer)
                end
                return false
            end
        end
    }
end



local function useitem_action_check(action_id, obj_tags, target_tags)
    return {
        action = action_id,
        testfn = function(inst, doer, target, acts, right)
            local ret = true
            if obj_tags ~= nil and next(obj_tags) ~= nil then
                ret = ret and inst:HasTags(obj_tags)
            end
            if target_tags ~= nil and next(target_tags) ~= nil then
                ret = ret and target:HasTags(target_tags)
            end
            return ret
        end
    }
end


---创建一个场景动作
---@param action_id string id
---@param state string 状态
---@param ext table|nil
---@return table
local function scene_action_data(action_id, state, ext)
    local str = STR_DEFS[action_id]
    return {
        id = action_id,
        str = str,
        state = state,
        actiondata = ext or nil,
        fn = function(act)
            local target, doer = act.target, act.doer
            if target and doer then
                if target.OperateFn ~= nil then
                    return target.OperateFn(target, doer)
                end
                return false
            end
        end
    }
end


---校验场景动作
---@param action_id string id
---@param target_tags table|nil 目标的一些标签
---@param _right boolean|nil 是否是右键
---@return table
local function scene_action_check(action_id, target_tags, _right)
    return {
        action = action_id,
        testfn = function(inst, doer, acts, right)
            local ret = true
            if target_tags ~= nil and next(target_tags) ~= nil then
                ret = ret and inst:HasTags(target_tags)
            end
            if _right ~= nil then
                ret = ret and right
            end
            return ret
        end
    }
end



local actions = {

    {
        id    = IDS.USESHOP,
        str   = STR_DEFS[IDS.USESHOP],
        state = STATES.S,
        fn    = function(act)
            act.doer:ShowPopUp(POPUPS.ZXTOOL, true, act.invobject)
            return true
        end,
    },

    {
        id    = IDS.MANAGER,
        str   = STR_DEFS[IDS.MANAGER],
        state = STATES.S,
        fn    = function(act)
            act.doer:ShowPopUp(POPUPS.ZXFARM_SCREEN, true, act.target)
            return true
        end,
    },

    useitem_action_data(IDS.GIVETOR, STATES.S, TYPES.TO),
    useitem_action_data(IDS.BEGIVED, STATES.S, TYPES.BY),
    useitem_action_data(IDS.GIVSOUL, STATES.L, TYPES.BY),
    useitem_action_data(IDS.ADDFOOD, STATES.M, TYPES.BY),
    useitem_action_data(IDS.UPGRADE, STATES.S, TYPES.BY),
    useitem_action_data(IDS.TRANSFR, STATES.S, TYPES.BY),
    useitem_action_data(IDS.PLANTER, STATES.M, TYPES.BY),
    useitem_action_data(IDS.ANIMBAG, STATES.L, TYPES.TO),
    useitem_action_data(IDS.CAPTIVE, STATES.M, TYPES.BY),
    useitem_action_data(IDS.KILFISH, STATES.M, TYPES.TO),
    useitem_action_data(IDS.HATCHER, STATES.S, TYPES.BY),
    useitem_action_data(IDS.FISHING, STATES.L, TYPES.BY),
    useitem_action_data(IDS.PUTFISH, STATES.M, TYPES.BY),

    scene_action_data(IDS.GETFARM, STATES.L),
    scene_action_data(IDS.GETBABY, STATES.M),
}



local componentactions = {
    {
        type = "USEITEM",
        component = "inventoryitem",
        tests = {
            useitem_action_check(IDS.GIVETOR, { "zxgiveable" }, { "xcanbegived" }),
            useitem_action_check(IDS.BEGIVED, nil, { "xbegived" }),
            useitem_action_check(IDS.ADDFOOD, { "zxfood" }, { "ZXFEEDER" }),
            useitem_action_check(IDS.GIVSOUL, { "ZXFARM_SOUL" }, { "ZXHATCHER" }),
            useitem_action_check(IDS.UPGRADE, { ZXTAGS.UP_ITEM }, { ZXTAGS.UP_TARGET }),
            useitem_action_check(IDS.TRANSFR, { ZXTAGS.TRANS }, { ZXTAGS.ANIMAL }),
            useitem_action_check(IDS.PLANTER, nil, { "ZXRACK" }),
            useitem_action_check(IDS.CAPTIVE, nil, { "ZXHOUSE" }),
            useitem_action_check(IDS.ANIMBAG, { "animal_bag" }, { "ZXFARM_HOST" }),
            useitem_action_check(IDS.KILFISH, { "zxfishknife" }),
            useitem_action_check(IDS.HATCHER, { "zxfishegg" }, { "zxfishhatcher" }),
            useitem_action_check(IDS.FISHING, { "zxfishnet" }, { "zxfishpond" }),
            useitem_action_check(IDS.PUTFISH, { "zxfishbaby" }, { "zxfishpond" })
        },
    },

    {
        type = "INVENTORY",
        component = "inventoryitem",
        tests = {
            {
                action = IDS.USESHOP,
                testfn = function(inst, doer, actions, right)
                    return doer ~= nil and inst and inst:HasTag("zxshop")
                end
            },
        }
    },

    {
        type = "SCENE",
        component = "workable",
        tests = {
            scene_action_check(IDS.GETBABY, { "zxhavestable" }),
            scene_action_check(IDS.GETFARM, { "ZXFARM_HOST" }),
            scene_action_check(IDS.MANAGER, { "xfarm_manager" }, true)
        },
    }
}


return {
    actions = actions,
    component_actions = componentactions
}
