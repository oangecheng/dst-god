
-- local FN_ATTACH = "attach"
-- local FN_DETACH = "detach"
-- local FN_UPDATE = "update"
-- local FN_SAVE   = "save"
-- local FN_LOAD   = "load"

---阶段等级为 100/n， 5阶段就是每20级提升一个等阶
---经验需求为 20 * 100 = 2000

local PLAYER = UGPOWERS.PLAYER



local function init_hunger_data()

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
                AddUgTag(owner, "ughunger_master", PLAYER.HUNGER)
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
                v.fn(inst, owner, lv)
            end
        end
    end


    local function attach_fn(inst, owner, name)
        owner.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI })
        owner:ListenForEvent("oneat", on_eat)
        inst.origin_max_hunger = owner.components.hunger.max
        if inst.percent then
            owner.components.hunger:SetPercent(inst.percent)
        end
        inst.components.uglevel.expfn = function ()
            return 100
        end
    end


    return {
        attach = attach_fn,
        detach = nil,
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
    
    local rewards_def = require("defs/rewardsdef").sanity
    
    local common_fns = {
        --- 献祭绳子提升等级
        --- 提升精神值上限
        {
            lv = 0,
            xp = function (item, owner, lv)
                if item.prefab == "rope"  then
                    return 25
                end
            end,
            fn = function (inst, owner, lv)
                local max = inst.org_max_sanity
                local com = owner.components.sanity
                if com ~= nil and max ~= nil then
                    local percent = com:GetPercent()
                    com.max = math.floor(max * (1 + 0.01 * lv) + 0.5)
                    com:SetPercent(percent)
                end
            end
        },

        --- 献祭莎草纸提升等级
        --- 献祭物品获得1-2阶蓝图
        --- 未开启勋章，添加快速制作标签和女工标签
        {
            lv = 25,
            xp = function (item, owner, lv)
                if item.prefab == "papyrus" then
                    return 25
                end
            end,
            fn = function (inst, owner, lv)
                local v = math.min((lv - 25) * 0.08 + 1, 2.1)
                PutUgData(owner, "gain_blue_print", math.floor(v))
                if not IsMedalOpen() then
                    AddUgTag(owner,"handyperson", PLAYER.SANITY)
                    AddUgTag(owner,"fastbuilder", PLAYER.SANITY)
                    owner:PushEvent("refreshcrafting") --更新制作栏
                end 
            end
        },

        --- 献祭羽毛笔升级
        --- 献祭物品获得2-4阶蓝图
        --- 未开启勋章，解锁读书标签
        {
            lv = 50,
            xp = function (item, owner, lv)
                if item.prefab == "featherpencil" then
                    return 25
                end
            end,
            fn = function (inst, owner, lv)
                local v = math.min((lv - 50) * 0.08 + 3, 4.1)
                PutUgData(owner, "gain_blue_print", math.floor(v))
                if not IsMedalOpen() then
                    AddUgTag(owner,"bookbuilder", PLAYER.SANITY)
                    if owner.components.reader == nil then
                        owner:AddComponent("reader")
                    end
                    owner:PushEvent("refreshcrafting") --更新制作栏
                end
            end
        },

        --- 献祭紫宝石升级
        --- 可以使用智慧值兑换物品，等级越高价格越便宜，缓存的是兑换折扣 0 - 1
        {
            lv = 75,
            xp = function (item, owner, lv)
                if item.prefab == "purplegem" then
                    return 50
                end
            end,
            fn = function (inst, owner, lv)
                local r = math.max((0.8 - lv * 0.005), 0.3)
                PutUgData(owner, "item_exchanger", r)
            end
        },

        --- 献祭任何物品都可以升级，2-5
        --- 获得造物能力，概率copy物品
        {
            lv = 100,
            xp = function (item, owner, lv)
                return math.random(2, 5)
            end,
            fn = function (inst, owner, lv)
                local r = math.min((lv - 75) * 0.01, 1)
                PutUgData(owner, "copy_item", r)
                AddUgTag(owner, "ugsanity_master")
            end
        }
    }

    local function update_fn(inst, owner, name)
        local lv = GetUgPowerLv(owner, name) or 0
        for _, v in ipairs(common_fns) do
            if lv >= v.lv and v.fn ~= nil then
                v.fn(inst, owner, lv)
            end
        end
    end


    local function on_sacrificial(doer, data)
        if data.item ~= nil then
            local lv = GetUgPowerLv(doer, PLAYER.SANITY)
            ---@diagnostic disable-next-line: undefined-field
            local common_fns_reverse = table.reverse(common_fns)
            for _, v in ipairs(common_fns_reverse) do
                if lv >= v.lv and v.xp ~= nil then
                    local exp = v.xp(data.item, doer, lv)
                    if exp ~= nil then
                        GainUgPowerXp(doer, PLAYER.SANITY, exp)
                    end
                    break
                end
            end

            local rcplv = GetUgData(doer, "gain_blue_print", 0)
            if rcplv > 0 then
                -- local r = rewards_def[rcplv]
                UgLog("获得蓝图奖励", "等级"..tostring(rcplv))
                -- 给予奖励
            end

        end
    end


    local function give_wisdom_value(player, value)
        local inst = GetUgEntity(player, PLAYER.SANITY)
        local comp = inst and inst.components.ugentity or nil
        if comp ~= nil then
            local v = (comp:GetValue("wisdom_value") or 0) + value
            comp:PutValue("wisdom_value", v)
        end
    end


    local function on_build_item(player)
        give_wisdom_value(math.random(1, 2))
    end
    
    local function on_build_structure(player)
        give_wisdom_value(math.random(2, 4))
    end
    
    local function on_unlock_recipe(player)
        give_wisdom_value(math.random(5, 10))
    end


    local attach_fn = function (inst, owner, name)
        owner:ListenForEvent("ugsacrificial_items", on_sacrificial)
        --- 制作物品获得智慧值
        owner:ListenForEvent("builditem", on_build_item)
        owner:ListenForEvent("buildstructure", on_build_structure)
        owner:ListenForEvent("unlockrecipe", on_unlock_recipe)
        local sanity = owner.components.sanity
        inst.org_max_sanity = sanity and sanity.max or nil
        if inst.percent then
            sanity:SetPercent(inst.percent)
        end
        inst.components.uglevel.expfn = function ()
            return 100
        end
    end

    return {
        attach = attach_fn,
        detach = nil,
        update = update_fn,
        onsave = function (inst, data)
            data.percent = inst.owner and inst.owner.components.sanity:GetPercent()
        end,
        onload = function (inst, data)
            inst.percent = data.percent or nil
        end
    }
end






local function init_health_data()


    local common_fns = {

        ---杀蜘蛛升级
        ---提升血量上限
        {
            lv = 0,
            xp = function (victim, owner, lv)
                if victim.prefab == "spider" then
                    return 25
                end
            end,
            fn = function(inst, owner, lv)
                local max = inst.org_maxhealth
                local com = owner.components.health
                if com ~= nil and max ~= nil then
                    local percent = com:GetPercent()
                    com:SetMaxHealth(math.floor(max * (1 + 0.01 * lv) + 0.5))
                    com:SetPercent(percent)
                end
            end
        },

        ---杀狗升级
        ---提升防御 max = 25%
        ---提升攻击 max = 25%
        {
            lv = 25,
            xp = function (victim, owner, lv)
                if victim.prefab == "hound" then
                    return 25
                end
            end,
            fn = function (inst, owner, lv)
                local mult1 = math.min(lv - 25 * 0.0025, 0.25)
                if owner.components.health ~= nil then
                    owner.components.health.externalabsorbmodifiers:SetModifier(PLAYER.HEALTH, mult1)
                end
                local mult2 = math.min(lv - 25 * 0.0025, 0.25) + 1
                if owner.components.combat ~= nil then
                    owner.components.combat.externaldamagemultipliers:SetModifier(PLAYER.HEALTH, mult2)
                end
            end
        },

        ---杀触手升级
        ---
        {
            lv = 50,
            xp = function (victim, owner, lv)
                if victim.prefab == "tentacle" then
                    return 100
                end
            end,
            fn = function (inst, owner, lv)
                local mult = math.min(lv - 25 * 0.0025, 0.25) + 1
                if owner.components.combat ~= nil then
                    owner.components.combat.externaldamagemultipliers:SetModifier(PLAYER.HEALTH, mult)
                end
            end
        },

        ---杀蜘蛛女王升级
        ---位面伤害&位面防御
        {
            lv = 75,
            xp = function (victim, owner, lv)
                if victim.prefab == "spiderqueen" then
                    return 100
                end
            end,
            fn = function (inst, owner, lv)
                local v = (lv - 75) * 1
            end
        },


        ---杀怪升级
        ---战神属性：僵直抗性
        {
            lv = 100,
            xp = function (victim, owner, lv)
                if victim.prefab == "spiderqueen" then
                    return 100
                end
            end,
            fn = function (inst, owner, lv)
                local v = (lv - 75) * 1
            end
        },

    }


    local function update_fn(inst, owner, name)
        local lv = GetUgPowerLv(owner, name) or 0
        for _, v in ipairs(common_fns) do
            if lv >= v.lv and v.fn ~= nil then
                v.fn(inst)
            end
        end
    end


    local function on_kill_other(killer, data)
        local victim = data.victim
        if victim and victim.components.health and victim.components.freezable then
            local health_value = victim.components.health.maxhealth
            if health_value >= 4000 then
                local inst = GetUgEntity(killer, PLAYER.HEALTH)
                if inst and inst.components.ugentity then
                    local v = inst.components.ugentity:GetValue("boss_killer_value") or 0
                    inst.components.ugentity:PutValue("boss_killer_value", v + math.random(1, 2))
                end
            end

            local lv = GetUgPowerLv(killer, PLAYER.HEALTH)
            ---@diagnostic disable-next-line: undefined-field
            local common_fns_reverse = table.reverse(common_fns)
            for _, v in ipairs(common_fns_reverse) do
                if lv >= v.lv and v.xp ~= nil then
                    local exp = v.xp(victim, killer, lv)
                    if exp ~= nil then
                        GainUgPowerXp(killer, PLAYER.HEALTH, exp)
                    end
                    break
                end
            end

        end
    end

    
    local function attach_fn(inst, owner, name)
        owner:ListenForEvent("killed", on_kill_other)
        local health = owner.components.health
        inst.org_maxhealth = health.maxhealth
        if inst.percent then
            health:SetPercent(inst.percent)
        end
        inst.components.uglevel.expfn = function ()
            return 100
        end
    end

    return {
        attach = attach_fn,
        detach = nil,
        update = update_fn,
        onsave = function (inst, data)
            data.percent = inst.owner and inst.owner.components.health:GetPercent()
        end,
        onload = function (inst, data)
            inst.percent = data.percent or nil
        end
    }
end




local UGPOWERS = {

    [PLAYER.HUNGER] = init_hunger_data(),
    [PLAYER.SANITY] = init_sanity_data(),
    [PLAYER.HEALTH] = init_health_data(),

}










return UGPOWERS