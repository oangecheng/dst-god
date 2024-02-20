


AddPlayerPostInit(function(player)
    local powersys = player:AddComponent("ksg_system_power")
    local tasksys = player:AddComponent("ksg_system_task")
    player:ListenForEvent("oneat", function (_, data)
        powersys:AddPower(KSG_POWERS.USER.HUNGER)
        if data.food and data.food.prefab == "egg" then
            local task = CreateRandomTask()
            tasksys:AddTask(task)
        end
    end)

    player:ListenForEvent(KSG_EVENTS.TASK_FINISH, function (inst, data)
        tasksys:RemoveTask(data.type)
    end)
end)