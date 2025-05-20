local DIR = "images/inventoryimages/"
local TYPE_BOX = 2


local function join_list(ret, array)
    if array ~= nil and next(array) ~= nil then
        for _, v in ipairs(array) do
            table.insert(ret, v)
        end
    end
end


---comment
---@return table
local function assets_prefab_fn(anim, xml, tex)
    return {
        Asset("ANIM", "anim/" .. anim .. ".zip"),
        Asset("ATLAS", DIR .. xml .. ".xml"),
        Asset("IMAGE", DIR .. tex .. ".tex")
    }
end



local common_items = {

    {
        name = "uggem_piece",
        data = {
            assets = assets_prefab_fn("ugitems", "ugitems", "uggem_piece"),
            stack  = TUNING.STACK_SIZE_SMALLITEM,
            bank   = "ugitems",
            build  = "ugitems",
            scale  = 0.5,
            loop   = true,
            tags   = { "molebait" },
            image  = "ugitems",
            atlas  = "uggem_piece",
            initfn = function(inst, prefab)
                inst.AnimState:OverrideSymbol("swap_item", "ugitems", "uggem_piece")
            end
        }
    },

    {
        name = "ugmagic_plant_energy",
        data = {
            assets = assets_prefab_fn("ugitems", "ugitems", "ugmagic_plant_energy"),
            stack  = TUNING.STACK_SIZE_SMALLITEM,
            bank   = "ugitems",
            build  = "ugitems",
            tags   = { UGTAGS.MAGIC_ITEM },
            image  = "ugitems",
            atlas  = "ugmagic_plant_energy",

            initfn = function(inst, prefab)
                inst.AnimState:OverrideSymbol("swap_item", "ugitems", "ugmagic_plant_energy")
            end,
            
            giveto = function(inst, target, doer)
                ---@diagnostic disable-next-line: undefined-field
                if table.contains(UGMAGICS.PLANT_ENERGY_TARGETS, target.prefab) then
                    local pos = target:GetPosition()
                    local new_plant = SpawnPrefab(target.prefab)
                    if new_plant ~= nil then
                        target:Remove()
                        new_plant.Transform:SetPosition(pos:Get())
                        return true
                    end
                end
            end
        }
    },

    {
        name   = "ugmagic_meat_rack",
        assets = assets_prefab_fn("ugitems", "ugitems", "ugmagic_meat_rack"),
        stack  = TUNING.STACK_SIZE_SMALLITEM,
        bank   = "ugitems",
        build  = "ugitems",
        tags   = { UGTAGS.MAGIC_ITEM },
        image  = "ugitems",
        atlas  = "ugmagic_meat_rack",

        initfn = function(inst, prefab)
            inst.AnimState:OverrideSymbol("swap_item", "ugitems", "ugmagic_meat_rack")
        end,
        giveto = function(inst, target, doer)
            ---@diagnostic disable-next-line: undefined-field
            if target.components.uglevel ~= nil then
                target.components.uglevel:LvDelta(1)
                return true
            end
        end
    }

}


return common_items


