local NAMES     = UGPOWERS.PLAYER
local FN_ATTACH = "attach"
local FN_DETACH = "detach"
local FN_UPDATE = "update"
local FN_SAVE   = "save"
local FN_LOAD   = "load"
local LV_MAX    = 100



--------------------------------------------------------------------------大胃王-----------------------------------------------------------------------------------------------
local function on_eat(eater, data)
    local edible = data.food and data.food.components.edible
    if edible then
        local hungerexp = edible:GetHunger(eater)
        local healthexp = edible:GetHealth(eater)
        local sanityexp = edible:GetSanity(eater)
        local exp = 0.4* hungerexp + healthexp * 0.6 + sanityexp * 1
        GainUgPowerXp(eater, NAMES.HUNGER, exp)
    end
end

---comment 增加饱食度上限
local function update_hunger(inst, owner, detach)
    local maxhunger = inst.maxhunger
    local com = owner.components.hunger
    if com ~= nil and maxhunger ~= nil then
        -- detach 恢复到原来的饱食度
        local lv = detach and 0 or inst.components.uglevel:GetLv()
        local percent = com:GetPercent()
        com.max = math.floor(maxhunger * (1 + 0.01 * lv) + 0.5)
        com:SetPercent(percent)
    end
end


local _hunger = {
    [FN_SAVE] = function (inst, data) data.percent = inst.owner and inst.owner.components.hunger:GetPercent() end,
    [FN_LOAD] = function (inst, data) inst.percent = data.percent or nil end
}

_hunger[FN_ATTACH] = function (inst, owner, name)
    owner:ListenForEvent("oneat", on_eat)
    local com = owner.components.hunger
    inst.maxhunger = com.max
    if inst.percent then
        com:SetPercent(inst.percent)
    end
end

_hunger[FN_DETACH] = function (inst, owner, name)
    owner:RemoveEventCallback("oneat", on_eat)
    update_hunger(inst, owner, true)
end

_hunger[FN_UPDATE] = function (inst, owner, name)
    update_hunger(inst, owner, false)
end






--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------

---@param killer 击杀者 data 受害者数据集
local function on_kill_other(killer, data)
    local victim = data.victim
    if victim and victim:HasTag("monster") and victim.components.health and victim.components.freezable then
        -- 所有经验都是10*lv 因此血量也需要计算为1/10
        local exp = math.max(victim.components.health.maxhealth * 0.1, 1)
        -- 击杀者能够得到满额的经验
        GainUgPowerXp(killer, NAMES.HEALTH, exp)
        -- 非击杀者经验值计算，范围10以内其他玩家
        local x, y, z = victim.Transform:GetWorldPosition()
        local players = TheSim:FindEntities(x, y, z, 10, { "player" })
        if players then
            local players_count = #players
            -- 单人模式经验100%，多人经验获取会减少，最低50%
            local multi = math.max((6 - players_count) * 0.2, 0.5)
            for _, player in ipairs(players) do
                -- 击杀者已经给了经验了
                if player ~= killer then
                    GainUgPowerXp(player, NAMES.HEALTH, exp * multi)
                end
            end
        end
    end
end


---comment 增加血量上限
local function update_health(inst, owner, detach)
    local max = inst.maxhealth
    local com = owner.components.health
    if com ~= nil and max ~= nil then
        -- detach 恢复到原来的饱食度
        local lv = detach and 0 or inst.components.uglevel:GetLv()
        local percent = com:GetPercent()
        com:SetMaxHealth(math.floor(max * (1 + 0.01 * lv) + 0.5))
        com:SetPercent(percent)
    end
end


local _health = {
    [FN_SAVE] = function (inst, data) data.percent = inst.owner and inst.owner.components.health:GetPercent() end,
    [FN_LOAD] = function (inst, data) inst.percent = data.percent or nil end
}

_health[FN_ATTACH] = function(inst, owner, name)
    owner:ListenForEvent("killed", on_kill_other)
    local health = owner.components.health
    inst.maxhealth = health.maxhealth
    if inst.percent then
        health:SetPercent(inst.percent)
    end
end

_health[FN_DETACH] = function (inst, owner, name)
    owner:RemoveEventCallback("killed", on_kill_other)
    update_health(inst, owner, true)
end

_health[FN_UPDATE] = function (inst, owner, name)
    update_health(inst, owner, false)
end



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------

