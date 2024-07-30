

local prefabs = {
    "collapse_small",
}

local PREFIX = "ugblueprints_"

local assets = {
    Asset("ANIM" , "anim/ugblueprints.zip"),
    Asset("ATLAS", "images/inventoryimages/ugblueprints.xml"),
    Asset("IMAGE", "images/inventoryimages/ugblueprints.tex")
}





local function MakeItem(prefab, data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()
        inst.entity:SetPristine()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("ugblueprints")
        inst.AnimState:SetBuild("ugblueprints")
        inst.AnimState:SetScale(0.6, 0.6, 0.6)
        inst.AnimState:PlayAnimation("idle")
        
        inst:AddTag(UGTAGS.BLUEPRINTS)
        inst:AddTag(UGTAGS.LEVEL)

        inst.AnimState:OverrideSymbol("ugblueprints_meatrack", "ugblueprints", prefab)
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("uglevel")
        inst.components.uglevel:SetLv(1)
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
   
        inst.components.inventoryitem.imagename = prefab 
        inst.components.inventoryitem.atlasname = "images/inventoryimages/ugblueprints.xml"
        inst.components.inventoryitem:SetOnDroppedFn(function(_)
            inst.AnimState:PlayAnimation("idle")
        end)

        inst.upgradefn = function (doer, target)
            if target.components.uglevel ~= nil then
                local lv = inst.components.uglevel:GetLv()
                target.components.uglevel:LvDelta(lv)
                return true
            end
        end

        return inst
    end

    return Prefab(prefab, fn, assets, prefabs)
end


local items = {}
local NORMAL = require("defs/items/blueprints")
for k, v in pairs(NORMAL) do
    local name = PREFIX..k
    table.insert(items, MakeItem(name, v))
end
return unpack(items)

