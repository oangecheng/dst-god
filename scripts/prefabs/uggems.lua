

local prefabs = {
    "collapse_small",
}

local assets = {
    Asset("ANIM" , "anim/uggems.zip"),
    Asset("ATLAS", "images/inventoryimages/uggems.xml"),
    Asset("IMAGE", "images/inventoryimages/uggems.tex")
}

local enhance = require("defs/uggems_def")


---comment 镶嵌函数
---@param doer table 玩家
---@param target table 目标装备
---@param gem table 宝石
---@return boolean true 镶嵌成功
local function inlayfn(doer, target, gem)
    local sys = target.components.ugsystem
    -- 合法性校验
    if sys == nil or gem.power == nil then
        return false
    end
    -- 判断能不能添加，属性是否匹配
    if not enhance.caninlayfn(target, gem.power) then
        return false
    end

    -- 已有的不能重复添加
    local ent = sys:GetEntity(gem.power)
    if ent ~= nil then
        return false
    end

    local e = sys:AddEntity(gem.power, gem.tempdata)
    e.components.uglevel:SetLv(gem.components.uglevel:GetLv())
    e.components.uglevel:SetXp(gem.components.uglevel:GetXp())
    return true
end



local function MakeItem(prefab, data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()
        inst.entity:SetPristine()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("uggems")
        inst.AnimState:SetBuild("uggems")
        inst.AnimState:SetScale(0.6, 0.6, 0.6)
        inst.AnimState:PlayAnimation("idle", true)
        
        inst:AddTag(UGTAGS.GEM)
        inst:AddTag(UGTAGS.LEVEL)
        inst.power = data.power

        inst.AnimState:OverrideSymbol("swap_item", "uggems", prefab)
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("uglevel")
        inst.components.uglevel.expfn = data.xpfn
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.tempdata = nil
   
        inst.components.inventoryitem.imagename = prefab 
        inst.components.inventoryitem.atlasname = "images/inventoryimages/uggems.xml"
        inst.components.inventoryitem:SetOnDroppedFn(function(_)
            inst.AnimState:PlayAnimation("idle", true)
        end)

        inst.inlayfn = inlayfn
        inst.enhancefn = function (item)
            return enhance.enhancefn(inst, item, data.power)
        end

        inst.OnSave = function (_, d)
            d.tempdata = inst.tempdata
        end
        inst.OnLoad = function (_, d)
            inst.tempdata = d.tempdata
        end

        return inst
    end

    return Prefab(prefab, fn, assets, prefabs)
end


local items = {}
local NORMAL = require("defs/items/gemsdef")
for k, v in pairs(NORMAL) do
    table.insert(items, MakeItem(k, v))
end
return unpack(items)

