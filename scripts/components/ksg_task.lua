
local function notify(self, fn)
    if self.type and self.taskdata and self.owner and fn then
        fn(self.type, self.taskdata, self.owner)
    end
end


local function onTaskData(self, data)
    if data then
        if self.owner and self.type then
            self:Start(self.type, self.owner)
        end
    end
end



local Task = Class(function (self, inst)
    self.inst = inst
    self.owner = nil
    self.taskdata = nil
end,
nil,
{
    taskdata = onTaskData
})


---comment 设置开启监听
---@param fn function
function Task:SetOnStartFn(fn)
    self.onStartFn = fn
end

---comment 设置成功监听
---@param fn function
function Task:SetOnWinFn(fn)
    self.onWinFn = fn
end

---comment 设置失败监听
---@param fn function
function Task:SetOnLoseFn(fn)
    self.onLoseFn = fn
end

---comment 设置任务结束监听
---@param fn function
function Task:SetOnStopFn(fn)
    self.onStopFn = fn
end


---comment 设置任务的数据
---@param data table|nil
function Task:SetData(data)
    if data then
        self.taskdata = data
    end
end


---comment获取任务数据
---@return table|nil
function Task:GetData()
    return self.taskdata
end


---comment 开始任务
---@param type string
---@param owner table
function Task:Start(type, owner)
    self.owner = owner
    self.inst.owner = owner
    self.type = type
    notify(self, self.onStartFn)
end


---comment 结束任务
---@param type string
function Task:Stop(type)
    notify(self, self.onStopFn)
    self.owner = nil
    self.type = nil
    self.inst.owner = nil
end


function Task:Update()
    if self.owner ~= nil then
        self.owner:PushEvent(KSG_EVENTS.TASK_UPDATE)
    end
end


---comment 任务成功
function Task:Win()
    notify(self, self.onWinFn)
    if self.owner and self.type and self.taskdata then
        local data = { type = self.type, win = true, task = self.taskdata}
        self.owner:PushEvent(KSG_EVENTS.TASK_FINISH, data)
    end
end


---comment 任务失败
function Task:Lose()
    notify(self, self.onLoseFn)
    if self.owner and self.type and self.taskdata then
        local data = { type = self.type, win = false, task = self.taskdata}
        self.owner:PushEvent(KSG_EVENTS.TASK_FINISH, data)
    end
end


function Task:OnSave()
    return {
        taskdata = self.taskdata
    }
end


function Task:OnLoad(data)
    self.taskdata = data.taskdata
end


return Task