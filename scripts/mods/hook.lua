local function cook_time_multi(doer)
    return GetUgData(doer, UGMARK.COOK_MULTI) or 1
end


--修改烹饪组件,在锅中收获自己做的料理的时候推送事件
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
        self.cooktimemult = oldmulti * cook_time_multi(doer)
        if oldStartCooking then
            oldStartCooking(self, doer)
        end
        self.cooktimemult = oldmulti
    end
end)



--- 晾晒加速hook， 由于晾晒的动作没有传入doer，所以hook比较麻烦
--- 实现方式，在执行晾晒之前打上标记，获取时间的时候就可以根据标记计算时间
AddComponentPostInit("dryable", function(self)
    local oldtimefn = self.GetDryTime
    self.GetDryTime = function(_)
        local mult = self.inst.drymulti or 1
        local time = oldtimefn(self)
        UgLog("dryable hook", time, mult)
        return time and time * mult or time
    end
end)


AddComponentPostInit("dryer", function(self)
    local oldSartDrying = self.StartDrying
    self.StartDrying = function(_, dryable)
        dryable.drymulti = self.inst.drymulti
        local ret = oldSartDrying(self, dryable)
        dryable.drymulti = nil
        return ret
    end

    --- 推送收获事件
    local oldHarvest = self.Harvest
    self.Harvest = function(self, harvester)
        local success = oldHarvest(self, harvester)
        if success then
            harvester:PushEvent(UGEVENTS.HARVEST_DRY, { product = self.product })
        end
        return success
    end
end)

--- hook 动作
local oldDrnfn = ACTIONS.DRY.fn
ACTIONS.DRY.fn = function(act)
    if act.target and act.doer then
        act.target.drymulti = GetUgData(act.doer, UGMARK.DRY_MULTI)
    end
    local ret, str = oldDrnfn(act)
    if act.target and act.doer then
        act.target.drymulti = nil
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



--修改海钓竿组件
AddComponentPostInit("oceanfishingrod", function(self)
    local oldCatchFish = self.CatchFish
    self.CatchFish = function(self)
        if self.target ~= nil and self.target.components.oceanfishable ~= nil then
            self.fisher:PushEvent(UGEVENTS.FISH_SUCCESS, { fish = self.target, isocean = true })
        end
        if oldCatchFish then
            oldCatchFish(self)
        end
    end
end)


--修改普通鱼竿组件
AddComponentPostInit("fishingrod", function(fishingrod)
    local oldCollect = fishingrod.Collect
    fishingrod.Collect = function(self)
        if self.caughtfish and self.fisherman and self.target then
            self.fisherman:PushEvent(UGEVENTS.FISH_SUCCESS, { fish = self.caughtfish, pond = self.target })
        end
        if oldCollect then
            oldCollect(self)
        end
    end

    local oldWaitForFish = fishingrod.WaitForFish
    fishingrod.WaitForFish = function(self)
        local mult = GetUgData(self.fisherman, UGMARK.FISH_MULTI)
        if mult ~= nil then
            local oldmin = self.minwaittime
            local oldmax = self.maxwaittime
            -- 根据源码，这里同步缩小 min和max值 就能实现缩短时间，不需要copy代码
            if oldmin ~= nil and oldmax ~= nil then
                self.minwaittime = oldmin * mult
                self.maxwaittime = oldmax * mult
            end

            if oldWaitForFish ~= nil then
                oldWaitForFish(self)
            end

            self.minwaittime = oldmin
            self.maxwaittime = oldmax
        end
    end
end)




--- hook治疗组件
AddComponentPostInit("healer", function(self)
    local old_heal = self.Heal
    self.Heal = function(_, target, doer)
        local old_health = self.health
        local mult = GetUgData(doer, UGMARK.HEAL_MULTI)
        if mult ~= nil then
            self.health = math.floor(old_health * mult)
        end
        local success, v2 = old_heal(self, target, doer)
        self.health = old_health
        if success then
            doer:PushEvent(UGEVENTS.HEAL, { target = target, health = old_health })
        end
        return success, v2
    end
end)
