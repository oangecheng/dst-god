
local function notify(self, fn)
    if self.name and self.owner and fn then
        fn(self.owner, self.name)
    end
end


local Entity = Class(function (self, inst)
    self.inst = inst
    self.data = nil
end)


function Entity:GetData()
    return self.data
end


function Entity:PutValue(key, value)
    if self.data ~= nil then
        self.data[key] = value
    end
end


function Entity:GetValue(key)
    if self.data ~= nil then
        return self.data[key]
    end
end


function Entity:Trans(to)
    if self.data ~= nil and to.components.ugentity ~= nil then
        to.components.ugentity.data = self.data
    end
end


function Entity:SetOnAttachFn(fn)
    self.onattch = fn
end


function Entity:SetOnDetachFn(fn)
    self.ondetach = fn
end


function Entity:SetOnExtendFn(fn)
    self.onextend = fn
end


function Entity:Attach(owner, name, data)
    self.inst.owner = owner
    self.owner = owner
    self.name  = name

    -- data只赋值一次，后期交给 entity 自己维护
    if self.data == nil then
        self.data = data
    end
    notify(self, self.onattch)
end


function Entity:Detach()
    if self.owner ~= nil then
       notify(self, self.ondetach)
       self.inst.owner = nil
       self.owner = nil
       self.name  = nil
    end
end


function Entity:Extend()
    if self.owner then
        notify(self, self.onextend)
    end
end


function Entity:OnSave()
    return {
        data = self.data
    }
end


function Entity:OnLoad(data)
    self.data = data.data or nil
end


return Entity