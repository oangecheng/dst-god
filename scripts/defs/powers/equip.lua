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
    [FN_UPDATE] = update_damage
}

_damage[FN_ATTACH] = function (inst, owner)
    if owner.components.weapon ~= nil then
        inst.damage = owner.components.weapon.damage
    end
end


_damage[FN_DETACH] = function (inst, owner)
    update_damage(inst, owner, true)
end






return {
    [NAMES.DAMAGE] = _damage
}