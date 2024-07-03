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




return {
    [NAMES.DAMAGE] = _damage,
    [NAMES.VAMPIR] = _vampir
}