local function on_build_item(player)
    GainUgPowerXp(player, NAMES.SANITY,  math.random(5, 10))
end

local function on_build_structure(player)
    GainUgPowerXp(player, NAMES.SANITY,  math.random(10, 20))
end

local function on_unlock_recipe(player)
    GainUgPowerXp(player, NAMES.SANITY, 50)
end


---comment 提升精神值上限 
local function update_sanity(inst, owner, detach)
    local max = inst.sanitymax
    local com = owner.components.sanity
    if com ~= nil and max ~= nil then
        local lv = detach and 0 or inst.components.uglevel:GetLv()
        local percent = com:GetPercent()
        com.max = math.floor(max * (1 + 0.01 * lv) + 0.5)
        com:SetPercent(percent)
    end
end


local _sanity = {
    [FN_SAVE] = function (inst, data) data.percent = inst.owner and inst.owner.components.sanity:GetPercent() end,
    [FN_LOAD] = function (inst, data) inst.percent = data.percent or nil end
}

_sanity[FN_ATTACH] = function (inst, owner)
    owner:ListenForEvent("builditem", on_build_item)
    owner:ListenForEvent("buildstructure", on_build_structure)
    owner:ListenForEvent("unlockrecipe", on_unlock_recipe)

    local sanity = owner.components.sanity
    inst.sanitymax = sanity and sanity.max or nil
    if inst.percent then
        sanity:SetPercent(inst.percent)
    end
end

_sanity[FN_UPDATE] = function (inst, owner)
    update_sanity(inst, owner, false)
end

_sanity[FN_DETACH] = function (inst, owner)
    owner:RemoveEventCallback("builditem", on_build_item)
    owner:RemoveEventCallback("buildstructure", on_build_structure)
    owner:RemoveEventCallback("unlockrecipe", on_unlock_recipe)
    update_sanity(inst, owner, true)
end



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------

local function on_harvest_food(doer, data)
    UgLog("on_harvest_food")
    GainUgPowerXp(doer, NAMES.COOKER, 5)
end

local function update_cooker(inst, owner, detach)
    local lv = detach and 0 or inst.components.uglevel:GetLv()
    local v  = math.max(1 - lv * 0.005, 0.5)
    PutUgData(owner, UGMARK.COOK_MULTI, v)
end

local _cooker = {}

_cooker[FN_ATTACH] = function (inst, owner)
    owner:ListenForEvent(UGEVENTS.HARVEST_SELF_FOOD, on_harvest_food)
end

_cooker[FN_UPDATE] = function (inst, owner)
    update_cooker(inst, owner, false)
end

_cooker[FN_DETACH] = function (inst, owner)
    owner:RemoveEventCallback(UGEVENTS.HARVEST_SELF_FOOD, on_harvest_food)
    update_cooker(inst, owner, true)
end



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local function on_harvest_dry(doer, data)
    GainUgPowerXp(doer, NAMES.DRYERR, 5)
end

local function update_dryerr(inst, owner, detach)
    local lv = inst.components.uglevel:GetLv()
    local v = detach and nil or math.max(1 - lv * 0.01, 0.3)
    PutUgData(owner, UGMARK.DRY_MULTI, v)
end

local _dryerr = {}
_dryerr[FN_ATTACH] = function (_, owner)
    owner:ListenForEvent(UGEVENTS.HARVEST_DRY, on_harvest_dry)
end

_dryerr[FN_UPDATE] = function (inst, owner)
    update_dryerr(inst, owner, false)
end

_dryerr[FN_DETACH] = function (inst, owner)
    update_dryerr(inst, owner, true)
    owner:RemoveEventCallback(UGEVENTS.HARVEST_DRY, on_harvest_dry)
end




--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local PICK_MAX = 5 
local PICKABLE_DEFS = (require "defs/items/ugitems").pick

local QUICK_PICKER_LEVEL = 5

---comment 计算倍率，最高5倍采集
---@param powerlv number 属性等级
---@return number 额外掉落物，累加计数
local function calc_extra_num(powerlv)
    local lv = powerlv
    lv = math.min(math.floor(lv * 0.05), PICK_MAX)
    local seed = 2 ^ PICK_MAX
    if lv < 1 then
        return math.random() < 0.1 and 1 or 0
    end
    local r = math.random(seed)
    for i = lv, 1, -1 do
        local ratio = seed / (2 ^ i)
        if r <= ratio then
            return i
        end
    end
    return 0
