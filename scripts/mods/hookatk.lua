local function check_dmg(dmg, spdmg)
    return dmg == 0 and spdmg == nil
end

local function dmgfn(target, dmg, spdmg, data)
    local xdmg = dmg
    local xspd = spdmg
    if target ~= nil and target.components.ugsystem ~= nil then
        local powers = target.components.ugsystem:GetAll(UGENTITY_TYPE.POWER)
        for _, v in ipairs(powers) do
            if v.dmgfn ~= nil then
                local lv = v.components.uglevel:GetLv()
                xdmg, xspd = v.dmgfn(v, lv, xdmg, xspd, data)
                --- 如果已经是0 和 空值，提前返回
                if check_dmg(xdmg, xspd) then
                    return 0, nil
                end
            end
        end
    end
    return xdmg, xspd
end


---comment hook 攻击伤害
---@param attacker table 攻击者
---@param victim table 受害者
---@param weapon table 武器
---@param dmg number 伤害
---@param spdmg table|nil 特殊伤害，例如位面伤害
---@return number 伤害, table|nil 特殊伤害
local function hook_damage(attacker, victim, weapon, dmg, spdmg)
    local xdmg = dmg
    local xspd = spdmg

    local data = { 
        attacker = attacker, 
        victim = victim, 
        weapon = weapon
     }

    ---计算攻击者
    xdmg, xspd = dmgfn(attacker, xdmg, xspd, data)
    if check_dmg(xdmg, xspd) then
        return xdmg, xspd
    end

    ---计算武器
    xdmg, xspd = dmgfn(weapon, xdmg, xspd, data)
    if check_dmg(xdmg, xspd) then
        return xdmg, xspd
    end

    ---计算被攻击者的
    xdmg, xspd = dmgfn(victim, xdmg, xspd, data)
    if check_dmg(xdmg, xspd) then
        return xdmg, xspd
    end

    ---这里只计算护甲类型的减伤
    if victim ~= nil and victim.components.inventory ~= nil then
        local slots = victim.components.inventory.equipslots
        for k, v in pairs(slots) do
            if v.components.ugsystem ~= nil and v.components.armor ~= nil then
                xdmg, xspd = dmgfn(v, xdmg, xspd, data)
                if check_dmg(xdmg, xspd) then
                    return xdmg, xspd
                end
            end
        end
    end

    return xdmg, xspd
end


--- hook combat 组件
--- 伤害计算使用这个函数hook
--- 怪物之间战斗的伤害结算也是计算属性的，因为hook的是组件
AddComponentPostInit("combat", function(self)
    local old_cacl_damage = self.CalcDamage
    self.CalcDamage = function(_, target, weapon, multiplier)
        local dmg, spdmg = old_cacl_damage(self, target, weapon, multiplier)
        dmg, spdmg = hook_damage(self.inst, target, weapon, dmg, spdmg)
        return dmg, spdmg
    end
end)


---------------------------------------------------------------------------------------------------------------------------------------------------------------


--- 攻击之后触发的效果
local function hook_target_atk(target, attacker, victim, weapon)
    local sys = target and target.components.ugsystem or nil
    if sys ~= nil then
        local powers = sys:GetAll(UGENTITY_TYPE.POWER)
        for _, v in ipairs(powers) do
            if v.attackfn ~= nil then
                local lv = v.components.uglevel:GetLv()
                v.attackfn(v, attacker, victim, weapon, lv)
            end
        end
    end
end


--- 武器，玩家
local function hook_atk(inst, data)
    local attacker = inst
    local victim = data.target
    local weapon = data.weapon
    hook_target_atk(attacker, attacker, victim, weapon)
    hook_target_atk(weapon, attacker, victim, weapon)
end


--- 被攻击触发的效果
local function hook_target_atked(target, attacker, victim, weapon)
    local sys = target and target.components.ugsystem or nil
    if sys ~= nil then
        local powers = sys:GetAll(UGENTITY_TYPE.POWER)
        for _, v in ipairs(powers) do
            if v.attackedfn ~= nil then
                local lv = v.components.uglevel:GetLv()
                v.attackedfn(v, attacker, victim, weapon, lv)
            end
        end
    end
end


---受害者
local function hook_atked(inst, data)
    hook_target_atked(inst, data.attacker, inst, data.weapon)
end


--- hook玩家攻击和被攻击的事件
--- 一般执行属性效果使用这个hook
AddPlayerPostInit(function(player)
    player:ListenForEvent("onattackother", hook_atk)
    player:ListenForEvent("attacked", hook_atked)
end)