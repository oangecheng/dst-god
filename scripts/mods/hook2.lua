---@diagnostic disable: duplicate-set-field


AddComponentPostInit("edible", function(self)
    local old_fn = self.GetHunger
    self.GetHunger = function(self, eater)
        if old_fn ~= nil then
            local hunger_value = old_fn(self, eater)
            local hunger_multi = GetUgData(eater, "eat_food_hunger_multi", 1)
            return hunger_value * hunger_multi
        end
    end
end)



AddComponentPostInit("health", function(self)
    local old_fn = self.DoDelta
    self.DoDelta = function(self, amount, ...)
        if old_fn ~= nil then
            local m = self.inst:HasTag("player") and GetUgData(self.inst, "health_delta", 1) or 1
            local v = amount > 0 and amount * m or amount
            return old_fn(self, v, ...)
        end
    end
end)



---hook状态机
---僵直和击飞抗性
AddStategraphPostInit("wilson", function(sg)
    --击飞抗性
    if sg.events and sg.events.knockback then
        local old_fn = sg.events.knockback.fn
        sg.events.knockback.fn = function(inst, data)
            if inst:HasTag("ughealth_master") then
                return
            elseif old_fn then
                return old_fn(inst, data)
            end
        end
    end

    --僵直抗性，概率抵抗
	if sg.events and sg.events.attacked then
		local old_fn = sg.events.attacked.fn
		sg.events.attacked.fn = function(inst, data)
            if inst:HasTag("ughealth_master") or inst:HasTag("playerghost") then
                return
            elseif old_fn then
                return old_fn(inst, data)
            end
        end
	end
end)



---hook烹饪组件
---在锅中收获自己做的料理的时候推送事件
AddComponentPostInit("stewer", function(self)
    local oldHarvest = self.Harvest
    self.Harvest = function(self, harvester)
        if self.done and harvester ~= nil and self.chef_id == harvester.userid and self.product then
            harvester:PushEvent(UGEVENTS.HARVEST_SELF_FOOD, { food = self.product })
        end
        return oldHarvest and oldHarvest(self, harvester) or nil
    end

    -- hook烹饪时间
    local oldStartCooking = self.StartCooking
    self.StartCooking = function(self, doer)
        local oldmulti = self.cooktimemult
        self.cooktimemult = oldmulti * (GetUgData(doer, "cook_time_mult") or 1)
        if oldStartCooking then
            oldStartCooking(self, doer)
        end
        self.cooktimemult = oldmulti
    end
end)




--- 晾晒加速hook， 由于晾晒的动作没有传入doer，所以hook比较麻烦
--- 实现方式，在执行晾晒之前打上标记，获取时间的时候就可以根据标记计算时间
local BATCH_KEY = "ugbatch_key"
AddComponentPostInit("dryable", function(self)
    local old_time_fn = self.GetDryTime
    self.GetDryTime = function(_)
        local mult = self.inst.drymulti or 1
        local time = old_time_fn(self)
        return time and time * mult or time
    end
end)
local function batc_dry(inst, dryable)
    if inst.components.ugmark ~= nil then
        local lv = inst.components.uglevel:GetLv()
        local st = dryable.components.stackable
        if lv > 0 and st ~= nil then
            local size = st:StackSize() - 1
            local cnt = math.min(lv, size)
            st:Get(cnt):Remove()
            inst.components.ugmark:Put(BATCH_KEY, cnt)
            return cnt
        end
    end
    return 0
