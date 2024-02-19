
local expfndef = function (lv)
    return (lv + 1) * 10
end

local function onLvChanged(self, lv)
    if self.onLvFn then
        self.onLvFn(lv)
    end
end


local function onXpChanged(self, xp)
    if self.onXpFn then
        self.onXpFn(xp)
    end
end


local Level = Class(
    function(self, inst)
        self.inst = inst
        self.lv = 0
        self.xp = 0
        self.max = math.maxinteger
    end,
    nil,
    {
        lv = onLvChanged,
        xp = onXpChanged
    })


---comment 设置经验变更回调
---@param fn function
function Level:SetOnXpFn(fn)
    self.onXpFn = fn
end


---comment 设置等级监听，只有等级发生变更时才会回调
---@param fn function
function Level:SetOnLvFn(fn)
    self.onLvFn = fn
end


---comment 判断是否是最大等级
---@return boolean
function Level:IsMax()
    return self.lv >= self.max
end


---comment 经验变化
---@param delta number
function Level:XpDelta(delta)
    if self:IsMax() then
        return
    end

    local txp = self.xp + delta
    local fn  = self.expfn or expfndef

    local tlv = self.lv
    while txp >= fn(tlv) do
        txp = txp - fn(tlv)
        tlv = tlv + 1
    end

    if tlv ~= self.lv then
        self.lv = math.min(self.max, tlv)
    end

    txp = self:IsMax() and 0 or txp
    if self.xp ~= txp then
        self.xp = txp
    end
end


---comment 等级变更
---@param delta integer
function Level:LvDelta(delta)
    if delta ~= 0 then
        self:SetLv(self.lv + delta)
    end
end


---comment 设置等级，一般用在怪物身上
---@param lv integer
function Level:SetLv(lv)
    if self.lv ~= lv then
        self.lv = math.min(lv, self.max)
    end
end


---comment 设置等级上限
---@param max integer|nil 设置nil无上限
function Level:SetMax(max)
    self.max = max and max or math.maxinteger
    if self.lv > self.max then
        self:SetLv(self.max)
    end
end


function Level:OnLoad(data)
    self.lv = data.lv or 0
    self.xp = data.xp or 0
end


function Level:OnSave()
    return {
        lv = self.lv,
        xp = self.xp
    }
end


return Level