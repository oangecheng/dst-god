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
    if TheWorld.ismastersim and player.prefab ~= "ugfoxgirl" then
        init_player_fn(player)
    end 
end)





AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst:ListenForEvent("ms_playerdespawnanddelete", function(_, player)
        inst.sys = player.components.ugsystem
        UgLog("player delete", inst.sys)
    end)

    inst:ListenForEvent("ms_newplayerspawned", function(_, player)
        UgLog("player spawn", inst.sys)
        if inst.sys then
           inst.sys:Transform(player)
        end
    end)
end)



--添加镶嵌系统
local GEMS_DEF = require("defs/uggems_def")


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
        if inst.components.ugsync then
            inst.components.ugsync:SyncPower()
        end
    end
end




local items = GEMS_DEF.items


--获取堆叠数量
local function GetStackSize(item)
    return item.components.stackable ~= nil and item.components.stackable:StackSize() or 1
end


---comment 尝试消耗
---@param user table 玩家
---@param target_prefab string 
---@return table|nil 数量
local function consum_items(user, target_prefab)
    local inventory = user.components.inventory
    if not inventory then
        return nil
    end

    local temp = inventory:FindItem(function (i) return i.prefab == target_prefab end)

    local cnt = 0
    if temp ~= nil then
        cnt = GetStackSize(temp)
    end
    return {
        item = temp,
        cnt  = cnt
    }
end

local function upgrade_gem(doer, inst, name)
    local sys = inst.components.ugsystem
    if not (sys ~= nil and name ~= nil) then
        return
    end
    local ent = sys:GetEntity(name)
    if ent == nil then
        UgSay(doer, "宝石不存在")
        return
    end

    local is = items[name]
    if is ~= nil then
        for k, v in pairs(is) do
            local d = consum_items(doer, k)
            if d ~= nil and d.cnt > 0 then
                local exp = d.cnt * v
                ent.components.uglevel:XpDelta(exp)
                if d.item ~= nil then
                    d.item:Remove()
                end
                -- 每次只升级一次
                return
            end
        end
    end
end




local function rpc_unload_gem(player, inst, name, mode)
    if name ~= nil and inst ~= nil then
        if TheWorld.ismastersim then
            if mode == 1 then
                unload_gem_fn(player, inst, name)
            elseif mode == 2 then
                upgrade_gem(player, inst, name)
            end
        else
            SendModRPCToServer(MOD_RPC.ugapi.UnLoadGem, inst, name, mode)
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
local equips = GEMS_DEF.equips
for _, v in ipairs(equips) do
    AddPrefabPostInit(v, init_equip_fn)
end





local berrybushs = {
    "berrybush_juicy",
    "berrybush",
    "berrybush2"
}
for _, v in ipairs(berrybushs) do
    AddPrefabPostInit(v, function (inst)
        inst:AddTag(UGTAGS.MAGIC_TARGET)
    end)
end
