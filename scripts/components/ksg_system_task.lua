local TASK_PREFAB = "ksg_task"


local function addTask(self, type, ent, data)
    if ent.components.ksg_task then
        self.tasks[type] = { inst = ent }
        ent.persists = false
        ent.components.ksg_task:SetData(data)
        ent.components.ksg_task:Start(type, self.inst)
    else
        ent:Remove()
    end
end


local System = Class(function (self, inst)
    self.inst = inst
    self.tasks = {}
end)


---comment 新增任务
---@param type string 任务类型
---@param data table 任务数据
---@return table|nil 任务实体
function System:AddTask(type, data)
    local task = self.tasks[type]
    local ret = nil
    if task == nil then
        local ent = SpawnPrefab(TASK_PREFAB)
        if ent then
            addTask(self, type, ent, data)
        end
        ret = ent
    else
        ret = task.inst
    end
    return ret
end


---comment 彻底移除一个任务
---@param type string 任务的类型
function System:RemoveTask(type)
    local task = self.tasks[type]
    if task ~= nil then
        self.tasks[type] = nil
        if task.inst.components.ksg_task then
            task.inst.components.ksg_task:Stop()
        end
        -- 移除实体
        task.inst:Remove()
    end
end



function System:OnSave()
    if next(self.tasks) == nil then return end
    local data = {}
    for k, v in pairs(self.tasks) do
        local saved--[[, refs]] = v.inst:GetSaveRecord()
        data[k] = saved
    end
    return { tasks = data }
end



function System:OnLoad(data)
    if data ~= nil and data.tasks ~= nil then
        for k, v in pairs(data.tasks) do
            if self.tasks[k] == nil then
                local ent = SpawnSaveRecord(v)
                if ent ~= nil then
                    addTask(self, k, ent)
                end
            end
        end
    end
end



return System