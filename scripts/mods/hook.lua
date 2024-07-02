

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