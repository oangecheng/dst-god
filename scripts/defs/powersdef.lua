
-- local FN_ATTACH = "attach"
-- local FN_DETACH = "detach"
-- local FN_UPDATE = "update"
-- local FN_SAVE   = "save"
-- local FN_LOAD   = "load"

---阶段等级为 100/n， 5阶段就是每20级提升一个等阶
---经验需求为 20 * 100 = 2000

local PLAYER = UGPOWERS.PLAYER



local function init_hunger_data ()

    local buffers = {
        buff_attack = { w = 3 },
        buff_playerabsorption = { w = 3 },
        buff_workeffectiveness = { w = 3 },
        buff_electricattack = { w = 1 }
    }

    local common_fns = {

        --- 增加饱食上限
        {
            lv = 0,
            xp = function (owner, food, lv)
                if food.prefab == "turkeydinner" then
                    return 50
                end
            end,
            fn = function (inst, owner, lv)
                local origin_max_hunger = inst.origin_max_hunger
                local com_hunger = owner.components.hunger
                if com_hunger ~= nil and origin_max_hunger ~= nil then
                    local percent = com_hunger:GetPercent()
                    com_hunger.max = math.floor(origin_max_hunger * (1 + 0.01 * lv) + 0.5)
                    com_hunger:SetPercent(percent)
                end
            end
        },

        --- 增加工作效率
        {
            lv = 25,
            xp = function (owner, food, lv)
                if food.prefab == "talleggs" then
                    return 40
                end
            end,
            fn = function (inst, owner, lv)
                local com_workmultiplier = owner.components.workmultiplier
                if com_workmultiplier ~= nil then
                    local multiplier = (lv - 25) * 0.01 + 1
                    com_workmultiplier:AddMultiplier(ACTIONS.CHOP,   multiplier, inst)
                    com_workmultiplier:AddMultiplier(ACTIONS.MINE,   multiplier, inst)
                    com_workmultiplier:AddMultiplier(ACTIONS.HAMMER, multiplier, inst)
                end
            end
        },

        --- 吃东西额外获得饱食度
        {
            lv = 50,
            xp = function (owner, food, lv)
                if food.prefab == "icecream" then
                    return 50
                end
            end,
            fn = function (inst, owner, lv)
                local m = (lv - 50) * 0.01 + 1
                PutUgData(owner, "eat_food_hunger_multi", m)
            end
        },

        --- 吃喜欢的东西概率获得buff
        {
            lv = 75,
            xp = function (owner, food, lv)
                if food.prefab == "jellybean" then
                    return 80
                end
            end,
            fn = function (inst, owner, lv)
                local ratio = math.min(0.01 * (lv - 75), 1)
                PutUgData(owner, "eat_food_give_buff", ratio)
            end
        }, 

        --- 吃任何东西都能升级
        --- 赋予食神称号
        {
            lv = 100,
            xp = function (owner, food, lv)
                local edible = food.components.edible
                if edible ~= nil then
                    return 0.4 * edible.hungervalue + edible.healthvalue * 0.6 + edible.sanityvalue * 1
                end
            end,
            fn = function (inst, owner, lv)
                AddUgTag(owner, "eat_food_master", PLAYER.HUNGER)
            end
        }
    }


    local function on_eat(eater, data)
        local food = data.food
        if food == nil then
            return
        end

        local lv = GetUgPowerLv(eater, PLAYER.HUNGER)
        ---@diagnostic disable-next-line: undefined-field
        local common_fns_reverse = table.reverse(common_fns)
        for _, v in ipairs(common_fns_reverse) do
            if lv >= v.lv and v.xp ~= nil then
                local exp = v.xp(eater, data.food, lv)
                if exp ~= nil then
                    GainUgPowerXp(eater, PLAYER.HUNGER, exp)
                end
                break
            end
        end

        local r = GetUgData(eater, "eat_food_give_buff", 0)
        local food_affinity = eater.components.foodaffinity
        if r > 0 and food_affinity and food_affinity:HasAffinity(data.food) then
            if math.random() < r then
                local buff = GetUgRandomItem(buffers)
                if buff ~= nil then
                    eater:AddDebuff(buff, buff)
                end
            end
        end
    end


    local function update_fn(inst, owner, name)
        local lv = GetUgPowerLv(owner, name) or 0
        for _, v in ipairs(common_fns) do
            if lv >= v.lv and v.fn ~= nil then
                v.fn(inst)
            end
        end
    end


    local function attach_fn(inst, owner, name)
        owner.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
        owner:ListenForEvent("oneat", on_eat)
        inst.origin_max_hunger = owner.components.hunger.max
        inst.components.uglevel.expfn = function ()
            return 100
        end
        if inst.percent then
            owner.components.hunger:SetPercent(inst.percent)
        end
    end

    local function detach_fn(inst, owner, name)
        owner:RemoveEventCallback("oneat", on_eat)
    end


    return {
        attach = attach_fn,
        detach = detach_fn,
        update = update_fn,
        onsave = function (inst, data)
            data.percent = inst.owner and inst.owner.components.hunger:GetPercent()
        end,
        onload = function (inst, data)
            inst.percent = data.percent or nil
        end
    }
end




local function init_sanity_data()
    

    local common_fns = {
        --- 提升精神值上限
        {

        }

    }

end




local UGPOWERS = {

    [PLAYER.HUNGER] = init_hunger_data()


}










return UGPOWERS