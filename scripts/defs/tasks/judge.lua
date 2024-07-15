local TYPES  = UGTASKS.TYPES
local LIMIT  = UGTASKS.LIMIT

local ATTACH = "attach"
local DETACH = "detach"

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
---@param name string 任务名称
---@param judge table 判定数据
local function commonTaskCheck(owner, name, judge)
    local inst = owner.components.ugsystem:GetEntity(name)
    local data = inst and inst.datafn()
    if not data then
        UgLog("taskcheck, empty data")
        return
    end
    local demand = findTargetDemand(data, judge)
    if demand ~= nil then
        demand.num = demand.num - (judge.cnt or 1)
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
        inst.winfn()
    else
        -- 否则刷新下面板
        if demand then
            inst.updatefn()
        end
    end
end


local function checkfn(owner, judge)
    if owner.ugtask ~= nil then
        commonTaskCheck(owner, owner.ugtask, judge)
    end
end




--------------------------------------------------------------------------*--------------------------------------------------------------------------
local on_kill_other = function(inst, data)
    local judge = { target = data.victim.prefab, type = TYPES.KILL }
    checkfn(inst, judge)
end

local _kill = {
    [ATTACH] = function (inst, owner)
        owner:ListenForEvent("killed", on_kill_other)
    end,
    [DETACH] = function (inst, owner)
        owner:RemoveEventCallback("killed", on_kill_other)
    end
}




--------------------------------------------------------------------------*--------------------------------------------------------------------------
local function on_fish(inst, data)
    local judge = { 
        type  = TYPES.FISH,
        arget = data.finish 
    }
    if data.isocean then
        judge.extra = {
            area = "ocean"
        }
    end
    checkfn(inst, judge)
end

local _fish = {
    [ATTACH] = function(inst, owner, name)
        owner:ListenForEvent(UGEVENTS.FISH_SUCCESS, on_fish)
    end,
    [DETACH] = function(inst, owner, name)
        owner:RemoveEventCallback(UGEVENTS.FISH_SUCCESS, on_fish)
    end
}


return {
    [TYPES.KILL] = _kill,
    [TYPES.FISH] = _fish,
}
