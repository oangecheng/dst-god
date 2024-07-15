local function on_data_dirty(self, inst)
    local serverdata = self._itemdatas:value()
    if serverdata ~= nil then
        local info = json.decode(serverdata)
        if info ~= nil then
            for k, v in pairs(info) do
                if type(v) == "table" then
                    self.datas[k] = v
                else
                    self.datas[k] = v
                end
            end
        end
    end
end


local Sync = Class(function(self, inst)
    self.inst = inst
    self.datas = {}
    self._itemdatas = net_string(inst.GUID, "ug._itemdatas", "ug_itemdirty")
    self.inst:ListenForEvent("ug_itemdirty", function(inst)
        on_data_dirty(self, inst)
    end)
end)


-- 数据类似这样的结构
-- {
--     power = {
--         damage = {
--             lv = 1,
--             xp = 2
--         }
--     },
--     lv = 1,
-- }
---comment 同步客户端数据，inst所有相关的数据
---@param data string json数据, 需要encode
function Sync:SyncData(data)
    self._itemdatas:set_local(data)
    self._itemdatas:set(data)
end


---comment 获取属性数据
---@return table|nil
function Sync:GetPowers()
    return self.datas["power"] or {}
end


function Sync:GetLevel()
    return self.datas["level"]
end


return Sync