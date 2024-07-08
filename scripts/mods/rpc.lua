
AddModRPCHandler(
    "ugapi",
    "UnLoadGem",
    function (player, inst, powername)
        inst.ugunload_gem(player, inst, powername)
    end
)



local function unload_gem_fn(doer, inst, powername)
    local sys = inst.components.ugsystem
    if sys and powername then
        local ent = sys:RemoveEntity(powername)
        if ent ~= nil then
            local lv = ent.components.uglevel:GetLv()
            local xp = ent.components.uglevel:GetXp()
            local gem = SpawnPrefab(powername.."_gem")
            if gem ~= nil then
                gem.components.uglevel:SetLv(lv)
                gem.components.uglevel:SetXp(xp)
                doer.components.inventory:GiveItem(gem)
                ent:Remove()
            end
        end
    end
end

AddPrefabPostInit("spear", function(item)
    item.ugunload_gem = function(doer, inst, powername)
        if powername ~= nil and inst ~= nil then
            if TheWorld.ismastersim then
                unload_gem_fn(doer, inst, powername)
            else
                SendModRPCToServer(MOD_RPC.ugapi.UnLoadGem, inst, powername)
            end
        end
    end
end)
