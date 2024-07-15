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
---@param source string 标记位
function AddUgComponent(owner, com, source)
    if owner ~= nil then
        local comp = owner.components[com]
        if comp == nil then
            owner:AddComponent(com)
            PutUgData(owner.components[com], source, true)
        elseif comp.ugdata ~= nil then
            PutUgData(comp, source, true)
        end
    end
end

---comment 移除临时组件
---@param owner table 目标
---@param com string 组件名称
---@param source string 标记位
function RemoveUgComponent(owner, com, source)
    local v = owner.components[com]
    --- ugdata 非空则认为由此mod添加的临时组件
    if v ~= nil and v.ugdata ~= nil then
        PutUgData(v, source, nil)
        local ret = false
        -- 遍历列表，如果没有值了，就把组件移除了
        for _, value in pairs(v.ugdata) do
            if value then
                ret = true
                break
            end
        end
        if not ret then
            owner:RemoveComponent(com)
        end
    end
end



function AddUgTag(owner, tag, source)
    if owner ~= nil then
        if owner.ugtags == nil then
            owner.ugtags = {}
        end
        owner.ugtags[source] = tag
        if not owner:HasTag(tag) then
            owner:AddTag(tag)
        end
    end
end



function RemoveUgTag(owner, tag, source)
    if owner ~= nil then
        if owner.ugtags ~= nil then
            owner.ugtags[source] = nil
        end
        if owner.ugtags == nil or IsTableEmpty(owner.ugtags) then
            owner:RemoveTag(tag)
        end
    end
end
