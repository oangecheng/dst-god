-- name,--配方名，一般情况下和需要合成的道具同名
-- ingredients,--配方，这边为了区分不同难度的配方，做了嵌套{{正常难度},{简易难度}}，只填一个视为不做难度区分
-- level,--解锁科技
-- --placer,--建筑类科技放置时显示的贴图、占位等/也可以配List用于添加更多额外参数，比如不可分解{no_deconstruction = true}
-- --min_spacing,--最小间距，不填默认为3.2
-- --nounlock,--不解锁配方，只能在满足科技条件的情况下制作(分类默认都算专属科技站,不需要额外添加了)
-- --numtogive,--一次性制作的数量，不填默认为1
-- --builder_tag,--制作者需要拥有的标签
-- --atlas,--需要用到的图集文件(.xml)，不填默认用images/name.xml
-- --image,--物品贴图(.tex)，不填默认用name.tex
-- --testfn,--尝试放下物品时的函数，可用于判断坐标点是否符合预期
-- --product,--实际合成道具，不填默认取name
-- --build_mode,--建造模式,水上还是陆地(默认为陆地BUILDMODE.LAND,水上为BUILDMODE.WATER)
-- --build_distance,--建造距离(玩家距离建造点的距离)
-- --filters,--制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}

-- --扩展字段
-- placer,--建筑类科技放置时显示的贴图、占位等
-- filter,--制作栏分类
-- description,--覆盖原来的配方描述
-- canbuild,--制作物品是否满足条件的回调函数,支持参数(recipe, self.inst, pt, rotation),return 结果,原因
-- sg_state,--自定义制作物品的动作(比如吹气球就可以调用吹的动作)
-- no_deconstruction,--填true则不可分解(也可以用function)
-- require_special_event,--特殊活动(比如冬季盛宴限定之类的)
-- dropitem,--制作后直接掉落物品
-- actionstr,--把"制作"改成其他的文字
-- manufactured,--填true则表示是用制作站制作的，而不是用builder组件来制作(比如万圣节的药水台就是用这个)

local ITEM_DIR = "images/inventoryimages/"

local UGITEM_ATLAS = {
    uggem_piece = ITEM_DIR.."ugitems.xml"
}


local function ingredients_fn(ingredients)
    local ret = {}
    for k, v in pairs(ingredients) do
        local atlas = UGITEM_ATLAS[k]
        local i = atlas ~= nil and Ingredient(k, v, atlas) or Ingredient(k, v)
        table.insert(ret, i)
    end
    return ret
end


local function data_fn(prefab, filename, data)
    return {
        atlas = ITEM_DIR..filename..".xml",
        image = prefab..".tex",
    }
end


local function add_recipe_fn(prefab, filename, tech, filters, ingredients, data)
    AddRecipe2(
        prefab, 
        ingredients_fn(ingredients), 
        tech,
        data_fn(prefab, filename, data),
        filters
    )
end


---comment 添加配方，普通物品
---@param prefab string 代码
---@param tech number 科技等级
---@param filters table tab
---@param ingredients table 配方
---@param data table|nil 补充数据
local function add_normal_recipe(prefab,  tech, filters, ingredients, data)
    add_recipe_fn(prefab, "ugitems", tech, filters, ingredients, data)
end



local GEMS = require("defs/items/gemsdef")
---comment 添加宝石的合成配方
---@param power string 属性名称
---@param ingredients table 额外配方
---@param data any
local function add_gem_recipe(power, ingredients, data)
    local gem = power.."_gem"
    local rarity = GEMS[gem].rarity or UGRARITY.WHITE
    ingredients["uggem_piece"] = rarity * 5
    add_recipe_fn(gem, "uggems", TECH.SCIENCE_TWO, { "REFINE" }, ingredients, data)
end


local EQUIPS = UGPOWERS.EQUIPS
add_gem_recipe(EQUIPS.ABSORB, { armorgrass = 1, armorwood = 1, armormarble = 1 })  -- 草甲x1 木甲x1  大理石甲x1
add_gem_recipe(EQUIPS.BLINDR, { townportaltalisman = 10 })
add_gem_recipe(EQUIPS.CHOPER, { goldenaxe = 1, log = 20 })
add_gem_recipe(EQUIPS.CRITER, { houndstooth = 10 })
add_gem_recipe(EQUIPS.DAMAGE, { ruins_bat = 1, nightsword = 1, glasscutter = 1 })
add_gem_recipe(EQUIPS.DAPPER, { walrushat = 1, spiderhat = 1 })


