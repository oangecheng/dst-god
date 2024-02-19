
local function addPower(self, name, ent)
    if ent.components.ksg_power then
        self.powers[name] = {
            inst = ent,
        }
        ent.persists = false
        ent.components.ksg_power:Bind(name, self.inst)
    else
        ent:Remove()
    end
end


local System = Class(function (self, inst)
    self.inst = inst
    self.powers = {}
end)



function System:SetOnGainFn(fn)
    self.onGainFn = fn
end


function System:SetOnLostFn(fn)
    self.onLostFn = fn
end



---comment 新增一个属性
---对于一个inst，同一种属性只能添加一次
---@param name string 属性名称
function System:AddPower(name)
    local existed = self.powers[name]
    local ret = nil
    if existed == nil then
        local ent = SpawnPrefab("ksg_power_"..name)
        if ent then
            addPower(self, name, ent)
            if self.onGainFn then
                self.onGainFn(name, ent)
            end
        end
        ret = ent
    else
        ret = existed.inst
    end
    return ret
end


---comment 彻底移除一个属性
---这个属性会被永久移除
---@param name string 属性名称
function System:RemovePower(name)
    local power = self.powers[name]
    if power ~= nil then
        self.powers[name] = nil
        power.inst.components.ksg_power:Unbind()
        if self.onLostFn then
            self.onLostFn(name, power.inst)
        end
        self.inst:DoTaskInTime(0, power.inst:Remove()) 
    end
end



function System:OnSave()
    if next(self.powers) == nil then return end
    local data = {}
    for k, v in pairs(self.powers) do
        local saved--[[, refs]] = v.inst:GetSaveRecord()
        data[k] = saved
    end
    return { powers = data }
end



function System:OnLoad(data)
    if data ~= nil and data.powers ~= nil then
        for k, v in pairs(data.powers) do
            if self.powers[k] == nil then
                local ent = SpawnSaveRecord(v)
                if ent ~= nil then
                    addPower(self, k, ent)
                end
            end
        end
    end
end


return System