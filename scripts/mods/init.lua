---@diagnostic disable: undefined-field

local PLAYER = UGPOWERS.PLAYER

local BLACK_NAMES = {
    wx78 = { PLAYER.SANITY, PLAYER.HEALTH, PLAYER.HUNGER }
}


local function init_player_fn(player)
    local sys = player:AddComponent("ugsystem")
    local bnames = BLACK_NAMES[player.prefab]
    if bnames ~= nil then
        sys:SetAttachTestFn(function (name, ent)
            return not table.contains(bnames, name)
        end)
    end
        
    player:AddComponent("ugsync")
    player:ListenForEvent(UGEVENTS.TASK_FINISH, function (inst, data)
        sys:RemoveEntity(data.name)
    end)
    player:DoTaskInTime(0.1, function ()
        player.components.ugsync:SyncPower()
    end)
end

AddPlayerPostInit(function(player)
    if TheWorld.ismastersim then
        init_player_fn(player)
    end 
end)





local function unload_gem_fn(doer, inst, name)
    local sys = inst.components.ugsystem
    if not (sys ~= nil and name ~= nil) then
        return
    end
    local ent = sys:RemoveEntity(name)
    if ent == nil then
        UgSay(doer, "宝石不存在")
        return
    end

    local lv = ent.components.uglevel:GetLv()
    local xp = ent.components.uglevel:GetXp()
    local da = ent.components.ugentity:GetData()

    local gem = SpawnPrefab(name .. "_gem")
    if gem ~= nil then
        gem.components.uglevel:SetLv(lv)
        gem.components.uglevel:SetXp(xp)
        gem.tempdata = da
        doer.components.inventory:GiveItem(gem)
        ent:Remove()
    end
end

local function rpc_unload_gem(player, inst, name)
    if name ~= nil and inst ~= nil then
        if TheWorld.ismastersim then
            unload_gem_fn(player, inst, name)
        else
            SendModRPCToServer(MOD_RPC.ugapi.UnLoadGem, inst, name)
        end
    end
end


local function init_equip_fn(inst)
    inst.ugunload_gem = rpc_unload_gem
    if TheWorld.ismastersim then
        inst:AddComponent("ugsystem")
        inst:AddComponent("ugsync")
        inst:DoTaskInTime(0.1, function()
            inst.components.ugsync:SyncPower()
        end)
    end
end


--添加镶嵌系统
local equips = require("defs/enhance/gems").equips
for _, v in ipairs(equips) do
    AddPrefabPostInit(v, init_equip_fn)
end