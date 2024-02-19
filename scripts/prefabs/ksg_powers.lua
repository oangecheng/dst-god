


local function MakePower(name, data)

    local function fn()
        local inst = CreateEntity()
        inst:AddTag(KSG_TAGS.LEVEL)
        inst.name = name

        if not TheWorld.ismastersim then
            inst:DoTaskInTime(0, inst:Remove())
            return inst
        end

        inst.entity:AddTransform()
        inst.entity:Hide()
        inst.persists = false
        inst:AddTag("CLASSIFIED")

        --- 等级组件
        --- 等级变更时，刷新属性状态，经验变更只刷新面板
        local level = inst:AddComponent("ksg_level")
        level:SetOnLvFn(function(lv)
            KsgLog("power lv changed", lv, name, inst.owner)
            if inst.owner then
                inst.owner:PushEvent(KSG_EVENTS.POWER_REFRESH, { name = name })
                if data.onrefresh then
                    data.onrefresh(inst)
                end
            end
        end)
        level:SetOnXpFn(function(xp)
            KsgLog("power xp changed", xp, name, inst.owner)
            if inst.owner then
                inst.owner:PushEvent(KSG_EVENTS.POWER_REFRESH, { name = name })
            end
        end)


        --- 属性组件
        local power = inst:AddComponent("ksg_power")
        power:SetOnBindFn(function(_, owner)
            KsgLog("power bind", name)
            if data.onbind then
                data.onbind(inst, owner, name)
            end
        end)
        power:SetOnUnbindFn(function(_, owner)
            KsgLog("power unbind", name)
            if data.onunbind then
                data.onunbind(inst, owner, name)
            end
        end)

        return inst
    end
        
    return Prefab("ksg_power_"..name, fn, nil, nil)
end




local powers = {}
local defs = MergeMaps(
    require("defs/powers/userpowers"),
    require("defs/powers/itempowers"),
    require("defs/powers/monspowers")
)
for k,v in pairs(defs) do
    table.insert(powers, MakePower(k, v))
end

return unpack(powers)