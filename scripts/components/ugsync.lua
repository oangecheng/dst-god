local function cache_data(self, info)
    if info ~= nil then
        for k, v in pairs(info) do
            if type(v) == "table" then
                self.datas[k] = self.datas[k] or {}
                for k1, v1 in pairs(v) do
                    self.datas[k][k1] = v1
                end
            else
                self.datas[k] = v
            end
        end
    end
end



local Sync = Class(function (self, inst)
    self.inst = inst
    self.datas = {}
    self.inst:ListenForEvent(UGEVENTS.POWER_UPDATE, function (inst, data)
        self:SyncPower(data.name)
    end)
end)


function Sync:SyncPower(name)
    local data = {}
    local sys = self.inst.components.ugsystem
    if sys ~= nil then
        local powers = sys:GetAll(UGENTITY_TYPE.POWER)
        data["power"] = {}
        for i, v in ipairs(powers) do
            data["power"][v.name] = {
                lv = v.components.uglevel:GetLv(),
                xp = v.components.uglevel:GetXp()
            }
        end
    end

    cache_data(self, data)
    if self.inst.replica.ugsync then
        self.inst.replica.ugsync:SyncData(json.encode(data))
    end
end


function Sync:SyncLevel()
    local data = {}
    if self.inst.components.uglevel ~= nil then
        data["level"] = self.inst.components.uglevel:GetLv()
    end

    cache_data(self, data)
    if self.inst.replica.ugsync then
        self.inst.replica.ugsync:SyncData(json.encode(data))
    end
end


---comment 获取属性数据
---@return table|nil
function Sync:GetPowers()
    return self.datas["power"]
end


function Sync:GetLevel()
    return self.datas["level"]
end


return Sync