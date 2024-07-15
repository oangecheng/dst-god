AddPlayerPostInit(function(player)
    local powersys = player:AddComponent("ugsystem")
    player:AddComponent("ugsync")

    
    player:ListenForEvent("oneat", function (_, data)
        for key, value in pairs(UGPOWERS.PLAYER) do
            powersys:AddEntity(value)
        end
    end)

    player:DoTaskInTime(0.1, function ()
        player.components.ugsync:SyncPower()
    end)
end)


AddPrefabPostInit("spear", function (inst)
    inst:AddComponent("ugsystem")
    inst:AddComponent("ugsync")
    inst:AddComponent("ugrepair")

    -- 测试代码
    for _, v in pairs(UGPOWERS.EQUIPS) do
        local power = inst.components.ugsystem:AddEntity(v)
        power.components.uglevel:SetLv(100)
    end

    inst:DoTaskInTime(0.1, function ()
        inst.components.ugsync:SyncPower()
    end)
end)