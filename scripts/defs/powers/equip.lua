local NAMES     = UGPOWERS.EQUIPS
local FN_ATTACH = "attach"
local FN_DETACH = "detach"
local FN_UPDATE = "update"
local FN_SAVE   = "save"
local FN_LOAD   = "load"


--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------

local function update_damage(inst, owner, detach)
    local dmg = inst.damage
    if dmg ~= nil then
        local lv = inst.components.uglevel:GetLv()
        local dv = dmg + (detach and 0 or lv)
        owner.components.weapon:SetDamage(dv)
    end
end


local _damage = {
    [FN_UPDATE] = update_damage,
    [FN_DETACH] = function(inst, owner)
        update_damage(inst, owner, true)
    end,
    [FN_ATTACH] = function(inst, owner)
        if owner.components.weapon ~= nil then
            inst.damage = owner.components.weapon.damage
        end
    end,
}


--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
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
        local delta = math.floor(lv * 0.05 + 1.5)
        delta = math.min(delta, 10)
        attacker.components.health:DoDelta(delta, false, NAMES.VAMPIR)
    end
end


local _vampir = {
    [FN_ATTACH] = function (inst, owner)
        inst.attackfn = attack_vampir
    end,
    [FN_DETACH] = function (inst)
        inst.attackfn = nil
    end
}



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------

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
    local x,y,z = victim.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, area, { "_combat" }, splash_exclude)
    for i, ent in ipairs(ents) do
        if ent ~= victim and ent ~= attacker and combat:IsValidTarget(ent) and (not isFollower(attacker, ent)) then
            attacker:PushEvent("onareaattackother", { target = ent, weapon = weapon, stimuli = nil })
            local damage = combat:CalcDamage(ent, weapon, 1) * multi
            ent.components.combat:GetAttacked(attacker, damage, weapon, nil)
        end
    end
end


local _splash = {
    [FN_ATTACH] = function (inst)
        inst.attackfn = attack_splash
    end,
    [FN_ATTACH] = function (inst)
        inst.attackfn = nil
    end,
}



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------

local function attack_criter(power, attacker, victim, weapon, lv)
    if attacker.components.combat ~= nil and victim.components.combat ~= nil then
        local dmg, spdmg = attacker.components.combat:CalcDamage(attacker, weapon, 1)
        -- 概率双倍伤害
        if dmg ~= nil and math.random() < (lv * 0.01)then
            victim.components.combat:GetAttacked(attacker, dmg, weapon, nil)
        end
    end
end

local _criter = {
    [FN_ATTACH] = function (inst)
        inst.attackfn = attack_criter
    end,
    [FN_DETACH] = function (inst)
        inst.attackfn = nil
    end
}




--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------

local function attack_blindr(power, attacker, victim, weapon, lv)
    -- 概率致盲
    if math.random() < (math.min(0.3, lv * 0.01)) then
        -- 给目标增加致盲标记
        PutUgData(victim, UGMARK.ATK_MISS, lv)
        if victim.ugblindtask ~= nil then
            victim.ugblindtask:Cancel()
            victim.ugblindtask = nil
        end
        -- 3s后移除标记
        victim.ugblindtask = victim:DoTaskInTime(3, function ()
            PutUgData(victim, UGMARK.ATK_MISS, nil)
        end)
    end
end

local _blindr = {
    [FN_ATTACH] = function (inst)
        inst.attackfn = attack_blindr
    end,
    [FN_DETACH] = function (inst)
        inst.attackfn = nil
    end
}





--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------

local function update_maxuse(inst, owner, detach)
    local max = inst.max
    if max ~= nil then
        local lv = detach and 0 or inst.components.uglevel:GetLv()
        local mv = max * (lv * 0.5 + 1)
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


local _maxuse = {
    [FN_UPDATE] = update_maxuse,
    [FN_DETACH] = function(inst, owner) update_maxuse(inst, owner, true) end,
    [FN_ATTACH] = function(inst, owner)
        if owner.components.finiteuses ~= nil then
            inst.max = owner.components.finiteuses.total
        elseif owner.components.armor ~= nil then
            inst.max = owner.components.armor.maxcondition
        end
    end
}




return {
    [NAMES.DAMAGE] = _damage,
    [NAMES.VAMPIR] = _vampir,
    [NAMES.SPLASH] = _splash,
    [NAMES.CRITER] = _criter,
    [NAMES.BLINDR] = _blindr,
    [NAMES.MAXUSE] = _maxuse,
}