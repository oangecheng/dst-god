

local function tryUpdatePower(inst, name, data)
    if inst.owner ~= nil then
        inst.owner:PushEvent(UGEVENTS.POWER_UPDATE, { name = name })
        if data then
            if data.update then
                UgLog("update power", name, inst.components.uglevel:GetLv() )
                data.update(inst, inst.owner, name)
            end
        end
    end
end


local function MakePower(name, data)

    local function fn()
        local inst = CreateEntity()
        inst:AddTag(UGTAGS.LEVEL)
        inst.type = UGENTITY_TYPE.POWER
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
        local level = inst:AddComponent("uglevel")

        level:SetOnLvFn(function()
            tryUpdatePower(inst, name, data)
        end)

        level:SetOnXpFn(function()
            if inst.owner then
                inst.owner:PushEvent(UGEVENTS.POWER_UPDATE, { name = name })
            end
        end)


        --- 属性组件
        local power = inst:AddComponent("ugentity")
        power:SetOnAttachFn(function(owner, pname)
            if data.attach then
                data.attach(inst, owner, pname)
                --- 因为attach比较晚，所以绑定之后刷新下属性状态
                tryUpdatePower(inst, name, data)
            end
        end)

        power:SetOnExtendFn(function (owner, pname)
            if data.extend then
                data.extend(inst, owner, pname)
            end
        end)

        power:SetOnDetachFn(function(owner, pname)
            if data.detach then
                data.detach(inst, owner, pname)
            end
        end)

        inst.OnLoad = function (_inst, d)
            if data.load then
                data.load(_inst, d)
            end
        end


        inst.OnSave = function (_inst, d)
            if data.save then
                data.save(_inst, d)
            end
        end


        return inst
    end
        
    return Prefab(name, fn, nil, nil)
end




local powers = {}
local defs = MergeMaps(
    require("defs/powers/player"),
    require("defs/powers/equip")
)
for k,v in pairs(defs) do
    table.insert(powers, MakePower(k, v))
end

return unpack(powers)