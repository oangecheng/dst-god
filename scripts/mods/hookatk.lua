
local function hook_weapon_attack(attacker, victim, weapon)
    local sys = weapon and weapon.components.ugsystem or nil
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


local function hook_attacked()
    
end


--- hook玩家攻击和被攻击的事件
--- 一般执行属性效果使用这个hook
AddPlayerPostInit(function(player)
    player:ListenForEvent("onattackother", function (inst, data)
        hook_weapon_attack(inst, data.target, data.weapon)
    end)

    player:ListenForEvent("attacked", function (inst, data)
        hook_attacked()
    end)
end)