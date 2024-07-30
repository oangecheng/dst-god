
local Mark = Class(function (self, inst)
    self.inst = inst
    self.marks = {}
end)


function Mark:Put(key, value)
    self.marks[key] = value
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
end



return Mark