end


local function on_pick_plant(player, data)
    if not (data and data.object) then
        return
    end

    if data.object:HasTag("farm_plant") then
        return
    end

    local powerlv = GetUgPowerLv(player, NAMES.PICKER)
    if powerlv == nil then
        return
    end


    local obj  = data.object
    local loot = data.loot
    local exp = (PICKABLE_DEFS[obj.prefab] or 0)
    if not (exp > 0 and obj) then 
        return 
    end

    GainUgPowerXp(player, NAMES.PICKER, exp)

    -- 处理特殊case，目前支持多汁浆果
    if data.prefab then
        local num = calc_extra_num(powerlv)
        if num > 0 and obj.components.lootdropper then
            local pt = obj:GetPosition()
            pt.y = pt.y + (obj.components.pickable.dropheight or 0)
            for _ = 1, num * data.num do
                obj.components.lootdropper:SpawnLootPrefab(data.prefab, pt)
            end
        end

    elseif loot then
        --- 单个物品
        if loot.prefab ~= nil then
            -- 根据等级计算可以额外掉落的数量
            local num = calc_extra_num(powerlv)
            if num > 0 then
                for _ = 1, num do
                    local item = SpawnPrefab(loot.prefab)
                    player.components.inventory:GiveItem(item, nil, player:GetPosition())
                end
            end

        -- 多物品掉落(好像没走这个逻辑，确认下是不是农场作物掉落, 暂时保留)
        elseif not IsTableEmpty(loot) then
            -- 额外掉落物
            local extraloot = {}
            local lootdropper = obj.components.lootdropper
            local num = calc_extra_num(powerlv)
            local dropper = lootdropper:GenerateLoot()
            if (not IsTableEmpty(dropper)) and num > 0 then
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

        -- 仙人掌花单独处理
        if obj.has_flower and (obj.prefab == "cactus" or obj.prefab == "oasis_cactus") then
            local n = calc_extra_num(powerlv)
            for i = 1, n do
                local flower = SpawnPrefab("cactus_flower")
                player.components.inventory:GiveItem(flower, nil, player:GetPosition())
            end
        end
    end
end


local function update_picker(inst, owner, detach)
    local lv = detach and 0 or inst.components.uglevel:GetLv()
    if lv >= QUICK_PICKER_LEVEL then
        AddUgTag(owner, "fastpicker", NAMES.PICKER)
    else
        RemoveUgTag(owner, "fastpicker", NAMES.PICKER)
    end
end


local _picker = {}
_picker[FN_ATTACH] = function (inst, owner)
    owner:ListenForEvent("picksomething", on_pick_plant)
    owner:ListenForEvent(UGEVENTS.PICK_STH, on_pick_plant)
end

_picker[FN_DETACH] = function (inst, owner)
    update_picker(inst, owner, true)
    owner:RemoveEventCallback("picksomething", on_pick_plant)
    owner:RemoveEventCallback(UGEVENTS.PICK_STH, on_pick_plant)
end

_picker[FN_UPDATE] = function (inst, owner)
    update_picker(inst, owner, false)
end





--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local function on_pick_farm(player, data)
    if not (data and data.object) then
        return
    end

    if not data.object:HasTag("farm_plant") then
        return
    end

    local powerlv = GetUgPowerLv(player, NAMES.FARMER)
    if powerlv == nil then
        return
    end

    local oversized = data.object.is_oversized
    local exp = oversized and 10 or 5
    GainUgPowerXp(player, NAMES.FARMER, exp)

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


local _farmer = {}
_farmer[FN_ATTACH] = function (inst, owner)
    owner:ListenForEvent("picksomething", on_pick_farm)
end

_farmer[FN_DETACH] = function (inst, owner)
    owner:RemoveEventCallback("picksomething", on_pick_farm)
end



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local function on_fish(owner, data)
    GainUgPowerXp(owner, NAMES.FISHER, 10)
end

local function update_fisher(inst, owner, detach)
    local lv = inst.components.uglevel:GetLv()
    local m = detach and nil or math.max(1 - lv * 0.01, 0.2)
    PutUgData(owner, UGMARK.FISH_MULTI, m)
end

local _fisher = {}
_fisher[FN_ATTACH] = function (inst, owner)
    owner:ListenForEvent(UGEVENTS.FISH_SUCCESS, on_fish)
end