end
AddPrefabPostInit("meatrack", function (inst)
    inst:AddComponent("uglevel")
    inst:AddComponent("ugmark")
    inst:AddComponent("ugsync")
    inst.components.uglevel:SetOnLvFn(function ()
        inst.components.ugsync:SyncLevel()
    end)
    inst:AddTag(UGTAGS.MAGIC_TARGET)
    inst:ListenForEvent("onremove", function ()
        if inst.components.uglevel then
            
        end
    end)
end)
AddComponentPostInit("dryer", function(self)
    local old_dry_fn = self.StartDrying
    self.StartDrying = function(_, dryable)
        dryable.drymulti = self.inst.drymulti
        local ret = old_dry_fn(self, dryable)
        dryable.drymulti = nil
        return ret
    end

    --- 推送收获事件
    local old_harvest_fn = self.Harvest
    self.Harvest = function(self, harvester)
        local product = self.product
        local success = old_harvest_fn(self, harvester)
        if success and product ~= nil then
            harvester:PushEvent(UGEVENTS.HARVEST_DRY, { product = product })
            if self.inst.components.ugmark ~= nil then
                local cnt = self.inst.components.ugmark:Poll(BATCH_KEY)
                if cnt ~= nil and cnt > 0 and harvester.components.inventory then
                    for i = 1, cnt do
                        local item = SpawnPrefab(product)
                        if item ~= nil then
                            harvester.components.inventory:GiveItem(item)
                        end
                    end
                end
            end
        end
        return success
    end
end)
--- hook 动作
local old_dry_action_fn = ACTIONS.DRY.fn 
ACTIONS.DRY.fn = function(act)
    local obj = act.invobject
    local target = act.target
    local cnt = batc_dry(target, obj)
    if target and act.doer then
        target.drymulti = GetUgData(act.doer, "dry_time_mult") or 1
        if cnt > 0 and target.drymulti ~= nil then
            target.drymulti = target.drymulti * (cnt + 1)
        end
    end
    local ret, str = old_dry_action_fn(act)
    if act.target ~= nil then
        act.target.drymulti = nil
    end
    if not ret and cnt > 0 then
        target.components.ugmark:Clear(BATCH_KEY)
    end
    return ret, str
end



--多汁浆果采集是掉落
AddPrefabPostInit("berrybush_juicy", function(inst)
    if GLOBAL.TheWorld.ismastersim then
        if inst.components.pickable then
            local oldpickfn = inst.components.pickable.onpickedfn
            inst.components.pickable.onpickedfn = function(inst, picker, loot)
                picker:PushEvent(UGEVENTS.PICK_STH, { object = inst, prefab = "berries_juicy", num = 3 })
                if oldpickfn then
                    oldpickfn(inst, picker, loot)
                end
            end
        end
    end
end)



-- 根据用户等级计算肥力值的倍率对肥力值进行修改
-- 并且返回原始的肥力值，如果之前的肥力值不存在，则返回nil
local function tryModifyNutrients(fertilizer, deployer)
    if not fertilizer or not deployer then return nil end
    local cacheValue = fertilizer.nutrients
    if not cacheValue then return nil end

    local multi = GetUgData(deployer, "deployable_mult", 0) + 1
    local newValue = {}
    for i,v in ipairs(cacheValue) do
        -- 土地肥力值的上限就是100
        table.insert(newValue, math.min(math.floor(v * multi), 100))
    end
    fertilizer.nutrients = newValue
    return cacheValue
end

---comments hook 施肥组件
AddComponentPostInit("deployable", function (deployable)
    local oldfn = deployable.Deploy
    deployable.Deploy = function (self, pt, deployer, rot)
        local inst = self.inst
        local fertilizer = inst.components.fertilizer
        local ret = tryModifyNutrients(fertilizer, deployer)
        local deployed = oldfn(self, pt, deployer, rot)
        if ret then
            inst.components.fertilizer.nutrients = ret
        end
		return deployed
    end
end)


--- comment 照料作物巨大化
AddComponentPostInit("farmplanttendable", function (tendable)
    local oldfn = tendable.TendTo
    tendable.TendTo = function (self, doer)
        if doer:HasTag("ugfarm_master") and self.inst.components.ugmark then
            self.inst.components.ugmark:Put("oversized", true)
        end
        return oldfn(self, doer)
    end
end)


local farmplants = require("prefabs/farm_plant_defs").PLANT_DEFS
for k, v in pairs(farmplants) do
    AddPrefabPostInit(v.prefab, function (inst)
        if TheWorld.ismastersim then
            inst:AddComponent("ugmark")
            inst.components.ugmark:SetFunc("oversized", function (data)
                if data then
                    inst.force_oversized = true
                end
            end)
        end
    end)
end