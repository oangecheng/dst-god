
local DIR = "images/inventoryimages/ugitems"


local assests = {
    Asset("ANIM" , "anim/ugitems.zip"),
    Asset("ATLAS", DIR..".xml"),
    Asset("IMAGE", DIR..".tex")
}


local prefabs = {
    "collapse_small",
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

        inst.AnimState:SetBank("ugitems")
        inst.AnimState:SetBuild("ugitems")
        local scale = data.scale or 1
        inst.AnimState:SetScale(scale, scale, scale)
        inst.AnimState:PlayAnimation("idle", data.loop)
        inst.AnimState:OverrideSymbol("swap_item", "ugitems", prefab)

        if data.tags then
            for _, v in ipairs(data.tags) do
                inst:AddTag(v)
            end
        end

        if data.initfn then
            data.initfn(inst, prefab, TheWorld.ismastersim)
        end


        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem:SetOnDroppedFn(function(_)
            inst.AnimState:PlayAnimation("idle", data.loop)
        end)

        inst.components.inventoryitem.imagename = prefab
        inst.components.inventoryitem.atlasname = DIR..".xml"

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = data.stacksize or TUNING.STACK_SIZE_SMALLITEM

        inst.givefn = data.givefn
        inst.usefn = data.usefn

        return inst
    end

    return Prefab(prefab, fn, assests, prefabs)
end

local items = {}

local NORMAL = require("defs/items/inventory")
for k, v in pairs(NORMAL) do
    table.insert(items, MakeItem(k, v))
end


return unpack(items)

