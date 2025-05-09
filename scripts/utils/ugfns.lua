
---comment 说话
---@param inst table 目标
---@param msg string 消息
function UgSay(inst, msg)
    if inst ~= nil and inst.components.talker ~= nil then
        inst.components.talker:Say(msg)
    end
end


---comment 获取名称
---@param prefab string 预制物代码
---@return string name 名称
function UgName(prefab)
    return STRINGS.UGNAMES(prefab) or STRINGS.NAMES[string.upper(prefab)]
end


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
---@param default_value any 兜底数据
---@return any data 任意类型，做好类型check
function GetUgData(owner, key, default_value)
    if owner ~= nil and owner.ugdata ~= nil then
        return owner.ugdata[key] or default_value
    end
    return default_value
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


---增加tag
---@param owner table
---@param tag string
---@param source string
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


-- ---增加tag
-- ---@param owner table
-- ---@param tag string
-- ---@param source string
-- function AddUgTag(owner, tag, source)
--     if owner ~= nil then
--         owner.ugtags = owner.ugtags or {}
--         owner.ugtags[tag] = owner.ugtags[tag] or {}
--         --- merge数组
--         ArrayUnion(owner.ugtags[tag], { source })
--         if not owner:HasTag(tag) then
--             owner:AddTag(tag)
--         end
--     end
-- end



-- function RemoveUgTag(owner, tag, source)
--     if owner ~= nil then
--         local tags = owner.ugtags and owner.ugtags or nil
--         if tags ~= nil then
--             local sources = tags[tag] or nil
--             if sources ~= nil then
--                 ---@diagnostic disable-next-line: undefined-field
--                 table.removearrayvalue(sources, source)
--                 if IsTableEmpty(sources) then
--                     owner:RemoveTag(tag)
--                 end
--             end
--         end
--     end
-- end




---comment 根据权重获取随机物品(权重表,随机值)
---表格式{ key = { w = 1, num = 2 } }
---@param loot table
---@return string,integer
function GetUgRandomItem(loot)
	local function totalWeightFn(source)
		local sum = 0
		for _, v in pairs(source) do
			sum = sum + v.w
		end
		return sum
	end

	local seed = math.random()
	local threshold = seed * totalWeightFn(loot)

	local target, cnt
	for k, v in pairs(loot) do
		threshold = threshold - v.w
		if threshold <= 0 then return k, v.num or 1 end
		target = k
		cnt = v.num or 1
	end

	return target, cnt
end


function IsMedalOpen()
    return TUNING.FUNCTIONAL_MEDAL_IS_OPEN
end



---持久数据至组件
---@param owner table
---@param powername string
---@param key string
---@param value number
function AddEntityNumber(owner, powername, key, value)
    local inst = GetUgEntity(owner, powername)
    local comp = inst and inst.components.ugentity or nil
    if comp ~= nil then
        local v = comp:GetValue(key) or 0
        comp:PutValue(key, v + value)
    end
end


---获取数据
---@param owner any
---@param powername any
---@param key any
---@return number
function GetEntityNumber(owner, powername, key)
    local inst = GetUgEntity(owner, powername)
    local comp = inst and inst.components.ugentity or nil
    if comp ~= nil then
        return comp:GetValue(key) or 0
    else
        return 0
    end
end



---显示提示信息
---@param player table
---@param msg string
---@param type number
function SpawnUgTip(player, msg, type)
    if player ~= nil then
        local tips = SpawnPrefab("ugtips")
        tips.Transform:SetPosition(player.Transform:GetWorldPosition())
        if tips.ug_tips_value then
            local data = { text = msg, type = type }
            tips.ug_tips_value:set(json.encode(data))
        end
    end
end