_fisher[FN_UPDATE] = function (inst, owner)
    update_fisher(inst, owner, false)
end

_fisher[FN_DETACH] = function (inst, owner)
    update_fisher(inst, owner, true)
    owner:RemoveEventCallback(UGEVENTS.FISH_SUCCESS, on_fish)
end



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local function monitor_locomotor(inst, owner)
    if not owner:HasTag("playerghost") then
        if owner.components.locomotor.wantstomoveforward then
            inst.time = inst.time + 1
        end
        -- 每走10s获得1点经验
        if inst.time >= 10 then
            GainUgPowerXp(owner, NAMES.RUNNER, 1)
            inst.time = 0
        end
    end
end


local function update_runner(inst, owner, detach)
    local locomotor = owner.components.locomotor
    if locomotor ~= nil then
        if detach then
            locomotor:RemoveExternalSpeedMultiplier(inst, NAMES.RUNNER)
        else
            local lv = inst.components.uglevel:GetLv()
            local mult = math.min(1 + lv * 0.01, 1.5)
            locomotor:SetExternalSpeedMultiplier(inst, NAMES.RUNNER, mult)
        end
    end
end

local _runner = {}
_runner[FN_ATTACH] = function (inst, owner)
    inst.time = 0
    owner.ugloco_task = owner:DoPeriodicTask(1, function ()
        monitor_locomotor(inst, owner)
    end)
end

_runner[FN_UPDATE] = function (inst, owner)
    update_runner(inst, owner, false)
end

_runner[FN_DETACH] = function (inst, owner)
    update_runner(inst, owner, true)
    if owner.ugloco_task ~= nil then
        owner.ugloco_task:Cancel()
        owner.ugloco_task = nil
    end
end 





--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local function update_doctor(inst, owner, detach)
    local lv = inst.components.uglevel:GetLv()
    local mv = detach and nil or (1 + lv * 0.01)
    PutUgData(owner, UGMARK.HEAL_MULTI, mv)
end


local function on_heal(doer, data)
    if data.health ~= nil then
        local xp = data.health * 0.5
        GainUgPowerXp(doer, NAMES.DOCTOR, xp)
    end
end


local _doctor = {
    [FN_UPDATE] = function (inst, owner)
        update_doctor(inst, owner, false)
    end,
    [FN_DETACH] = function (inst, owner)
        update_doctor(inst, owner, true)
        owner:RemoveEventCallback(UGEVENTS.HEAL, on_heal)
    end,  
    [FN_ATTACH] = function (inst, owner)
        owner:ListenForEvent(UGEVENTS.HEAL, on_heal)
    end
}



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local function on_hunter_killed(inst, data)
    local victim = data.victim
   
    if victim.components.freezable or victim:HasTag("monster") then
        local dropper = victim.components.lootdropper
        if dropper == nil then
            return
        end

        local lv = GetUgPowerLv(inst, NAMES.HUNTER)
        if lv ~= nil then
            -- 双倍掉落初始10%，满级100%
            local ratio = (lv + 10) / 100
            local rd = math.random()
    
            -- 三倍掉落概率更低，为两倍概率的1/5
            if rd < ratio / 5 then 
                dropper:DropLoot()
                dropper:DropLoot()
            elseif rd < ratio then
                dropper:DropLoot() 
            end
    
            -- 击杀大于血量1000的怪物能够升级属性
            if victim.components.health then
                local max = victim.components.health.maxhealth
                if max >= 1000 then
                    GainUgPowerXp(inst, NAMES.HUNTER, max * 0.01)
                end 
            end
        end

    end
end

local _hunter = {
    [FN_ATTACH] = function (inst, owner)
        owner:ListenForEvent("killed", on_hunter_killed)
    end,
    [FN_DETACH] = function (inst, owner)
        owner:RemoveEventCallback("killed", on_hunter_killed)
    end
}



return {
    [NAMES.HUNGER] = _hunger,
    [NAMES.HEALTH] = _health,
    [NAMES.SANITY] = _sanity,
    [NAMES.COOKER] = _cooker,
    [NAMES.DRYERR] = _dryerr,
    [NAMES.PICKER] = _picker,
    [NAMES.FARMER] = _farmer,
    [NAMES.FISHER] = _fisher,
    [NAMES.RUNNER] = _runner,
    [NAMES.DOCTOR] = _doctor,
    [NAMES.HUNTER] = _hunter,
}