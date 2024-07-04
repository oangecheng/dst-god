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
    sys:AddEntity(UGPOWERS.EQUIPS.DAMAGE)
    local powers = sys:GetEntity(UGENTITY_TYPE.POWER)
    for _, v in ipairs(powers) do
        v.components.uglevel:SetLv(100)
    end
end)