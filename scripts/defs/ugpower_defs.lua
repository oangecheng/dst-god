
-- local FN_ATTACH = "attach"
-- local FN_DETACH = "detach"
-- local FN_UPDATE = "update"
-- local FN_SAVE   = "save"
-- local FN_LOAD   = "load"

---阶段等级为 100/n， 5阶段就是每20级提升一个等阶
---经验需求为 20 * 100 = 2000

local PLAYER = UGPOWERS.PLAYER





local function init_hunger_data()

    local NAME = PLAYER.HUNGER

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
            fn = function (inst, owner, lv)
                local m = (lv - 50) * 0.01 + 1
                PutUgData(owner, "eat_food_hunger_multi", m)
            end
        },

        --- 吃喜欢的东西概率获得buff
        {
            lv = 75,
            fn = function (inst, owner, lv)
                local ratio = math.min(0.01 * (lv - 75), 1)
                PutUgData(owner, "eat_food_give_buff", ratio)
            end
        }, 

        --- 吃任何东西都能升级
        --- 赋予食神称号
        {
            lv = 100,
            fn = function (inst, owner, lv)
                AddUgTag(owner, "ughunger_master", NAME)
            end
        }
    }

    local function food_xp(food)
        local edible = food.components.edible
        if edible ~= nil then
            return 0.4 * edible.hungervalue + edible.healthvalue * 0.6 + edible.sanityvalue * 1
        end
    end


    local function on_eat(eater, data)
        local food = data.food
        if food == nil then
            return
        end

        --- 记录种类和击杀次数
        local power = GetUgEntity(eater, NAME)
        local entity = power and power.components.ugentity or nil
        if entity ~= nil and power ~= nil then
            local foods_data = entity:GetValue("foods_data") or {}
            local value = foods_data[food.prefab] or 0

            -- 吃新食物，累计经验值
            local xp = 0
            if value == 0 then
                xp = 100
            else
                if power.components.uglevel:GetLv() >= 100 then
                    xp = food_xp(food)
                end
            end
            if xp > 0 then
                GainUgPowerXp(eater, NAME, xp)
            end

            foods_data[food.prefab] = value + 1
            entity:PutValue("foods_data", foods_data)
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
    
    local NAME = PLAYER.SANITY
    local rewards_def = require("defs/rewardsdef").sanity
    
    local common_fns = {
        --- 提升精神值上限
        {
            lv = 0,
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

        --- 物品获得1-2阶蓝图
        --- 未开启勋章，添加快速制作标签和女工标签
        {
            lv = 25,
            fn = function (inst, owner, lv)
                local v = math.min((lv - 25) * 0.08 + 1, 2.1)
                PutUgData(owner, "gain_blue_print", math.floor(v))
                if not IsMedalOpen() then
                    AddUgTag(owner,"handyperson", NAME)
                    AddUgTag(owner,"fastbuilder", NAME)
                    owner:PushEvent("refreshcrafting") --更新制作栏
                end 
            end
        },

        --- 物品获得2-4阶蓝图
        --- 未开启勋章，解锁读书标签
        {
            lv = 50,
            fn = function (inst, owner, lv)
                local v = math.min((lv - 50) * 0.08 + 3, 4.1)
                PutUgData(owner, "gain_blue_print", math.floor(v))
                if not IsMedalOpen() then
                    AddUgTag(owner,"bookbuilder", NAME)
                    if owner.components.reader == nil then
                        owner:AddComponent("reader")
                    end
                    owner:PushEvent("refreshcrafting") --更新制作栏
                end
            end
        },

        --- 可以使用智慧值兑换物品，等级越高价格越便宜，缓存的是兑换折扣 0 - 1
        {
            lv = 75,
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
                AddUgTag(owner, "ugsanity_master", NAME)
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



    local function record_build_item(doer, item, exp)
        --- 记录种类和制作次数
        local power = GetUgEntity(doer, NAME)
        local entity = power and power.components.ugentity or nil
        if entity ~= nil and power ~= nil then
            local items_data = entity:GetValue("items_data") or {}
            local value = items_data[item.prefab] or 0

            -- 制作物品，累计经验值
            local xp = 0
            if value == 0 then
                xp = exp
            else
                if power.components.uglevel:GetLv() >= 100 then
                    xp = math.random(1, 2)
                end
            end
            if xp > 0 then
                GainUgPowerXp(doer, NAME, xp)
            end

            items_data[item.prefab] = value + 1
            entity:PutValue("items_data", items_data)
        end
    end


    local function random_give_blueprint(doer)
        local rcplv = GetUgData(doer, "gain_blue_print", 0)
        if rcplv > 0 then
            -- local r = rewards_def[rcplv]
            UgLog("获得蓝图奖励", "等级" .. tostring(rcplv))
            -- 给予奖励
        end
    end


    local function on_build_item(player, data)
        record_build_item(player, data.item, 50)
    end
    
    local function on_build_structure(player, data)
        record_build_item(player, data.item, 100)
    end



    local attach_fn = function (inst, owner, name)
        --- 制作物品获得智慧值
        owner:ListenForEvent("builditem", on_build_item)
        owner:ListenForEvent("buildstructure", on_build_structure)
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

    local NAME = PLAYER.HEALTH

    local common_fns = {

        ---提升血量上限
        {
            lv = 0,
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

        ---提升防御 max = 25%
        ---提升攻击 max = 25%
        {
            lv = 25,
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

        ---所有回血效果增强
        {
            lv = 50,
            fn = function (inst, owner, lv)
                local v = math.min((lv - 50) * 0.005, 0.5) + 1
                PutUgData(owner, "health_delta", v)
            end
        },

        ---位面伤害&位面防御
        {
            lv = 75,
            fn = function (inst, owner, lv)
                AddUgTag(owner, "player_lunar_aligned", NAME)
                AddUgTag(owner, "player_shadow_aligned", NAME)
                local delta = math.min((lv - 75) * 0.01, 0.2)
                local persist = owner.components.damagetyperesist
                if persist ~= nil then
                    persist:AddResist("shadow_aligned", owner, 1 - delta, NAME)
                    persist:AddResist("lunar_aligned" , owner, 1 - delta, NAME)
                end
                local bouns = owner.components.damagetypebonus
                if bouns ~= nil then
                    bouns:AddBonus("lunar_aligned" , owner, 1 + delta, NAME)
                    bouns:AddBonus("shadow_aligned", owner, 1 + delta, NAME)
                end
            end
        },


        ---杀怪升级
        ---战神属性：僵直抗性
        {
            lv = 100,
            fn = function (inst, owner, lv)
                AddUgTag(owner, "ughealth_master", NAME)
            end
        },

    }


    local function update_fn(inst, owner, name)
        local lv = GetUgPowerLv(owner, name) or 0
        for _, v in ipairs(common_fns) do
            if lv >= v.lv and v.fn ~= nil then
                v.fn(inst, owner, lv)
            end
        end
    end


    local function on_kill_other(killer, data)
        local victim = data.victim
        local power = GetUgEntity(killer, NAME)
        if victim and victim.components.health and victim.components.freezable and power then

            local health_value = victim.components.health.maxhealth
            local entity = power.components.ugentity

            local killed_data = entity:GetValue("killed_data") or {}
            local value = killed_data[victim.prefab] or 0
            killed_data[victim.prefab] = value + 1
            entity:PutValue("killed_data", killed_data)

            -- 制作物品，累计经验值
            local xp = 0
            if value == 0 then
                xp = math.random(40, 60)
            else
                if power.components.uglevel:GetLv() >= 100 then
                    xp = math.min(health_value * 0.01, 100)
                end
            end
            if xp > 0 then
                GainUgPowerXp(killer, NAME, xp)
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




local function init_cooker_data()

    local NAME = PLAYER.COOKER


    local common_fns = {

        --- 升级：青蛙三明治
        --- 提升烹饪速度
        {
            lv = 0,
            xp = function (prefab, owner, lv)
                if prefab == "frogglebunwich" then
                    return 25
                end
            end,
            fn = function (inst, owner, lv)
                local v = math.max(1 - lv * 0.02, 0.25)
                PutUgData(owner, "cook_time_mult", v)
            end
        },

        --- 升级：鱼肉玉米卷
        --- 晾肉加速
        --- 获得升级晾肉架的能力
        {
            lv = 25,
            xp = function (prefab, owner, lv)
                if prefab == "fishtacos" then
                    return 25
                end
            end,
            fn = function (inst, owner, lv)
                local v = math.max(1 - (lv - 25) * 0.01, 0.75)
                PutUgData(owner, "dry_time_mult", v)
                if not IsMedalOpen() then
                    AddUgTag(owner,"masterchef", NAME) --大厨标签
                    AddUgTag(owner,"professionalchef", NAME) --调料站
                    AddUgTag(owner,"expertchef", NAME)--熟练烹饪标签
                end
            end
        },

        --- 升级：花沙拉
        --- 获得一些特殊能力 升级晾肉架、手搓丸子
        {
            lv = 50,
            xp = function (prefab, owner, lv)
                if prefab == "flowersalad" then
                    return 25
                end
            end,
            fn = function (inst, owner, lv)
                AddUgTag(owner, "cook_item_maker",NAME)
                AddUgTag(owner, "ugfood_maker_normal", NAME)
                owner:PushEvent("refreshcrafting")
            end
        },

        --- 升级：鳄梨酱
        --- 解锁各种特殊食物配方，提升各项能力
        {
            lv = 75,
            xp = function (prefab, owner, lv)
                if prefab == "guacamole" then
                    return 25
                end
            end,
            fn = function (inst, owner, lv)
                AddUgTag(owner, "ugfood_maker_special", NAME)
            end
        },

        --- 升级：制作并收获
        --- 能制作传说中的厨具
        {
            lv = 100,
            xp = function (prefab, owner, lv)
                return math.random(1, 3)
            end,
            fn = function (inst, owner, lv)
                AddUgTag(owner, "ugcook_master", NAME)
            end
        }
    }


    local function on_harvest_food(owner, data)
        local lv = GetUgPowerLv(owner, NAME)
        ---@diagnostic disable-next-line: undefined-field
        local common_fns_reverse = table.reverse(common_fns)
        for _, v in ipairs(common_fns_reverse) do
            if lv >= v.lv and v.xp ~= nil then
                local exp = v.xp(data.food, owner, lv)
                if exp ~= nil then
                    GainUgPowerXp(owner, NAME, exp)
                end
                break
            end
        end
    end

    
    local function attach_fn(inst, owner, name)
        owner:ListenForEvent(UGEVENTS.HARVEST_SELF_FOOD, on_harvest_food)
        inst.components.uglevel.expfn = function ()
            return 100
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


    return {
        attach = attach_fn,
        update = update_fn,
    }
end





local function init_picker_data()

    local NAME = PLAYER.PICKER

    local PICKABLE_DEFS = {
        grass = 1,   -- 草
        sapling = 1,  -- 树枝
        flower = 1, -- 花
        carrot_planted = 1, -- 胡萝卜
        reeds = 1, -- 芦苇
        flower_evil = 1,  -- 恶魔花
        berrybush = 2,  -- 浆果丛1
        berrybush2 = 2, -- 浆果丛2
        berrybush_juicy = 2, -- 多汁浆果
        cactus = 2,  -- 仙人掌1
        oasis_cactus = 2, -- 仙人掌2
        red_mushroom = 2, -- 红蘑菇
        green_mushroom = 2, -- 绿蘑菇
        blue_mushroom = 2, -- 蓝蘑菇
        cave_fern = 1, -- 蕨类植物 
        cave_banana_tree = 2, -- 洞穴香蕉 
        lichen = 2,  -- 洞穴苔藓
        marsh_bush = 2, -- 荆棘丛
        flower_cave = 2, -- 荧光果
        flower_cave_double = 2, -- 荧光果2 
        flower_cave_triple = 2, -- 荧光果3 
        sapling_moon = 2, -- 月岛树枝
        succulent_plant = 2, -- 多肉植物
        bullkelp_plant = 2, -- 公牛海带
        wormlight_plant = 2, -- 荧光植物
        stalker_fern = 2, -- 蕨类植物
        rock_avocado_bush = 2, -- 石果树
        oceanvine = 2, -- 苔藓藤条
        bananabush = 2, -- 香蕉丛
        monkeytail = 2, -- 猴尾草
        ancienttree_nightvision = 10, --夜莓

        stalker_berry = 2, -- 神秘植物
        stalker_bulb = 2, -- 荧光果1，编织者召唤的
        stalker_bulb_double = 2, -- 荧光果2，编织者召唤的
        rosebush = 2, -- 棱镜蔷薇花
        orchidbush = 2, -- 棱镜兰草花
        lilybush = 2, -- 棱镜蹄莲花
        monstrain = 2, -- 棱镜雨竹
        shyerryflower = 2, -- 棱镜颤栗花
        mandrake_berry = 2, -- 勋章曼德拉果
        medal_fruit_tree_carrot = 2, -- 勋章胡萝卜树
        medal_fruit_tree_pomegranate = 2, --勋章石榴树
        medal_fruit_tree_pepper = 2, --辣椒
        medal_fruit_tree_garlic = 2, --大蒜
        medal_fruit_tree_dragonfruit= 2, -- 火龙果
        medal_fruit_tree_banana = 2,
        medal_fruit_tree_asparagus = 2,
        medal_fruit_tree_potato = 2,
        medal_fruit_tree_onion = 2,
        medal_fruit_tree_tomato = 2,
        medal_fruit_tree_watermelon = 2,
        medal_fruit_tree_pumpkin = 2,
        medal_fruit_tree_eggplant = 2,
        medal_fruit_tree_corn = 2,
        medal_fruit_tree_durian = 2,
        medal_fruit_tree_immortal_fruit = 2,
        medal_fruit_tree_lucky_fruit = 2,
    }

    local MAX = 5
    local function calc_extra_num(powerlv)
        local lv = math.min(math.floor(powerlv * 0.04) + 1, MAX)
        local r = math.random(2 ^ MAX)
        for i = lv, 1, -1 do
            local ratio = 32 / (2 ^ i)
            if r <= ratio then
                return i
            end
        end
        return 0
    end


    local common_fns = {

        {
            lv = 0,
            xp = function (target, owner, lv)
                if target.prefab == "grass" or target.prefab == "sapling" then
                    return 5
                end
            end,
            fn = function (inst, owner, lv)
            end
        },

        {
            lv = 25,
            xp = function (target, owner, lv)
                if target.prefab == "berrybush" or target.prefab == "berrybush2" then
                    return 10
                elseif target.prefab == "berrybush_juicy" then
                    return 20
                end
            end,
            fn = function (inst, owner, lv)
                AddUgTag(owner, "fastpicker", NAME)
            end
        },

        {
            lv = 50,
            xp = function (target, owner, lv)
                if target.prefab == "cactus" or target.prefab == "oasis_cactus" then
                    return target.has_flower and 30 or 20
                end
            end,
            fn = function (inst, owner, lv)
                AddUgTag(owner, "ugpick_item_maker", NAME)
                owner:PushEvent("refreshcrafting") --更新制作栏
            end
        },

        {
            lv = 75,
            xp = function(target, owner, lv)
                if target.prefab == "oceanvine" then
                    return 25
                elseif target.prefab == "ancienttree_nightvision" then
                    return 50
                end
            end,
            fn = function(inst, owner, lv)
                local r = math.min(lv - 50, 50) * 0.01
                PutUgData(owner, "ugpick_value_ratio", r)
            end
        },

        {
            lv = 100,
            xp = function(target, owner, lv)
                return PICKABLE_DEFS[target.prefab] or 0
            end,
            fn = function(inst, owner, lv)
                AddUgTag(owner, "ugpick_master", NAME)
            end
        }

    }


    local function on_pick_plant(player, data)
        local obj = data and data.object
        if obj == nil or obj:HasTag("farm_plant") then
            return
        end
        local powerlv = GetUgPowerLv(player, NAME)
        if powerlv == nil then
            return
        end
        local loot = data.loot
        if obj.prefab ~= nil and PICKABLE_DEFS[obj.prefab] ~= nil then
            ---@diagnostic disable-next-line: undefined-field
            local common_fns_reverse = table.reverse(common_fns)
            for _, v in ipairs(common_fns_reverse) do
                if powerlv >= v.lv and v.xp ~= nil then
                    local exp = v.xp(obj, player, powerlv)
                    if exp ~= nil then
                        GainUgPowerXp(player, NAME, exp)
                    end
                    break
                end
            end

            ---每次采集概率获得1点植物能量
            if math.random() < GetUgData(player, "ugpick_value_ratio", 0) then
                AddEntityNumber(player, NAME, "ugpick_value", 1)
            end

            local num = calc_extra_num(powerlv)
            if num < 0 then
                return
            end
            -- 处理特殊case，目前支持多汁浆果
            if data.prefab then
                if obj.components.lootdropper then
                    local pt = obj:GetPosition()
                    pt.y = pt.y + (obj.components.pickable.dropheight or 0)
                    for _ = 1, num do
                        obj.components.lootdropper:SpawnLootPrefab(data.prefab, pt)
                    end
                end
            elseif loot then
                --- 单个物品
                if loot.prefab ~= nil then
                    for _ = 1, num do
                        local item = SpawnPrefab(loot.prefab)
                        player.components.inventory:GiveItem(item, nil, player:GetPosition())
                    end
                elseif not IsTableEmpty(loot) then
                    local extraloot = {}
                    local lootdropper = obj.components.lootdropper
                    local dropper = lootdropper:GenerateLoot()
                    if (not IsTableEmpty(dropper)) then
                        for _, prefab in ipairs(dropper) do
                            for i = 1, num do
                                table.insert(extraloot, lootdropper:SpawnLootPrefab(prefab))
                            end
                        end
                        for i, item in ipairs(extraloot) do
                            player.components.inventory:GiveItem(item, nil, player:GetPosition())
                        end
                    end
                end
            end

            -- 仙人掌花单独处理
            if obj.has_flower and (obj.prefab == "cactus" or obj.prefab == "oasis_cactus") then
                local flower = SpawnPrefab("cactus_flower")
                if flower ~= nil then
                    flower.components.stackable:SetStackSize(num)
                    player.components.inventory:GiveItem(flower, nil, player:GetPosition()) 
                end
            end
        end
    end
    
    local function attach_fn(inst, owner, name)
        owner:ListenForEvent("picksomething", on_pick_plant)
        owner:ListenForEvent(UGEVENTS.PICK_STH, on_pick_plant)
        inst.components.uglevel.expfn = function ()
            return 100
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

    return {
        attach = attach_fn,
        update = update_fn
    }
end





local function init_farmer_data()

    local NAME = PLAYER.FARMER


    local common_fns = {
        {
            lv = 0,
            xp = function (plant, owner, lv)
                return plant.is_oversized and 64 or 32
            end,
            fn = function (inst, owner, lv)
            end
        },

        {
            lv = 25,
            xp = function (plant, owner, lv)
                return plant.is_oversized and 32 or 16
            end,
            fn = function (inst, owner, lv)
                PutUgData(owner, "oversized_mult", true)
            end
        },

        {
            lv = 50,
            xp = function (plant, owner, lv)
                return plant.is_oversized and 16 or 8
            end,
            fn = function (inst, owner, lv)
                local m = math.min((lv - 50) * 0.1, 10)
                PutUgData(owner, "deployable_mult", m)
            end
        },

        {
            lv = 75,
            xp = function (plant, owner, lv)
                return plant.is_oversized and 4 or 2
            end,
            fn = function (inst, owner, lv)
                AddUgTag(owner, "ugfarm_item_maker", NAME)
            end
        },

        {
            lv = 100,
            xp = function (plant, owner, lv)
                return plant.is_oversized and 2 or 1
            end,
            fn = function (inst, owner, lv)
                AddUgTag(owner, "ugfarm_master", NAME)
            end
        },
    }

    local MAX = 5
    local function calc_extra_num(powerlv)
        local lv = math.min(math.floor(powerlv * 0.04) + 1, MAX)
        local r = math.random(2 ^ MAX)
        for i = lv, 1, -1 do
            local ratio = 32 / (2 ^ i)
            if r <= ratio then
                return i
            end
        end
        return 0
    end

    local function on_pick_farm_plant(player, data)
        if not (data and data.object and data.object:HasTag("farm_plant"))  then
            return
        end
        local powerlv = GetUgPowerLv(player, NAME)
        if powerlv == nil then
            return
        end

        ---@diagnostic disable-next-line: undefined-field
        local common_fns_reverse = table.reverse(common_fns)
        for _, v in ipairs(common_fns_reverse) do
            if powerlv >= v.lv and v.xp ~= nil then
                local exp = v.xp(data.object, player, powerlv)
                if exp ~= nil then
                    GainUgPowerXp(player, NAME, exp)
                end
                break
            end
        end

        --- 巨大化作物多倍需要条件
        if data.object.is_oversized and not GetUgData(player, "oversized_mult") then
            return
        end

        local dropper = data.object.components.lootdropper
        -- 额外掉落物
        if dropper then
            local num = calc_extra_num(powerlv)
            local loot = dropper:GenerateLoot()
            if num <= 0 or IsTableEmpty(loot) then return end
            local extraloot = {}
            for _, p in ipairs(loot) do
                for i = 1, num do
                    table.insert(extraloot, dropper:SpawnLootPrefab(p))
                end
            end
            -- 给予玩家物品
            for _, item in ipairs(extraloot) do
                player.components.inventory:GiveItem(item, nil, player:GetPosition())
            end 
        end
        
    end
    

    local function attach_fn(inst, owner, name)
        owner:ListenForEvent("picksomething", on_pick_farm_plant)
    end

    local function update_fn(inst, owner, name)
        local lv = GetUgPowerLv(owner, name) or 0
        for _, v in ipairs(common_fns) do
            if lv >= v.lv and v.fn ~= nil then
                v.fn(inst, owner, lv)
            end
        end
    end

    return {
        attach_fn = attach_fn,
        update_fn = update_fn,
    }

end



local function init_hunter_data()

    local NAME = PLAYER.HUNTER

    local common_fns = {
        {
            lv = 0,
            fn = function (inst, owner, lv)
                local r = math.min(lv * 0.02, 0.2)
                PutUgData(owner, "butter_drop_ratio", r)
            end
        }
    }

    local function on_kill_other(player, data)
        local victim = data.victim
        if victim and victim.components.health and victim.components.freezable then
            local lootdropper = victim.components.lootdropper


            if victim.prefab == "butterfly" then
                local r = GetUgData(player, "butter_drop_ratio", 0)
                if lootdropper ~= nil and math.random() < r then
                    lootdropper:SpawnLootPrefab("butter", victim:GetPosition())
                end
            end


            --- 记录种类和击杀次数
            local power = GetUgEntity(player, NAME)
            local entity = power and power.components.ugentity or nil
            if entity ~= nil then
                local victim_data = entity:GetValue("victim") or {}
                local killed_value = victim_data[victim.prefab] or 0

                if lootdropper ~= nil and killed_value > 0 then
                    local lv = entity.components.uglevel:GetLv()
                    local r = (lv * 0.002) * math.max(1, killed_value * 0.05)
                    if math.random() < r then
                        lootdropper:DropLoot()
                    end
                end

                --- 计算新目标，积累经验
                --- 击杀累计杀戮值，提升下次击杀的双倍掉落几率
                local max_health = victim.components.health.maxhealth
                if killed_value == 0 then
                    local exp = max_health >= 4000 and 200 or 100
                    GainUgPowerXp(player, NAME, exp)
                end

                local v = math.max(math.floor(max_health * 0.01), 1)
                victim_data[victim.prefab] = killed_value + v
                entity:PutValue("victim", victim_data)
            end
        end
    end

    local function attach_fn(inst, owner, name)
        owner:ListenForEvent("killed", on_kill_other)
        inst.components.uglevel.expfn = function ()
            return 100
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

    return {
        attach = attach_fn,
        update = update_fn
    }
end



local function init_runner_data()
    local NAME = PLAYER.RUNNER

    local function update_runner(inst, owner, detach)
        local locomotor = owner.components.locomotor
        if locomotor ~= nil then
            if detach then
                locomotor:RemoveExternalSpeedMultiplier(inst, NAME)
            else
                local lv = inst.components.uglevel:GetLv()
                local mult = math.min(1 + lv * 0.0025, 1.25)
                locomotor:SetExternalSpeedMultiplier(inst, NAME, mult)
            end
        end
    end

    return {
        attach = function ()
            
        end,
        update = function (inst, owner)
            update_runner(inst, owner)
        end,
        detach = function (inst, owner)
            update_runner(inst, owner, true)
        end
    }
end




local function init_fisher_data()

    local NAME = PLAYER.FISHER

    local function on_fish(owner, data)
        GainUgPowerXp(owner, NAME, 25)
    end
    
    local function update_fisher(inst, owner)
        local lv = inst.components.uglevel:GetLv()
        local mv = math.max(1 - lv * 0.01, 0.2)
        PutUgData(owner, UGMARK.FISH_MULTI, mv)
    end

    return {
        attach = function (inst, owner, name)
            owner:ListenForEvent("fishcaught", on_fish)
            owner:ListenForEvent(UGEVENTS.FISH_SUCCESS, on_fish)
            inst.components.uglevel.expfn = function ()
                return 100
            end
        end,
        update = function (inst, owner, name)
            update_fisher(inst, owner)
        end
    }
end




local function init_doctor_data()
    
    return {
        attach = function ()
            
        end,
        update = function ()
            
        end
    }
end



local function init_dryyer_data()
    
    return {
        attach = function ()
            
        end,
        update = function ()
            
        end
    }
end





local EQUIPS = UGPOWERS.EQUIPS


local function init_damage_data()

    --- purebrilliance = 5, horrorfuel = 5, 

    local function update_fn(inst, owner, detach)
        local dmg = inst.damage
        if dmg ~= nil then
            local lv = inst.components.uglevel:GetLv()
            local dv = dmg + (detach and 0 or lv)
            owner.components.weapon:SetDamage(dv)
        end
    end
    
    return {
        attach = function (inst, owner, name)
            inst.components.uglevel.expfn = function ()
                return 100
            end
            if owner.components.weapon ~= nil then
                inst.damage = owner.components.weapon.damage
            end
        end,

        update = function (inst, owner, name)
            update_fn(inst, owner)
        end,

        detach = function (inst, owner, name)
            update_fn(inst, owner, true)
        end
    }
end



local function init_criter_data()
    -- 最高暴击倍率
    local MAX = 3
    local function dmg_criter(power, lv, dmg, spdmg, data)
        local m = 1
        if math.random() < 0.25 then
            local seed = lv * 0.01
            m = math.min(math.floor(2 + seed), MAX)
        end
        return dmg * m, spdmg
    end

    return {
        attach = function(inst)
            inst.components.uglevel.expfn = function ()
                return 100
            end
            inst.dmgfn = dmg_criter
        end,
        detach = function(inst)
            inst.dmgfn = nil
        end
    }
end




local function init_splash_data()

    --- aoe需要排除对象的tag
    local splash_exclude = {
        "INLIMBO",
        "companion",
        "wall",
        "abigail",
    }

    -- 判断是否为跟随者，比如雇佣的猪哥
    local function isFollower(inst, target)
        return inst.components.leader ~= nil and inst.components.leader:IsFollower(target)
    end

    -- 初始 50% 范围伤害，满级80%
    -- 初始 1.2 范围， 满级3范围
    local function cacl_splash_data(lv)
        local multi = 0.5 + 0.03 * lv
        local area  = 1.2 + 0.018 * lv
        return multi, area
    end


    local function attack_splash(power, attacker, victim, weapon, lv)
        local multi, area = cacl_splash_data(lv)
        local combat = attacker.components.combat
        local x, y, z = victim.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, area, { "_combat" }, splash_exclude)
        for i, ent in ipairs(ents) do
            if ent ~= victim and ent ~= attacker and combat:IsValidTarget(ent) and (not isFollower(attacker, ent)) then
                attacker:PushEvent("onareaattackother", { target = ent, weapon = weapon, stimuli = nil })
                local damage = combat:CalcDamage(ent, weapon, 1) * multi
                ent.components.combat:GetAttacked(attacker, damage, weapon, nil)
            end
        end
    end

    return {
        attach = function (inst)
            inst.attackfn = attack_splash
            inst.components.uglevel.expfn = function ()
                return 100
            end
        end,
        detach = function (inst)
            inst.attackfn = nil
        end,
    }
end



local function init_vampir_data()

    local NAME = EQUIPS.VAMPIR

    local function can_vampir(victim)
        return victim ~= nil
            and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
                    victim:HasTag("veggie") or
                    victim:HasTag("structure") or
                    victim:HasTag("wall") or
                    victim:HasTag("balloon") or
                    victim:HasTag("groundspike") or
                    victim:HasTag("smashable") or
                    victim:HasTag("abigail") or
                    victim:HasTag("companion"))
            and victim.components.health ~= nil
    end
    
    
    local function attack_vampir(power, attacker, victim, weapon, lv)
        if can_vampir(victim) and attacker.components.health then
            local delta = math.min(math.floor(lv * 0.05 + 1.5), 10)
            attacker.components.health:DoDelta(delta, false, NAME)
        end
    end
    
    
    return {
        attach = function (inst, owner)
            inst.attackfn = attack_vampir
            inst.components.uglevel.expfn = function ()
                return 100
            end
        end,
        detach = function (inst)
            inst.attackfn = nil
        end
    }    
end



local function init_blindr_data()

    local function attack_blindr(power, attacker, victim, weapon, lv)
        -- 概率致盲
        if math.random() < (math.min(0.3, lv * 0.01)) then
            -- 给目标增加致盲标记
            PutUgData(victim, "attack_miss", lv)
            if victim.ugblindtask ~= nil then
                victim.ugblindtask:Cancel()
                victim.ugblindtask = nil
            end
            -- 2s后移除标记
            victim.ugblindtask = victim:DoTaskInTime(2, function ()
                PutUgData(victim, "attack_miss", nil)
            end)
        end
    end
    
    return {
        attach = function (inst)
            inst.attackfn = attack_blindr
            inst.components.uglevel.expfn = function ()
                return 100
            end
        end,
        detach = function (inst)
            inst.attackfn = nil
        end
    }
end




local function init_posion_data()
    
    local NAME = EQUIPS.POISON

    local function attack_poison(power, attacker, victim, weapon, lv)
        if victim.components.locomotor ~= nil then
            -- 最高30%概率减速 25%
            if math.random() < (math.min(0.3, lv * 0.01)) then
                victim.components.locomotor:SetExternalSpeedMultiplier(power, NAME, 0.75)
                if victim.ugpoisontask ~= nil then
                    victim.ugpoisontask:Cancel()
                    victim.ugpoisontask = nil
                end
                -- 3s后移除标记
                victim.ugpoisontask = victim:DoTaskInTime(3, function()
                    victim.components.locomotor:RemoveExternalSpeedMultiplier(power, NAME)
                end)
            end
        end
    end
    
    return {
        attach = function (inst)
            inst.attackfn = attack_poison
            inst.components.uglevel.expfn = function ()
                return 100
            end
        end,
        detach = function (inst)
            inst.attackfn = nil
        end
    }
end



local function init_thorns_data()
    local function atked_thorns(power, attacker, victim, weapon, lv)
        if attacker.components.health ~= nil then
            local dmg = math.floor( math.random(5) + lv * 0.1)
            attacker.components.health:DoDelta(-dmg, nil, nil, true, nil, true)
            attacker:PushEvent("thorns")
        end
    end
    
    return {
        attach = function (inst, owner)
            inst.attackedfn = atked_thorns
            inst.components.uglevel.expfn = function ()
                return 100
            end
        end,
        detach = function (inst, owner)
            inst.attackedfn = nil
        end
    }    
end



local function init_absorb_data()

    local NAME = EQUIPS.ABSORB

    local function update_absorb(inst, owner, detach)
        if inst.org_absorb ~= nil then
            if detach then
                owner.components.armor:SetAbsorption(inst.org_absorb)
            else
                local lv = detach and 0 or inst.components.uglevel:GetLv()
                local mv = math.min(0.7 + lv * 0.02, 0.95)
                owner.components.armor:SetAbsorption(mv)
            end
        end
    end

    return {
        attach = function (inst, owner)
            if owner.components.armor ~= nil then
                inst.org_absorb = owner.components.armor.absorb_percent
            end
            inst.components.uglevel.expfn = function ()
                return 100
            end
        end,
        update = function (inst, owner)
            update_absorb(inst, owner)
        end,
        detach = function (inst, owner)
            update_absorb(inst, owner, true)
        end,
    }
    
end



local function init_dodger_data()
    -- 最高闪避概率
    local DODGER_MAX = 0.3
    local function dmg_dodger(power, lv, dmg, spdmg, data)
        local seed = math.min(lv * 0.003, DODGER_MAX)
        -- 100级以上闪避支持位面伤害
        if math.random() < seed then
            return 0, lv >= 100 and nil or spdmg
        end
        return dmg, spdmg
    end

    return {
        attach = function(inst)
            inst.dmgfn = dmg_dodger
            inst.components.uglevel.expfn = function ()
                return 100
            end
        end,
        detach = function(inst)
            inst.dmgfn = nil
        end
    }
end




local function init_dapper_data()
    local DAPPERNESS_RATIO = TUNING.DAPPERNESS_MED / 3

    local function update_dapper(inst, owner, detach)
        if inst.dapperness ~= nil then
            if detach then
                owner.components.equippable.dapperness = inst.dapperness
            else
                local lv = inst.components.uglevel:GetLv()
                local dv = 3 + DAPPERNESS_RATIO * lv * 0.1
                owner.components.equippable.dapperness = dv
            end
        end
    end

    return {
        update = function(inst, owner)
            update_dapper(inst, owner)
        end,
        detach = function(inst, owner)
            update_dapper(inst, owner, true)
        end,
        attach = function(inst, owner)
            inst.components.uglevel.expfn = function ()
                return 100
            end
            if owner.components.equippable ~= nil then
                inst.dapperness = owner.components.equippable.dapperness
            end
        end
    }
end



local function init_warmer_data()
    
    local NAME = EQUIPS.WARMER

    local function update_warmer(inst, owner, detach)
        local insulator = owner.components.insulator
        if inst.org_insulation ~= nil and inst.org_type ~= nil then

            if detach then
                insulator:SetInsulation(inst.org_insulation)
                insulator.type = inst.org_type
            else

                local lv = inst.components.uglevel:GetLv()
                local iv = 120 + 5 * lv
                insulator:SetInsulation(iv)
                local tp = inst.components.ugentity:GetValue("warmer_type") or inst.org_type
                insulator.type = tp
            end
        end
    end


    local function switch_type_fn(inst, doer, obj)
        local tp_current = inst.components.ugentity:GetValue("warmer_type")
        if tp_current == nil then
            tp_current = inst.org_type
        end

        local ret = false
        if tp_current == SEASONS.WINTER then
            if obj.prefab == "bluegem" then
                inst.components.ugentity:PutValue("warmer_type", SEASONS.SUMMER)
                ret = true
            end
        else
            if obj.prefab == "redgem" then
                inst.components.ugentity:PutValue("warmer_type", SEASONS.SUMMER)
                ret = true
            end
        end

        if ret then
            update_warmer(inst, doer)
        end
        return ret
    end

    return {

        attach = function(inst, owner, name)
            AddUgTag(owner, UGTAGS.SWICTH, NAME)
            AddUgComponent(owner, "insulator", NAME)
            local value, type = owner.components.insulator:GetInsulation()
            -- 缓存原始状态和属性
            inst.org_insulation = value
            inst.org_type = type
            -- 切换函数
            owner.ugswitchfn = function(doer, obj)
                switch_type_fn(inst, doer, obj)
            end
            inst.components.uglevel.expfn = function ()
                return 100
            end
        end,

        detach = function (inst, owner, name)
            update_warmer(inst, owner, true)
            RemoveUgTag(owner, UGTAGS.SWICTH, NAME)
            RemoveUgComponent(owner, "insulator", NAME)
            owner.ugswitchfn = nil
        end,

        update = function (inst, owner, name)
            update_warmer(inst, owner)
        end

    }

end




local function init_proofr_data()

    local NAME = EQUIPS.PROOFR

    local function update_proofr(inst, owner, detach)
        if inst.org_effect ~= nil then
            if detach then
                owner.components.waterproofer:SetEffectiveness(inst.org_effect)
            else
                local lv = detach and 0 or inst.components.uglevel:GetLv()
                local ev = math.min(0.7 + lv * 0.03, 1)
                owner.components.waterproofer:SetEffectiveness(ev)
            end
        end
    end

    return {

        attach = function(inst, owner)
            inst.components.uglevel.expfn = function() return 100 end

            AddUgComponent(owner, "waterproofer", NAME)
            local waterproofer = owner.components.waterproofer
            if GetUgData(waterproofer, NAME) then
                waterproofer:SetEffectiveness(0)
            end
            inst.org_effect = waterproofer:GetEffectiveness()
        end,

        update = function(inst, owner)
            update_proofr(inst, owner, false)
        end,
        detach = function(inst, owner)
            update_proofr(inst, owner, true)
            RemoveUgComponent(owner, "waterproofer", NAME)
        end,
    }
end




local function init_choper_data()
    local chopmax = 15
    local NAME = EQUIPS.CHOPER

    local function update_choper(inst, owner, detach)
        local lv = detach and 0 or inst.components.uglevel:GetLv()
        local mv = math.max(chopmax - lv * 0.15, 1)
        local multi = math.floor(chopmax / mv + 0.5)
        owner.components.tool:SetAction(ACTIONS.CHOP, multi)
        if owner.components.finiteuses ~= nil then
            owner.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)
        end
    end

    return {

        attach = function(inst, owner)
            inst.components.uglevel.expfn = function() return 100 end
            AddUgComponent(owner, "tool", NAME)
        end,

        update = function(inst, owner)
            update_choper(inst, owner)
        end,

        detach = function(inst, owner)
            update_choper(inst, owner, true)
            RemoveUgComponent(owner, "tool", NAME)
        end,
    }
end



local function init_mining_data()
    local minemax = 10
    local NAME = EQUIPS.MINING

    local function update_mining(inst, owner, detach)
        local lv = detach and 0 or inst.components.uglevel:GetLv()
        local mv = math.max(minemax - lv * 0.1, 1)
        local multi = math.floor(minemax / mv + 0.5)
        owner.components.tool:SetAction(ACTIONS.MINE, multi)
        if owner.components.finiteuses ~= nil then
            owner.components.finiteuses:SetConsumption(ACTIONS.MINE, 1)
        end
    end

    return {
        attach = function(inst, owner)
            inst.components.uglevel.expfn = function() return 100 end
            AddUgComponent(owner, "tool", NAME)
        end,

        update = function(inst, owner)
            update_mining(inst, owner)
        end,
        
        detach = function(inst, owner)
            update_mining(inst, owner, true)
            RemoveUgComponent(owner, "tool", NAME)
        end,
    }
end






local function init_speedr_data()

    local function update_speedr(inst, owner, detach)
        if inst.speed ~= nil then
            if detach then
                owner.components.equippable.walkspeedmult = inst.speed
            else
                local lv = inst.components.uglevel:GetLv()
                local mv = 0.05 + lv * 0.01
                owner.components.equippable.walkspeedmult = mv
            end
        end
    end
    
    return {
        attach = function (inst, owner)
            inst.components.uglevel.expfn = function() return 100 end
            if owner.components.equippable ~= nil then
                inst.speed = owner.components.equippable:GetWalkSpeedMult()
            end
        end,
        update = function (inst, owner)
            update_speedr(inst, owner)
        end,
        detach = function (inst, owner)
            update_speedr(inst, owner, true)
        end,
    }
    
end




local function init_maxuse_data() 

    local NAME = EQUIPS.MAXUSE
    local REPAIR_ITEMS = {
        goldnugget = 0.2
    }
    
    
    -- 盔甲消耗的比较快，单独计算，20%以下就自动卸下
    local function repair_percent(inst)
        if inst.components.armor then return 0.2 end
        return 0.05 
    end
    
    
    local function on_percent_changed(inst, data)
        if inst.ugowner and data.percent <= repair_percent(inst) then
            local inventory = inst.ugowner.components.inventory
            if inventory ~= nil then
                local slot = inventory:IsItemEquipped(inst)
                if slot ~= nil then
                    local item = inventory:Unequip(slot)
                    inventory:GiveItem(item)
                end
            end
        end
    end
    
    
    local function on_equip(inst, data)
        inst.ugowner = data.owner
    end
    
    
    local function repair_fn(inst, item, doer)
        local delta = REPAIR_ITEMS[item.prefab]
        if delta == nil then
            return false
        end
        
        -- 武器或者工具
        local finiteuses = inst.components.finiteuses
        if finiteuses ~= nil then
            local percent = math.min(finiteuses:GetPercent() + delta, 1)
            finiteuses:SetPercent(percent)
            return true
        end
        
        -- 盔甲
        local armor = inst.components.armor
        if armor then
            local percent = math.min(armor:GetPercent() + delta, 1)
            armor:SetPercent(percent)
            return true
        end
    
        -- 衣帽使用针线包修复
        return false
    end
    
    
    local function update_maxuse(inst, owner, detach)

        if inst.max == nil then
            return
        end
    
        local lv = detach and 0 or inst.components.uglevel:GetLv()
    
        -- 处理衣帽的数据
        if owner.components.fuled ~= nil then
            local v = inst.max * (lv * 0.25 + 1)
            local percent = owner.components.fuled:GetPercent()
            owner.components.fuled.maxfuel = v
            owner.components.fuled:SetPercent(percent)
            return
        end
    
        -- 处理武器&护甲
        if inst.max ~= nil then
            local mv = math.floor(inst.max * (lv * 0.5 + 1))
            if owner.components.finiteuses ~= nil then
                local pt = owner.components.finiteuses:GetPercent()
                owner.components.finiteuses:SetMaxUses(mv)
                owner.components.finiteuses:SetPercent(pt)
            elseif owner.components.armor ~= nil then
                local pt = owner.components.armor:GetPercent()
                owner.components.armor.maxcondition = mv
                owner.components.armor:SetPercent(pt)
            end
        end
    end


    local function attach_fn(inst, owner)
        -- 衣帽的修理走修理包
        if owner.components.finiteuses ~= nil then
            owner.ugrepairfn = repair_fn
            AddUgTag(owner, UGTAGS.REPAIR, NAME)
            inst.max = owner.components.finiteuses.total
            if inst.percent ~= nil then
                owner.components.finiteuses:SetPercent(inst.percent)
            end
    
        elseif owner.components.armor ~= nil then
            owner.ugrepairfn = repair_fn
            AddUgTag(owner, UGTAGS.REPAIR, NAME)
            inst.max = owner.components.armor.maxcondition
            if inst.percent ~= nil then
                owner.components.armor:SetPercent(inst.percent)
            end
    
        elseif owner.components.fuled ~= nil then
            inst.max = owner.components.fuled.maxfuel
            if inst.percent ~= nil then
                owner.components.fuled:SetPercent(inst.percent)
            end
        end    
    end


    return {

        attach = function (inst, owner, name)
            inst.components.uglevel.expfn = function() return 100 end
            owner:ListenForEvent("percentusedchange", on_percent_changed)
            owner:ListenForEvent("equipped", on_equip)
            attach_fn(inst, owner)
        end,

        update = function(inst, owner)
            update_maxuse(inst, owner)
        end,

        detach = function(inst, owner)
            RemoveUgTag(owner, UGTAGS.REPAIR, NAME)
            update_maxuse(inst, owner, true)
            owner:RemoveEventCallback("percentusedchange", on_percent_changed)
            owner:RemoveEventCallback("equipped", on_equip)
            owner.ugowner = nil
            owner.ugrepairfn = nil
            inst.percent = nil
        end,

        save = function (inst, data)
            if inst.owner ~= nil then
                if inst.owner.components.fuled then
                    data.percent = inst.owner.components.fuled:GetPercent()
                elseif inst.owner.components.finiteuses then
                    data.percent = inst.owner.components.finiteuses:GetPercent()
                elseif inst.owner.components.armor then
                    data.percent = inst.owner.components.armor:GetPercent()
                end
            end
        end,

        load = function (inst, data)
            inst.percent = data.percent
        end
    }
end


return  {
    player = {
        [PLAYER.HUNGER] = init_hunger_data(),
        [PLAYER.SANITY] = init_sanity_data(),
        [PLAYER.HEALTH] = init_health_data(),
        [PLAYER.COOKER] = init_cooker_data(),
        [PLAYER.PICKER] = init_picker_data(),
        [PLAYER.FARMER] = init_farmer_data(),
        [PLAYER.HUNTER] = init_hunter_data(),
        [PLAYER.RUNNER] = init_runner_data(),
        [PLAYER.FISHER] = init_fisher_data(),
        [PLAYER.DOCTOR] = init_doctor_data(),
        [PLAYER.DRYERR] = init_dryyer_data()
    },

    equips = {
        [EQUIPS.DAMAGE] = init_damage_data(),
        [EQUIPS.CRITER] = init_criter_data(),
        [EQUIPS.SPLASH] = init_splash_data(),
        [EQUIPS.VAMPIR] = init_vampir_data(),
        [EQUIPS.BLINDR] = init_blindr_data(),
        [EQUIPS.POISON] = init_posion_data(),
        [EQUIPS.CHOPER] = init_choper_data(),
        [EQUIPS.MINING] = init_mining_data(),

        [EQUIPS.THORNS] = init_thorns_data(),
        [EQUIPS.ABSORB] = init_absorb_data(),
        [EQUIPS.DODGER] = init_dodger_data(),

        [EQUIPS.DAPPER] = init_dapper_data(),
        [EQUIPS.WARMER] = init_warmer_data(),
        [EQUIPS.PROOFR] = init_proofr_data(),

        [EQUIPS.MAXUSE] = init_maxuse_data(),
        [EQUIPS.SPEEDR] = init_speedr_data(),
    }
}