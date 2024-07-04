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




--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local function update_warmer(inst, owner, detach)
    if inst.modtype ~ nil and inst.insulator ~= nil and inst.type ~= nil then
        local lv = detach and 0 or inst.components.uglevel:GetLv()
        local iv = inst.insulator + lv * 10
        local ty = detach and inst.type or inst.modtype
        owner.components.SetInsulation(iv)
        if ty == SEASONS.SUMMER then
            owner.components.insulator:SetSummer()
        elseif ty == SEASONS.WINTER then
            owner.components.insulator:SetWinter()
        end
    end
end


local _warmer = {
    [FN_UPDATE] = update_warmer,
    [FN_LOAD]   = function (inst, data)
        inst.modtype = data.modtype
        inst.actived = data.actived
    end,
    [FN_SAVE]   = function (inst, data)
        data.modtype = inst.modtype
        data.actived = inst.actived
    end,
    [FN_DETACH] = function(inst, owner) 
        update_warmer(inst, owner, true)
        RemoveUgComponent(owner, "insulator", NAMES.WARMER)
        inst.ugswitchfn = nil
        inst.ugactivefn = nil
    end
}

_warmer[FN_ATTACH] = function(inst, owner)
    -- 激活函数
    owner.ugactivefn = function(doer, data)
        if inst.actived then
            return false
        else
            inst.actived = true
            return true
        end
    end

    -- 切换函数
    owner.ugswitchfn = function(doer, data)
        if inst.actived and inst.modtype ~= nil then
            inst.modtype = (inst.modtype == SEASONS.SUMMER) and SEASONS.WINTER or SEASONS.SUMMER
            update_warmer(inst, owner)
            return true
        end
        return false
    end

    AddUgComponent(owner, "insulator", NAMES.WARMER)
    if owner.components.insulator then
        local value, type = owner.components.insulator:GetInsulation()
        inst.insulation = value
        inst.type = type
        if inst.modtype == nil then
            inst.modtype = type
        end
    end
end



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local DAPPERNESS_RATIO = TUNING.DAPPERNESS_MED / 3

local function update_dapper(inst, owner, detach)
    if inst.dapperness ~= nil then
        local lv = detach and 0 or inst.components.uglevel:GetLv()
        local dv = inst.dapperness + DAPPERNESS_RATIO * lv
        owner.components.equippable.dapperness = dv
    end
end

local _dapper = {
    [FN_UPDATE] = update_dapper,
    [FN_DETACH] = function (inst, owner)
        update_dapper(inst, owner, true)
    end,
    [FN_ATTACH] = function (inst, owner)
        if owner.components.equippable ~= nil then
            inst.dapperness = owner.components.equippable.dapperness
        end
    end
}



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local function update_proofr(inst, owner, detach)
    if inst.effect ~= nil then
        local lv = detach and 0 or inst.components.uglevel:GetLv()
        local ev = math.min(inst.effect + lv * 0.01, 1)
        owner.components.waterproofer:SetEffectiveness(ev)
    end
end

local _proofr = {
    [FN_UPDATE] = update_proofr,
    [FN_DETACH] = function (inst, owner)
        update_proofr(inst, owner, true)
        RemoveUgComponent(owner, "waterproofer", NAMES.PROOFR)
    end,
}

_proofr[FN_ATTACH] = function (inst, owner)
    -- 修改下升级函数，防水升级到100比较困难
    inst.components.uglevel.expfn = function () return 10 end
    AddUgComponent(owner, "waterproofer", NAMES.PROOFR)
    local waterproofer = owner.components.waterproofer
    if waterproofer.isugtemp then
        waterproofer:SetEffectiveness(0)
    end
    local eff = waterproofer:GetEffectiveness()
    inst.effect = eff
end



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local chopmax = 15

local function update_choper(inst, owner, detach)
    local lv = detach and 0 or inst.components.uglevel:GetLv()
    local mv = math.max(chopmax - lv * 0.15, 1)
    local multi = math.floor(chopmax/mv + 0.5)
    owner.components.tool:SetAction(ACTIONS.CHOP, multi)
    if owner.components.finiteuses ~= nil then
        owner.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)
    end
    
end

local _choper = {
    [FN_UPDATE] = update_choper,
    [FN_DETACH] = function (inst, owner)
        update_choper(inst, owner, true)
        RemoveUgComponent(owner, "tool", NAMES.CHOPER)
    end,
    [FN_ATTACH] = function (inst, owner)
        AddUgComponent(owner, "tool", NAMES.CHOPER)
    end
}



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local minemax = 10

local function update_mining(inst, owner, detach)
    local lv = detach and 0 or inst.components.uglevel:GetLv()
    local mv = math.max(minemax - lv * 0.1, 1)
    local multi = math.floor(minemax/mv + 0.5)
    owner.components.tool:SetAction(ACTIONS.MINE, multi)
    if owner.components.finiteuses ~= nil then
        owner.components.finiteuses:SetConsumption(ACTIONS.MINE, 1)
    end
    
end

local _mining = {
    [FN_UPDATE] = update_mining,
    [FN_DETACH] = function (inst, owner)
        update_mining(inst, owner, true)
        RemoveUgComponent(owner, "tool", NAMES.MINING)
    end,
    [FN_ATTACH] = function (inst, owner)
        AddUgComponent(owner, "tool", NAMES.MINING)
    end
}



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local function update_speedr(inst, owner, detach)
    if inst.speed ~= nil then
        local lv = detach and 0 or inst.components.uglevel:GetLv()
        local mv = inst.speed + lv * 0.01
        owner.components.equippable.walkspeedmult = mv
    end
end

local _speedr = {
    [FN_UPDATE] = update_speedr,
    [FN_DETACH] = function (inst, owner)
        update_speedr(inst, owner, true)
    end,
    [FN_ATTACH] = function (inst, owner)
        if owner.components.equippable ~= nil then
            inst.speed = owner.components.equippable:GetWalkSpeedMult()
        end
    end
}





--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local function update_absorb(inst, owner, detach)
    if inst.absorb ~= nil then
        local lv = detach and 0 or inst.components.uglevel:GetLv()
        local mv = inst.absorb + lv * 0.01
        owner.components.armor:SetAbsorption(mv)
    end
end

local _absorb = {
    [FN_UPDATE] = update_absorb,
    [FN_DETACH] = function (inst, owner)
        update_absorb(inst, owner, true)
    end,
    [FN_ATTACH] = function (inst, owner)
        if owner.components.armor ~= nil then
            inst.absorb = owner.components.armor.absorb_percent
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
    [NAMES.WARMER] = _warmer,
    [NAMES.DAPPER] = _dapper,
    [NAMES.PROOFR] = _proofr,
    [NAMES.CHOPER] = _choper,
    [NAMES.MINING] = _mining,
    [NAMES.SPEEDR] = _speedr,
    [NAMES.ABSORB] = _absorb,
}