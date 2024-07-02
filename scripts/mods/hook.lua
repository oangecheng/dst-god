

local function cook_time_multi(doer)
    return GetUgData(doer, UGDATA_KEY.COOK_MULTI) or 1
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
AddComponentPostInit("dryable", function (self)
    local oldtimefn = self.GetDryTime
    self.GetDryTime = function (_)
        local mult = self.inst.drymulti or 1
        local time = oldtimefn(self)
        UgLog("dryable hook", time, mult)
        return time and time * mult or time
    end
end)


AddComponentPostInit("dryer", function (self)
    local oldSartDrying = self.StartDrying
    self.StartDrying = function (_, dryable)
        dryable.drymulti = self.inst.drymulti
        local ret = oldSartDrying(self, dryable)
        dryable.drymulti = nil
        return ret
    end

    --- 推送收获事件
    local oldHarvest = self.Harvest
    self.Harvest = function (self, harvester)
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
        act.target.drymulti = GetUgData(act.doer, UGDATA_KEY.DRY_MULTI)
    end
    local ret, str = oldDrnfn(act)
    if act.target and act.doer then
        act.target.drymulti = nil
    end
    return ret, str
end