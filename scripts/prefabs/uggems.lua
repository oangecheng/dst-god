

local prefabs = {
    "collapse_small",
}

local assets = {
    Asset("ANIM" , "anim/uggems.zip"),
    Asset("ATLAS", "images/inventoryimages/uggems.xml"),
    Asset("IMAGE", "images/inventoryimages/uggems.tex")
}


local function MakeItem(prefab, power)
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
        inst.power = power

        inst.AnimState:OverrideSymbol("swap_item", "uggems", prefab)
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("ugmark")
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.tempdata = nil
   
        inst.components.inventoryitem.imagename = prefab 
        inst.components.inventoryitem.atlasname = "images/inventoryimages/uggems.xml"
        inst.components.inventoryitem:SetOnDroppedFn(function(_)
            inst.AnimState:PlayAnimation("idle", true)
        end)

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
local NORMAL = UGPOWERS.EQUIPS
for k, v in pairs(NORMAL) do
    table.insert(items, MakeItem(v.."_gem", v))
end
return unpack(items)

