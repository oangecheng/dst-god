

local prefabs = {
    "collapse_small",
}

local assets = {
    Asset("ANIM" , "anim/uggems.zip"),
    Asset("ATLAS", "images/items/uggems.xml"),
    Asset("IMAGE", "images/items/uggems.tex")
}


local function inlayfn(doer, target, gem)
    local sys =  target.components.ugsystem
    if sys ~= nil and gem.power then
        local ent = sys:GetEntity(gem.power)
        if ent ~= nil then
            return false           
        else
            local e = sys:AddEntity(gem.power)
            e.components.uglevel:SetLv(gem.components.uglevel:GetLv())
            e.components.uglevel:SetXp(gem.components.uglevel:GetXp())
        end
        return true
    end
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
        inst.AnimState:SetScale(0.4, 0.4, 0.4)
        inst.AnimState:PlayAnimation("idle")
        
        inst:AddTag(UGTAGS.GEM)
        inst:AddTag(UGTAGS.LEVEL)
        inst.power = data.power

        inst.AnimState:OverrideSymbol("swapgem", "uggems", prefab)
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("uglevel")
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
   
        inst.components.inventoryitem.imagename = prefab 
        inst.components.inventoryitem.atlasname = "images/items/uggems.xml"
        inst.components.inventoryitem:SetOnDroppedFn(function(_)
            inst.AnimState:PlayAnimation("idle")
        end)

        inst.inlayfn = inlayfn

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

