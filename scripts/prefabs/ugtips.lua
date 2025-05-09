
local pcall = GLOBAL.pcall


local TIPS_TYPE = {
	{
		color = { r = 255 / 255, g = 0, b = 0 }
	},
	{
		color = { r = 70 / 255, g = 139 / 255, b = 101 / 255 },
	}
}


local function show_tips(inst)
	local str = inst.ug_tips_value:value()
	if str ~= nil and str ~= "{}" then
		local success, data = pcall(json.decode, str)
		if success and data ~= nil then
			local label = inst.Label
			label:SetText(data.text)
			label:SetColour(TIPS_TYPE[data.type].color)
			label:Enable(true)
		end
	end
end


local function UpdatePing(inst, t0, duration)
    local t = GetTime() - t0
    local k = 1 - math.max(0, t - 0.1) / duration
    k = 1 - k * k
    local s = Lerp(15, 30, k)--字体从15到30
	local y = Lerp(4, 5, k)--高度从4到5
    local label=inst.Label
	if label then
		label:SetFontSize(s)
		label:SetWorldOffset(0, y, 0)
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddNetwork()
	inst.entity:SetCanSleep(false)
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	
	local label = inst.entity:AddLabel()
	label:SetFont(NUMBERFONT)
	label:SetFontSize(15)
	label:SetWorldOffset(0, 4, 0)
	label:SetColour(255/255, 204/255, 51/255)
	label:SetText("+0")
	label:Enable(false)

	inst.ug_tips_value = net_string(inst.GUID, "ug_tips_value", "ug_tips_valuedirty")
	inst:ListenForEvent("ug_tips_valuedirty", show_tips)

	inst.entity:SetPristine()
	inst.persists = false
	local duration = 0.85 --持续时间
	inst:DoPeriodicTask(0, UpdatePing, nil, GetTime(), duration)
	inst:DoTaskInTime(duration, inst.Remove)

	return inst
end

return Prefab("ugtips", fn)