
local function ongodchange(self, god)
    if self.ongodfn then
        self.ongodfn()
    end
end


local God = Class(
    function (self, inst)
        self.inst = inst
        self.god = 1
        self.max = 4
    end,
    nil,
    {
        god = ongodchange
    }
)


---comment 设置等阶提升回调
---@param fn function
function God:SetOnGodFn(fn)
    self.ongodfn = fn
end


---comment 判断是否是真神
---@return boolean
function God:IsGod()
    return self.god >= self.max
end


---comment 提升等阶
function God:Upgrade()
    local god = math.min(self.max, self.god + 1)
    if self.god ~= god then
        self.god = god
    end
end


function God:OnLoad(data)
    self.god = data.god
end


function God:OnSave()
    return {
        god = self.god
    }
end


return God