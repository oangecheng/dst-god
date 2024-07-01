local NAMES     = UGPOWERS.PLAYER
local FN_ATTACH = "attach"
local FN_DETACH = "detach"
local FN_UPDATE = "update"
local FN_SAVE   = "save"
local FN_LOAD   = "load"



--------------------------------------------------------------------------大胃王-----------------------------------------------------------------------------------------------
local function on_eat(eater, data)
    local edible = data.food and data.food.components.edible
    if edible then
        local hungerexp = edible:GetHunger(eater)
        local healthexp = edible:GetHealth(eater)
        local sanityexp = edible:GetSanity(eater)
        local exp = 0.2 * hungerexp + healthexp * 0.3 + sanityexp * 0.5
        UgGainPowerExp(eater, NAMES.HUNGER, exp)
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
        UgGainPowerExp(killer, NAMES.HEALTH, exp)
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
                    UgGainPowerExp(player, NAMES.HEALTH, exp * multi)
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

_health[FN_ATTACH] = function (inst, owner, name)
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
    update_health(inst, owner)
end



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------

local function on_build_item(player)
    UgGainPowerExp(player, NAMES.SANITY,  math.random(3, 5))
end

local function on_build_structure(player)
    UgGainPowerExp(player, NAMES.SANITY,  math.random(6, 10))
end

local function on_unlock_recipe(player)
    UgGainPowerExp(player, NAMES.SANITY, 20)
end


---comment 提升精神值上限 
local function update_sanity(inst, owner, detach)
    local max = inst.maxsanity
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


return {
    [NAMES.HUNGER] = _hunger,
    [NAMES.HEALTH] = _health,
    [NAMES.SANITY] = _sanity,
}