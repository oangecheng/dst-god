-- 任务的数据结构按照如下定义
-- {
--     type = TYPES.KILL,
--     name = NAMES.DAILY,
--     star = STARS.S
--     time = 0
--     demands = {
--        {
--             type   = KSG_TASKS.TYPE.KILL
--             target = "spider" | nil
--             tag    = "tree" | nil
--             finish = false
--             num    = 1,
--             limit  = 1,
--             extra  = {} | nil
--         }
--     },
--     奖励可能是随机生成的，也可能一开始就给定了
--     rewards = {
--        {
--             type = 1,
--             num  = 1,
--             name = "cutgrass"
--        }
--      }
--     punish = {
--         type = 1
--      }
-- }
local TYPES = UGTASKS.TYPES
local LIMIT = UGTASKS.LIMIT
local NAMES = UGTASKS.NAMES
local STRS  = STRINGS.UGTASK_STRS

local DEFS  = require("task/defs")


local function reward_fn(star)
    return DEFS.rewardfn(star)
end


local function demand_kill_fn(star)
    local mon, num = DEFS.monsterfn(star)
    return {
        type   = TYPES.KILL,
        target = mon,
        num    = num,
        strfn  = function(data)
            local title = STRS.DEMAND
            local str = STRS.KILL..UgName(data.target).."x"..tostring(data.num)
            return title.."\n"..str
        end
    }
end


local function demand_fish_fn(star)
    local fish, num = DEFS.fishfn(star)
    return {
        target = fish,
        limit = LIMIT.MOON,
        num = num,
    }
end


return {
    taskfn = nil
}