
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
local AWARD = UGTASKS.AWARD


local function task_kill(player, name, star)
    return {
        name = NAMES.DAILY,
        type = TYPES.KILL,
        demands = {
            {
                target = "spider",
                num = 1,
            }
        },
        rewards = {
            {
                type = AWARD.ITEM,
                target = "cutgrass",
                num = 1,
            },
        }
    }
end



local FISH_DEF = {
    "wobster_moonglass",
    "wobster_sheller",
    "eel",
}
local function task_fish(player, name, star)
    return {
        name = NAMES.DAILY,
        type = TYPES.FISH,
        demands = {
            {
                target = "eel",
                limit = LIMIT.MOON,
                num = 1,
            }
        }
    }
end


return {
    taskfn = task_kill
}