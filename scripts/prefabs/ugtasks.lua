
local JUDGES = require("task/judge")
local FINISH = require("task/finish")
local ATTACH = "attach"
local DETACH = "detach"

local function on_task_change(inst, fn)
    local data = inst.components.ugentity:GetData()
    if data ~= nil and data.demands ~= nil then
        for _, v in ipairs(data.demands) do
            local judge = JUDGES[v.type]
            if judge ~= nil and inst.owner ~= nil then
                judge[fn](inst, inst.owner, inst.name)
            end
        end
    end
end


local function finish_task(inst, iswin)
    if inst.owner then
        inst.owner:PushEvent(UGEVENTS.TASK_FINISH, { name = inst.name, win = iswin })
    end
end


local function fn()
    local inst = CreateEntity()
    inst:AddTag("CLASSIFIED")
    inst.type = UGENTITY_TYPE.TASK

    inst.name = UGTASKS.NAMES.DAILY
    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, inst:Remove())
        return inst
    end
    
    inst.entity:AddTransform()
    inst.entity:Hide()
    inst.persists = false


    inst:AddComponent("timer")
    inst:AddComponent("ugentity")

    local function datafn()
        return inst.components.ugentity:GetData()
    end

    inst.datafn = datafn
    
    inst.winfn = function ()
        local data = datafn()
        UgLog("task win")
        if data ~= nil and data.rewards ~= nil and inst.owner ~= nil then
            FINISH.winfn(inst, inst.owner, data.rewards)
        end
        finish_task(inst, true)
    end

    inst.losefn = function ()
        local data = datafn()
        UgLog("task lose")
        if data ~= nil and data.punish ~= nil and inst.owner ~= nil then
            FINISH.losefn(inst, inst.owner, data.punish)
        end
        finish_task(inst, false)
    end

    inst.components.ugentity:SetOnAttachFn(function(owner, name)
        owner.ugtask = name
        UgLog("task attach", name)
        on_task_change(inst, ATTACH)
    end)
    
    inst.components.ugentity:SetOnDetachFn(function(owner, name)
        UgLog("task detach", name)
        on_task_change(inst, DETACH)
        owner.ugtask = nil
    end)

    return inst
end

return Prefab(UGTASKS.NAMES.DAILY, fn, nil, nil)