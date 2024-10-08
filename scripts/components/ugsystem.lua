
local function attach(system, name, ent, data)
    if ent.components.ugentity then
        ent.persists = false
        -- 可以attach再attach
        if system.attach_test_fn == nil or system.attach_test_fn(name, ent) then
            ent.components.ugentity:Attach(system.inst, name, data)
        end
        system.entities[name] = {
            inst = ent,
            type = ent.type
        }
        system.inst:PushEvent(UGEVENTS.POWER_UPDATE, {})
    else
        ent:Remove()
    end
end


local function detach(system, name)
    local ent = system.entities[name]
    system.entities[name] = nil
    if ent ~= nil and ent.inst.components.ugentity then
        ent.inst.components.ugentity:Detach()
    end
    system.inst:PushEvent(UGEVENTS.POWER_UPDATE, {})
    return ent.inst
end


local function extend(inst)
    if inst.components.ugentity then
        inst.components.ugentity:Extend(inst)
    end
end


local System = Class(function (self, inst)
    self.inst = inst
    self.entities = {}
end)


function System:SetAttachTestFn(fn)
    self.attach_test_fn = fn
end


---添加实体
---@param name string 实体名称
---@param data table|nil 实体数据
---@return table|nil 实体对象
function System:AddEntity(name, data)
    local ent = self.entities[name]
    if ent ~= nil then
        extend(ent.inst)
        return ent.inst
    end

    local newEnt = SpawnPrefab(name)
    if newEnt ~= nil then
        attach(self, name, newEnt, data)
    end
    UgLog("AddEntity", name)
    return newEnt
end


---移除一个实体，只是从owner身上移除，本身实例还存在
---@param name 实体名称
---@return table|nil 被移除的实体
function System:RemoveEntity(name)
    return detach(self, name)
end



function System:GetEntity(name)
    local data = self.entities[name]
    if data ~= nil then
       return data.inst
    end
end



---comment 获取实例列表
---@param type number|nil 类型，nil返回全部 
---@return 数据列表 table 实例
function System:GetAll(type)
    local list = {}
    for k, v in pairs(self.entities) do
        if v ~= nil and type == nil or type == v.inst.type then
            table.insert(list, v.inst)
        end
    end
    return list    
end



---将所有实体迁移至另一个目标
---@param target table 目标
function System:Transform(target)
    local target_system = target.components.ugsystem
    if target_system ~= nil then
        for k, v in pairs(self.entities) do
            local lv = v.inst and v.inst.components.uglevel
            local l = lv:GetLv()
            local e = lv:GetXp()
            local ent = target_system:AddEntity(k)
            ent.components.uglevel:SetLv(l)
            ent.components.uglevel:SetXp(e)
        end
    end
end



function System:OnSave()
    if next(self.entities) == nil then return end
    local data = {}
    for k, v in pairs(self.entities) do
        local saved--[[, refs]] = v.inst:GetSaveRecord()
        data[k] = saved
    end
    return { entities = data }
end



function System:OnLoad(data)
    if data ~= nil and data.entities ~= nil then
        for k, v in pairs(data.entities) do
            if self.entities[k] == nil then
                local ent = SpawnSaveRecord(v)
                if ent ~= nil then
                    attach(self, k, ent)
                end
            end
        end
    end
end



return System