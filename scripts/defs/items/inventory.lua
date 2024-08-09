

--- 建家石
local GEM_PIECE = "uggem_piece"
local gem_piece = {
    tags  = { "molebait" },
    scale = 0.5
}


return {
    [GEM_PIECE] = gem_piece,
    ["ugmagic_plant_energy"] = {
        tags = { UGTAGS.ENERGY },
        givefn = function (inst, target, doer)
            local pickable = target.components.pickable
            if pickable == nil or not pickable.transplanted then
                return false
            end
            pickable.cycles_left = nil
            pickable.transplanted = nil
            return true
        end

    }
}