
local Mark = Class(function (self, inst)
    self.inst = inst
    self.marks = {}
    self.fns = {}
end)


function Mark:Put(key, value)
    self.marks[key] = value
    local fn = self.fns[key]
    if fn ~= nil then
        fn(value)
    end
end


function Mark:SetFunc(key, fn)
    self.fns[key] = fn
end


function Mark:Get(key)
    return self.marks[key]
end


function Mark:Clear(key)
    self.marks[key] = nil
end


function Mark:Poll(key)
    local v = self:Get(key)
    self.marks[key] = nil
    return v
end


function Mark:OnSave()
    return {
        marks = self.marks
    }
end


function Mark:OnLoad(data)
    self.marks = data.marks or {}
    for k, v in pairs(self.marks) do
        local fn = self.fns[k]
        if fn ~= nil then
            fn(v)
        end
    end
end



return Mark