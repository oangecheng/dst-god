local TYPES  = UGTASKS.TYPE
local ATTACH = "attach"
local DETACH = "detach"
local SAVE   = "save"
local LOAD   = "load"


local function findTargetDemand(data, judge)
    -- 先查找第一个进行中的任务
    local demand = nil
    for _, v in ipairs(data.demands) do
        if v and not v.finish then
            demand = v
            break
        end
    end
    if not demand then
        return nil
    end
    
    -- 校验任务类型, 子要求没有用整个任务的type
    local type = demand.type or data.type
    if judge.type ~= type  then
        return nil
    end

    -- 校验任务目标，目标为空或者匹配
    if demand.target ~= nil and demand.target ~= judge.target then
        return nil
    end

    local inst = judge.inst
    if demand.tag ~= nil then
        if not (inst and inst:HasTag(demand.tag)) then
            return nil
        end
    end

    --- 校验限制条件，有限制条件需要满足限制条件
    local limit = demand.limit
    local extra = demand.extra
    if limit ~= nil then
        if limit == LIMIT.MOON  then
             if not TheWorld.state.isfullmoon then
                return nil
             end
        elseif limit == LIMIT.AREA then
            if not (extra and extra.area == judge.area) then
                return nil
            end
        end
    end

    return demand
end


---comment通用的任务判定
---@param owner table 玩家实例
---@param judge table 判定数据
---@param cnt number 任务判定成功之后，需要完成的目标数量
local function commonTaskCheck(owner, judge, cnt)
    local inst = owner.components.ugsystem:GetEntity(UGTASKS.NAME)
    local data = inst and inst.datafn()
    if not data then
        UgLog("taskcheck, empty data")
        return
    end
    local demand = findTargetDemand(data, judge)
    if demand ~= nil then
        demand.num = demand.num - cnt
        if demand.num < 1 then
            demand.finish = true
        end
    end
    -- 找下个任务
    local next = nil
    for _, v in ipairs(data.demands) do
        if v and not v.finish then
            demand = v
            break
        end
    end

    -- 任务全部做完了，推送任务完成事件
    if not next then
        inst.components.ksg_task:Win()
    else
        -- 否则刷新下面板
        if demand then
            inst.components.ksg_task:Update()
        end
    end
end



local function onKillOther(killer, data)
    local victim = data.victim
    local judge = { target = victim.prefab, type = TYPES.KILL }
    commonTaskCheck(killer,judge, 1)
end



local kill = {
    startfn = function (owner, data)
        owner:ListenForEvent("killed", onKillOther)
    end,
    stopfn = function (owner, data)
        owner:RemoveEventCallback("killed", onKillOther)
    end
}



return {
    [TYPE.KILL] = kill
}