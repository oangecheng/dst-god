

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

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(data.build)
        local scale = data.scale or 1
        inst.AnimState:SetScale(scale, scale, scale)
        inst.AnimState:PlayAnimation("idle", data.loop)
        
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

        inst.components.inventoryitem.imagename = data.image
        inst.components.inventoryitem.atlasname = "images/items/"..data.atlas..".xml"

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = data.stacksize or TUNING.STACK_SIZE_SMALLITEM
        return inst
    end

    return Prefab(prefab, fn, data.assets, prefabs)
end

local items = {}

local NORMAL = require("defs/items/ugi")
for k, v in pairs(NORMAL) do
    table.insert(items, MakeItem(k, v))
end


return unpack(items)

