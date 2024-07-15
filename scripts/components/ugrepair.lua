
local ITEMS = {
    goldnugget = 0.2
}


-- 盔甲消耗的比较快，单独计算，20%以下就自动卸下
local function percent_limt(inst)
    if inst.components.armor then return 0.2 end
    return 0.05 
end


local function on_percent_changed(inst, data)
    if data.percent > percent_limt(inst) then
        return
    end
    local owner = inst.ugowner
    if owner ~= nil and owner.components.inventory then
        local slot = owner.components.inventory:IsItemEquipped(inst)
        if slot then
            local item = owner.components.inventory:Unequip(slot)
            owner.components.inventory:GiveItem(item)
        end
    end
end

--- 修改官方函数容易引发bug，所以这里采用耐久小于10%时自动卸下装备的机制，避免物品被移除
--- 如果一不小心弄没了，回档吧大宝贝
local function equip_monitor(self)
    self.inst:ListenForEvent("percentusedchange", on_percent_changed)
    self.inst:ListenForEvent("equipped", function(inst, data)
        inst.ugowner = data.owner
    end)
end


-- 衣服帽子用针线包吧（虽然修复材料有点廉价），但是不想单独兼容了
local function do_repair(self, cnt)
    -- 武器或者工具
    local finiteuses = self.inst.components.finiteuses
    if finiteuses then
        local percent = math.min(finiteuses:GetPercent() + cnt, 1)
        finiteuses:SetPercent(percent)
    end
    
    -- 盔甲
    local armor = self.inst.components.armor
    if armor then
        local percent = math.min(armor:GetPercent() + cnt, 1)
        armor:SetPercent(percent)
    end
end


local function on_active(self, active)
    if active then
        AddUgTag(self.inst, UGTAGS.REPAIR, "ugrepair")
        equip_monitor(self)
    end
end




local Repairable = Class(
    function (self, inst)
        self.inst = inst
        self.active = false
    end,
    nil,
    {
        active = on_active
    }
)


---comment 启用功能
function Repairable:Active()
    if self.inst.components.armor ~= nil or self.inst.components.finiteuses ~= nil then
        if not self.active then
            self.active = true
         end
    end 
end



---comment 修理物品
---@param material table 材料
---@param doer table 修理者
---@return boolean 是否修理成功
function Repairable:Repair(material, doer)
    local percent = ITEMS[material.prefab]
    if self.active and percent then
        do_repair(self, percent)
        return true
    end
    return false
end


function Repairable:OnLoad(data)
    self.active = data.active or false
end


function Repairable:OnSave(data)
    return {
        active = self.active
    }
end


return Repairable