

--- 宝石碎片
local GEM_PIECE = "uggem_piece"
local gem_piece = {
    tags  = { "molebait" },
    scale = 0.5
}


--- 这几个植物多次采集会枯萎，可以使用药水
local plants = {
    "berrybush", "berrybush2", "berrybush_juicy", "grass", "bananabush"
}

--- 植物精华
local PLANT_ENERGY  = { key = "ugmagic_plant_energy" }
PLANT_ENERGY.tags   = { UGTAGS.MAGIC_ITEM }
PLANT_ENERGY.givefn = function(inst, target, doer)
    if table.contains(plants, target.prefab) then
        local pos = target:GetPosition()
        local new_plant = SpawnPrefab(target.prefab)
        if new_plant ~= nil then
            target:Remove()
            new_plant.Transform:SetPosition(pos:Get())
            return true
        end
    end
end


--- 晾肉架升级包
local MAGIC_MEAT_RACK = { key = "ugmagic_meat_rack"}
MAGIC_MEAT_RACK.tags  = { UGTAGS.MAGIC_ITEM }
MAGIC_MEAT_RACK.givefn = function (inst, target, doer)
    if target.components.uglevel ~= nil then
        target.components.uglevel:LvDelta(1)
        return true
    end
end


return {
    [GEM_PIECE] = gem_piece,
    [PLANT_ENERGY.key] = PLANT_ENERGY,
    [MAGIC_MEAT_RACK.key] = MAGIC_MEAT_RACK,
}