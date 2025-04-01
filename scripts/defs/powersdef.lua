
-- local FN_ATTACH = "attach"
-- local FN_DETACH = "detach"
-- local FN_UPDATE = "update"
-- local FN_SAVE   = "save"
-- local FN_LOAD   = "load"

---阶段等级为 100/n， 5阶段就是每20级提升一个等阶
---经验需求为 20 * 100 = 2000

local PLAYER = UGPOWERS.PLAYER



local function init_hunger_data ()

    local items = {
        { dragonpie = 50 }, { turkeydinner = 40 }, { fishtacos = 25 }, { waffles = 50 },{ lobsterdinner = 80 }
    }

    local buffers = {
        buff_attack = { w = 3 },
        buff_playerabsorption = { w = 3 },
        buff_workeffectiveness = { w = 3 },
        buff_electricattack = { w = 1 }
    }

    local common_fns = {
        {
            lv = 0,
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

        {
            lv = 20,
            fn = function (inst, owner, lv)
                local com_workmultiplier = owner.components.workmultiplier
                if com_workmultiplier ~= nil then
                    local multiplier = math.min(0.001 * lv, 1) + 1
                    com_workmultiplier:AddMultiplier(ACTIONS.CHOP,   multiplier, inst)
                    com_workmultiplier:AddMultiplier(ACTIONS.MINE,   multiplier, inst)
                    com_workmultiplier:AddMultiplier(ACTIONS.HAMMER, multiplier, inst)
                end
            end
        },

        {
            lv = 40, 
            fn =  function (inst, owner, lv)
                
            end
        },

        {
            lv = 60, 
            fn = function (inst, owner, lv)
                local m = math.min(0.001 * lv, 0.5) + 1
                PutUgData(owner, "eat_food_hunger_multi", m)
            end
        },

        {
            lv = 80,
            fn = function (inst, owner, lv)
                local ratio = math.min(0.0025 * lv, 0.25)
                PutUgData(owner, "eat_food_give_buff", ratio)
            end
        }
    }


    local function god_fn(inst, owner, lv)
        AddUgTag(owner, "cooker_god", PLAYER.HUNGER)
    end


    local function on_eat(eater, data)
        local edible = data.food and data.food.components.edible
        local lv = GetUgPowerLv(eater, PLAYER.HUNGER)
        if edible ~= nil and lv ~= nil then
            local step = lv * 0.05 + 1
            local exp = 0
            if step > 5 then
                exp = 0.4 * edible.hungervalue + edible.healthvalue * 0.6 + edible.sanityvalue * 1
            elseif step > 0 then
                local item = items[step]
                if item ~= nil then
                    exp = item[data.food.prefab] or 0
                end
            end
            GainUgPowerXp(eater, PLAYER.HUNGER, exp)

            local r = GetUgData(eater, "eat_food_give_buff", 0)
            if r > 0 then
                if math.random() < r then
                    local buff = GetUgRandomItem(buffers)
                    if buff ~= nil then
                        eater:AddDebuff(buff, buff)
                    end
                end
            end
        end
    end


    local function on_update(inst, owner, name, lv)
        local step = lv * 0.05 + 1
        if step > 5 then
            god_fn(inst, owner, lv)
        end
        for i = 1, step do
            local fn = common_fns[i]
            if fn ~= nil then
                fn(inst, owner, lv)
            end
        end
    end


    return {
        attach = function (inst, owner, name)
            owner:ListenForEvent("oneat", on_eat)
            inst.origin_max_hunger = owner.components.hunger.max
            inst.components.uglevel.expfn = function ()
                return 100
            end
            if inst.percent then
                owner.components.hunger:SetPercent(inst.percent)
            end
        end,

        detach = function (inst, owner, name)
            owner:RemoveEventCallback("oneat", on_eat)
        end,

        update = function (inst, owner, name)
            local lv = GetUgPowerLv(owner, name) or 0
            on_update(inst, owner, name, lv)
        end,

        save = function (inst, data)
            data.percent = inst.owner and inst.owner.components.hunger:GetPercent()
        end,

        load = function (inst, data)
            inst.percent = data.percent or nil
        end
    }
end




local UGPOWERS = {

    [PLAYER.HUNGER] = init_hunger_data()


}










return UGPOWERS