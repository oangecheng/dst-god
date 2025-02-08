
AddModRPCHandler(
    "ugapi",
    "UnLoadGem",
    function (player, inst, powername, mode)
        inst.ugunload_gem(player, inst, powername, mode)
    end
)

