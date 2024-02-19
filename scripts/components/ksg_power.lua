
local function notify(self, fn)
    if self.name and self.owner and fn then
        fn(self.name, self.owner)
    end
end


local Power = Class(function (self, inst)
    self.inst = inst
    self.datas = {}
end)


---comment 设置绑定监听
---@param fn function
function Power:SetOnBindFn(fn)
    self.onBindFn = fn
end


---comment 设置解绑监听
---@param fn function
function Power:SetOnUnbindFn(fn)
    self.onUnbindFn = fn
end


---comment 绑定属性
---@param name string
---@param owner table
function Power:Bind(name, owner)
    self.name = name
    self.owner = owner
    self.inst.owner = owner
    notify(self, self.onBindFn)
end


---comment 解绑属性
function Power:Unbind()
    notify(self, self.onUnbindFn)
    self.name = nil
    self.owner = nil
    self.inst.owner = nil
end


---comment 存储数据
---@param key string
---@param data any
function Power:Save(key, data)
    self.datas[key] = data
end


---comment 取缓存的数据
---@param key any
---@return any
function Power:Get(key)
    return self.datas[key]
end



function Power:OnSave()
    return {
        datas = self.datas
    }
end


function Power:OnLoad(data)
    self.datas = data.datas or {}
end


return Power