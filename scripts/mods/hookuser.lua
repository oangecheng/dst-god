

AddPlayerPostInit(function(player)
    if not TheWorld.ismastersim then
        return
    end
    local sys = player:AddComponent("ugsystem")
    player:AddComponent("ugsync")
    player:ListenForEvent(UGEVENTS.TASK_FINISH, function (inst, data)
        sys:RemoveEntity(data.name)
    end)
    player:DoTaskInTime(0.1, function ()
        player.components.ugsync:SyncPower()
    end)
    for _, v in pairs(UGPOWERS.PLAYER) do
        sys:AddEntity(v)
    end
end)



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


--添加镶嵌系统
local equips = require("defs/enhance/gems").equips
for _, v in ipairs(equips) do
    AddPrefabPostInit(v, function(inst)
        
        if TheWorld.ismastersim then
            inst:AddComponent("ugsystem")
            inst:AddComponent("ugsync")

            inst:DoTaskInTime(0.1, function()
                inst.components.ugsync:SyncPower()
            end)
        end

        inst.ugunload_gem = function(doer, inst, powername)
            if powername ~= nil and inst ~= nil then
                if TheWorld.ismastersim then
                    unload_gem_fn(doer, inst, powername)
                else
                    SendModRPCToServer(MOD_RPC.ugapi.UnLoadGem, inst, powername)
                end
            end
        end
    end)
end
