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


return {
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
