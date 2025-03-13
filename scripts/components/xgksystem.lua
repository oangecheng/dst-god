

local exp_def_fn = function (lv, power)
    return XGK_CONFIG.DEBUG and 1 or (lv + 1) * 10
end



local function is_max_lv(d)
    return d and d.lv >= d.maxlv
end


local function on_lv_up(self, power, data, delta)
     local txp = data.xp + delta
     local fn  = self.expfn or exp_def_fn
 
     local tlv = data.lv
     while txp >= fn(tlv, power) do
         txp = txp - fn(tlv)
         tlv = tlv + 1
     end
 
     if tlv ~= data.lv then
         data.lv = math.min(data.maxlv, tlv)
         if self.on_lv_changed_fn ~= nil then
            self.on_lv_changed_fn(self.inst, power, data)
         end
     end
 
     txp = is_max_lv(data) and 0 or txp
     if data.xp ~= txp then
         data.xp = txp
     end
end


local function sync_data(self)
    if self.inst.components.xgksync ~= nil then
        local json_data = json.encode(self.powers)
        self.inst.components.xgksync:SyncPower(json_data)
    end
end


local System = Class(function(self, inst)
    self.inst = inst
    self.powers = {}
end)


function System:SetOnPowerAttachFn(fn)
    self.on_attach_fn = fn
end


function System:SetOnPowerDetachFn(fn)
    self.on_detach_fn = fn
end


function System:SetOnLvChangedFn(fn)
    self.on_lv_changed_fn = fn
end


function System:SetPowerXpFn(fn)
    self.expfn = fn
end


function System:AttachPower(power, data, notify)
    --- 属性的数据结构
    local d = data or {
        lv = 0,
        xp = 0,
        maxlv = 10000,
        ext = {}
    }
    self.powers[power] = d
    if self.on_attach_fn ~= nil then
        self.on_attach_fn(self.inst, power, d)
    end

    if notify then
        sync_data(self)
    end

    return d
end


function System:DetachPower(power)
    local d = self.powers[power]
    self.powers[power] = nil
    if self.on_detach_fn ~= nil then
        self.on_detach_fn(self.inst, power, d)
    end
    return d
end


function System:GainXp(power, xp)
    local d = self.powers[power] or nil
    if d and not is_max_lv(d) then
        on_lv_up(self, power, d, xp)
        sync_data(self)
    end
end


function System:OnSave()
    return {
        powers = self.powers
    }
end


function System:OnLoad(data)
    local powers = data.powers or {}
    for k, v in pairs(powers) do
        self:AttachPower(k, v)
    end
end


return System