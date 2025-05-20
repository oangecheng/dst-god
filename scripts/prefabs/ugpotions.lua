
local DIR = "images/inventoryimages/ugpotions"


local assests = {
    Asset("ANIM" , "anim/ugpotions.zip"),
    Asset("ATLAS", DIR..".xml"),
    Asset("IMAGE", DIR..".tex")
}


local prefabs = {
    "collapse_small",
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
        inst.AnimState:SetBank("ugpotions")
        inst.AnimState:SetBuild("ugpotions")
        inst.AnimState:PlayAnimation("idle", true)
        inst.AnimState:OverrideSymbol("swap_item", "ugpotions", power)

        inst:AddTag(UGTAGS.POTION)

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem:SetOnDroppedFn(function(_)
            inst.AnimState:PlayAnimation("idle", true)
        end)

        inst.components.inventoryitem.imagename = power
        inst.components.inventoryitem.atlasname = DIR..".xml"

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM


        inst.drinkfn = function(doer)
            local sys = doer.components.ugsystem
            if sys ~= nil then
                local ent = sys:GetEntity(power)
                if ent == nil then
                    sys:AddEntity(power)
                    return true
                end
            end
            return false
        end

        return inst
    end

    return Prefab(prefab, fn, assests, prefabs)
end

local items = {}

local NORMAL = UGPOWERS.PLAYER
for _, v in pairs(NORMAL) do
    table.insert(items, MakeItem(v.."_potion", v))
end


return unpack(items)

