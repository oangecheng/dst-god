---comment 获取一个实例
---@param owner table 目标
---@param name string key
---@return table|nil enity 实体
function GetUgEntity(owner, name)
    if owner.components.ugsystem ~= nil then
        return owner.components.ugsystem:GetEntity(name)
    end
end


---comment 获取经验
---@param owner table 目标
---@param name string key
---@param exp number 经验值
function GainUgPowerXp(owner, name, exp)
    local power = GetUgEntity(owner, name)
    if exp ~= 0 and power ~= nil then
        exp = math.max(1, math.floor(exp + 0.5))
        if power.components.uglevel then
            power.components.uglevel:XpDelta(exp)
        end
    end
end

---comment 获取属性等级
---@param owner table 目标
---@param name string 属性名称
---@return number|nil lv 等级
function GetUgPowerLv(owner, name)
    local inst = GetUgEntity(owner, name)
    if inst ~= nil then
        return inst.components.uglevel:GetLv()
    end
end


---comment 临时在owner上存放数据
---@param owner table 目标
---@param key string 数据的key
---@param value any 任意值
function PutUgData(owner, key, value)
    UgLog("PutUgData", key, value)
    if owner ~= nil then
        local datas = owner.ugdata or {}
        datas[key] = value
        owner.ugdata = datas
    end
end


---comment 获取临时存放owner上的数据
---@param owner table|nil 目标
---@param key string 数据的key
---@return any data 任意类型，做好类型check
function GetUgData(owner, key)
    if owner ~= nil and owner.ugdata ~= nil then
        return owner.ugdata[key]
    end
end


---comment 添加临时组件，如果已有就不添加
---@param owner table 目标
---@param com string 组件名称
function AddUgComponent(owner, com)
    if owner ~= nil and owner.components[com] == nil then
        owner:AddComponent(com)
        owner.components[com].isugtemp = true
    end
end

---comment 移除临时组件
---@param owner table 目标
---@param com string 组件名称
function RemoveUgComponent(owner, com)
    local v = owner.components[com]
    if v ~= nil and v.isugtemp then
        owner:RemoveComponent(com)
    end
end