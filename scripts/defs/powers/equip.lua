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
    [FN_UPDATE] = function (inst, owner)
        update_damage(inst, owner, false)
    end,
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
-- 最高暴击倍率
local critmax = 5
local function dmg_criter(power, lv, dmg, spdmg, data)
    local m = 1
    if math.random() < 0.2 then
        local seed = lv * 0.1
        m = math.min(math.floor(2 + seed), critmax)
    end
    return dmg * m, spdmg
end

local _criter = {
    [FN_ATTACH] = function (inst)
        inst.dmgfn = dmg_criter
    end,
    [FN_DETACH] = function (inst)
        inst.dmgfn = nil
    end
}



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
-- 最高闪避概率
local DODGER_MAX = 0.3
local function dmg_dodger(power, lv, dmg, spdmg, data)
    local seed = math.min(lv * 0.01, DODGER_MAX)
    -- 闪避支持位面伤害等
    if math.random() < seed then
        return 0, nil
    end
    return dmg, spdmg
end

local _dodger = {
    [FN_ATTACH] = function (inst)
        inst.dmgfn = dmg_dodger
    end,
    [FN_DETACH] = function (inst)
        inst.dmgfn = nil
    end
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
local function attack_poison(power, attacker, victim, weapon, lv)
    if victim.components.locomotor ~= nil then
        -- 最高30%概率减速 25%
        if math.random() < (math.min(0.3, lv * 0.01)) then
            victim.components.locomotor:SetExternalSpeedMultiplier(power, NAMES.POISON, 0.75)
            if victim.ugpoisontask ~= nil then
                victim.ugpoisontask:Cancel()
                victim.ugpoisontask = nil
            end
            -- 3s后移除标记
            victim.ugpoisontask = victim:DoTaskInTime(3, function()
                victim.components.locomotor:RemoveExternalSpeedMultiplier(power, NAMES.POISON)
            end)
        end
    end
end

local _poison = {
    [FN_ATTACH] = function (inst)
        inst.attackfn = attack_poison
    end,
    [FN_DETACH] = function (inst)
        inst.attackfn = nil
    end
}




--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local function atked_thorns(power, attacker, victim, weapon, lv)
    if attacker.components.health ~= nil then
        local dmg = math.floor( math.random(5) + lv * 0.1)
        attacker.components.health:DoDelta(-dmg, nil, nil, true, nil, true)
        attacker:PushEvent("thorns")
    end
end

local _thorns = {
    [FN_ATTACH] = function (inst, owner)
        inst.attackedfn = atked_thorns
    end,
    [FN_DETACH] = function (inst, owner)
        inst.attackedfn = nil
    end
}






--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
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
        local inventory = inst.owner.components.inventory
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
        if owner.components.fuled ~= nil then
            local v = inst.max * (lv * 0.25 + 1)
            local percent =  owner.components.fuled:GetPercent()
            owner.components.fuled.maxfuel = v
            owner.components.fuled:SetPercent(percent)
            return
        end
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


local _maxuse = {
    [FN_UPDATE] = function(inst, owner) 
        update_maxuse(inst, owner, false) 
    end,
}

_maxuse[FN_SAVE] = function (inst, data)
    -- 衣帽需要存下当前的百分比
    if inst.owner ~= nil and inst.owner.components.fuled then
        data.percent = inst.owner.components.fuled:GetPercent()
    end
end

_maxuse[FN_LOAD] = function (inst, data)
    inst.percent = data.percent
end


_maxuse[FN_ATTACH] = function(inst, owner)
    owner:ListenForEvent("percentusedchange", on_percent_changed)
    owner:ListenForEvent("equipped", on_equip)
    
    -- 衣帽的修理走修理包
    if owner.components.finiteuses ~= nil then
        owner.ugrepairfn = repair_fn
        AddUgTag(owner, UGTAGS.REPAIR, NAMES.MAXUSE)
        inst.max = owner.components.finiteuses.total

    elseif owner.components.armor ~= nil then
        owner.ugrepairfn = repair_fn
        AddUgTag(owner, UGTAGS.REPAIR, NAMES.MAXUSE)
        inst.max = owner.components.armor.maxcondition

    elseif owner.components.fuled ~= nil then
        inst.max = owner.components.fuled.maxfuel
        if inst.percent ~= nil then
            owner.components.fuled:SetPercent(inst.percent)
        end
    end    
end


_maxuse[FN_DETACH] = function(inst, owner)
    RemoveUgTag(owner, UGTAGS.REPAIR, NAMES.MAXUSE)
    update_maxuse(inst, owner, true)
    owner:RemoveEventCallback("percentusedchange", on_percent_changed)
    owner:RemoveEventCallback("equipped", on_equip)
    owner.ugowner = nil
    owner.ugrepairfn = nil
    inst.percent = nil
end



--------------------------------------------------------------------------**-----------------------------------------------------------------------------------------------
local function update_warmer(inst, owner, detach)
    if inst.modtype ~= nil and inst.insulator ~= nil and inst.type ~= nil then
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
    [FN_UPDATE] = function(inst, owner)
        update_warmer(inst, owner, false)
    end,
    [FN_LOAD]   = function(inst, data)
        inst.modtype = data.modtype
        inst.actived = data.actived
    end,
    [FN_SAVE]   = function(inst, data)
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
    [FN_UPDATE] = function (inst, owner)
        update_dapper(inst, owner, false)
    end,
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
    [FN_UPDATE] = function (inst, owner)
        update_proofr(inst, owner, false)
    end,
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
    if GetUgData(waterproofer, NAMES.PROOFR) then
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
    [FN_UPDATE] = function (inst, owner)
        update_choper(inst, owner, false)
    end,
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
    [FN_UPDATE] = function (inst, owner)
        update_mining(inst, owner, false)
    end,
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
    [FN_UPDATE] = function (inst, owner)
        update_speedr(inst, owner, false)
    end,
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
        local mv = math.min(inst.absorb + lv * 0.01, 0.9)
        owner.components.armor:SetAbsorption(mv)
    end
end

local _absorb = {
    [FN_UPDATE] = function (inst, owner)
        update_absorb(inst, owner, false)
    end,
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
    -- 伤害计算类型
    [NAMES.CRITER] = _criter,
    [NAMES.DODGER] = _dodger,

    -- 攻击效果类型
    [NAMES.VAMPIR] = _vampir,
    [NAMES.SPLASH] = _splash,
    [NAMES.BLINDR] = _blindr,
    [NAMES.POISON] = _poison,

    -- 被攻击
    [NAMES.THORNS] = _thorns,

    -- 固定属性类型
    [NAMES.DAMAGE] = _damage,
    [NAMES.MAXUSE] = _maxuse,
    [NAMES.WARMER] = _warmer,
    [NAMES.DAPPER] = _dapper,
    [NAMES.PROOFR] = _proofr,
    [NAMES.CHOPER] = _choper,
    [NAMES.MINING] = _mining,
    [NAMES.SPEEDR] = _speedr,
    [NAMES.ABSORB] = _absorb,
}