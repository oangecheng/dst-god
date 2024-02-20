local TYPE = KSG_TASKS.TYPE
local NAME = KSG_TASKS.NAME
local LIMIT = KSG_TASKS.LIMIT


-- 任务的数据结构按照如下定义
-- {
--     type = KSG_TASKS.TYPE.KILL,
--     name = KSG_TASKS.NAME.DAILY,
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
-- }


local function creatKillTask(name, demands, rewards)
    return {
        type = TYPE.KILL,
        name = name,
        demands = {
            {
                target = "spider",
                num    = 1,
                finish = false,
                -- limit  = LIMIT.MOON
            }
        },
    }
end


local function create(type, name, demands, rewards)
    return creatKillTask(name, demands, rewards)
end


return {
    fn = create
}
