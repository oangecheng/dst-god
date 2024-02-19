


AddPlayerPostInit(function(player)
    player:AddComponent("ksg_system_power")
    player:AddComponent("ksg_system_task")
    player:ListenForEvent("oneat", function ()
        player.components.ksg_system_power:AddPower(KSG_POWERS.USER.HUNGER)
    end)
end)