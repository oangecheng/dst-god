
local JUDGES = {}
local TIMER = "Task"
JUDGES[KSG_TASKS.TYPE.KILL] = require("defs/tasks/taskjudge")


local function fn()
    local inst = CreateEntity()
    inst:AddTag("CLASSIFIED")
    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, inst:Remove())
        return inst
    end

    inst.entity:AddTransform()
    inst.entity:Hide()
    inst.persists = false


    local task  = inst:AddComponent("timer")
    local timer = inst:AddComponent("ksg_task")

    task:SetOnStartFn(function(type, data, owner)
        KsgLog("on task start", type)
        local judge = JUDGES[type]
        if judge and judge.startfn then
            judge.startfn(owner, data)
        end
        if data.time > 0 then
            timer:StartTimer(TIMER, data.time)
        end
    end)

    task:SetOnStopFn(function(type, data, owner)
        KsgLog("on task stop", type)
        timer:StopTime(TIMER)
        local judge = JUDGES[type]
        if judge and judge.stopfn then
            judge.stopfn(owner, data)
        end
        timer:StopTime(TIMER)
    end)

    task:SetOnWinFn(function(type, data, owner)
        KsgLog("on task win", type)
    end)

    task:SetOnLoseFn(function(type, data, owner)
        KsgLog("on task lose", type)
    end)

    -- 倒计时结束任务失败
    inst:ListenForEvent("timerdone", function (_, data)
        task:Lose()
    end)

    return inst
end

return Prefab("ksg_task", fn, nil, nil)
