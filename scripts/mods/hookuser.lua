AddPlayerPostInit(function(player)
    local powersys = player:AddComponent("ugsystem")
    player:ListenForEvent("oneat", function (_, data)
        for key, value in pairs(UGPOWERS.PLAYER) do
            powersys:AddEntity(value)
        end
    end)
end)


AddPrefabPostInit("spear", function (inst)
    local sys = inst:AddComponent("ugsystem")
    for _, v in pairs(UGPOWERS.EQUIPS) do
        local power = sys:AddEntity(v)
        power.components.uglevel:SetLv(100)
    end
end)