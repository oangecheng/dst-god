local DIR = "images/items/"

local ITEMS = {}

local function assestsfn(prefab)
    return {
        Asset("ANIM" , "anim/"..prefab..".zip"),
        Asset("ATLAS", DIR..prefab..".xml"),
        Asset("IMAGE", DIR..prefab..".tex")
    }
end


local GEMS = {}
for k, v in pairs(UGPOWERS.EQUIPS) do
    table.insert(GEMS, v.."_gem")
end

local GEMS_FILE = "uggems"
for _, v in ipairs(GEMS) do
    ITEMS[v] = {
        assets = assestsfn(GEMS_FILE),
        bank   = GEMS_FILE,
        build  = GEMS_FILE,
        scale  = 0.4,
        loop   = false,
        tags   = { "UGGEM" },
        atlas  = GEMS_FILE,
        image  = v,
        initfn = function (inst)
            inst.AnimState:OverrideSymbol("swapgem", "uggems", v)
        end
    }
end


return ITEMS