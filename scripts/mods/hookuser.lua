local factory = require "defs/tasks/factory"

AddPlayerPostInit(function(player)
    local sys = player:AddComponent("ugsystem")
    player:AddComponent("ugsync")


    player:ListenForEvent(UGEVENTS.TASK_FINISH, function (inst, data)
        sys:RemoveEntity(data.name)
    end)

    player:ListenForEvent("oneat", function (_, data)
        for key, value in pairs(UGPOWERS.PLAYER) do
            sys:AddEntity(value)
        end

        if data.food.prefab == "bird_egg" then
            local name = UGTASKS.NAMES.DAILY
            local task = factory.taskfn(player, name, UGTASKS.STARS.S)
            sys:AddEntity(name, task)
        end
    end)

    player:DoTaskInTime(0.1, function ()
        player.components.ugsync:SyncPower()
    end)
end)


AddPrefabPostInit("spear", function (inst)
    inst:AddComponent("ugsystem")
    inst:AddComponent("ugsync")
    -- 测试代码
    for _, v in pairs(UGPOWERS.EQUIPS) do
        local power = inst.components.ugsystem:AddEntity(v)
    end

    inst:DoTaskInTime(0.1, function ()
        inst.components.ugsync:SyncPower()
    end)
end)