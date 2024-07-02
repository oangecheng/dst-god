AddPlayerPostInit(function(player)
    local powersys = player:AddComponent("ugsystem")
    player:ListenForEvent("oneat", function (_, data)
        for key, value in pairs(UGPOWERS.PLAYER) do
            powersys:AddEntity(value)
        end
    end)
end)