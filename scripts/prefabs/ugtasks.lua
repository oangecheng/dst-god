

local function fn()
    local inst = CreateEntity()
    inst:AddTag("CLASSIFIED")
    inst.type = UGENTITY_TYPE.TASK
    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, inst:Remove())
        return inst
    end
    
    inst.entity:AddTransform()
    inst.entity:Hide()
    inst.persists = false


    inst:AddComponent("timer")
    inst:AddComponent("ugentity")
    inst.datafn = function()
        return inst.components.ugentity:GetData()
    end
    inst.winfn = function ()
        
    end

    inst.losefn = function ()
        
    end

    inst.components.ugentity:SetOnAttachFn(function(owner, name)
        owner.ugtask = name
    end)
    inst.components.ugentity:SetOnDetachFn(function(owner, name)
        owner.ugtask = nil
    end)

    return inst
end

return Prefab(UGTASKS.DAILY, fn, nil, nil)