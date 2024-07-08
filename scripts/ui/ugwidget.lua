local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local PowerPage = require "ui/ugpagepower"

require("util")



local function getTargetPowers(inst)
    local system = TheWorld.ismastersim and inst.components.ugsync or inst.replica.ugsync
    if system ~= nil then
        return system:GetPowers()
    end
end


local function getEquipmentsPowers(owner)
	local list = {}
	if TheWorld.ismastersim then
		if owner.components.inventory ~= nil then
			for k, v in pairs(owner.components.inventory.equipslots) do
				local p = getTargetPowers(v)
				if p then
					list[v.prefab] = p
				end
			end
		end
	else
		local inventory = owner.replica.inventory
		if inventory ~= nil then
			for k, v in pairs(inventory:GetEquips()) do
				local p = getTargetPowers(v)
				if p then
					list[v.prefab] = {
						powers = p,
						target = v
					}
				end
			end
		end
	end

	return list
end


-------------------------------------------------------------------------------------------------------
local MultiTabWidget = Class(Widget, function(self, owner)
    Widget._ctor(self, "MultiTabWidget")
    self.root = self:AddChild(Widget("root"))

	self.tab_root = self.root:AddChild(Widget("tab_root"))

	self.backdrop = self.root:AddChild(Image("images/plantregistry.xml", "backdrop.tex"))

	local base_size = .5



	local button_data = {
		{
			text = "人物面板",
			build_panel_fn = function()
				local data = {
					powers = getTargetPowers(owner),
					target = owner,
					xml = nil,
				}
				return PowerPage(self, owner, data)
			end
		},
	}

	local list = getEquipmentsPowers(owner)
	if next(list) ~= nil then
		for k, v in pairs(list) do
			if v ~= nil and next(v) ~= nil then
				table.insert(
					button_data,
					{
						text = STRINGS.NAMES[string.upper(k)],
						build_panel_fn = function()
							local data = {
								powers = v.powers,
								target = v.target,
								xml = "images/items/uggems.xml" 
							}
							return PowerPage(self, owner, data)
						end
					}
				)
			end
		end
	end
	local function MakeTab(data, index)
        local tab = ImageButton("images/plantregistry.xml", "plant_tab_inactive.tex", nil, nil, nil, "plant_tab_active.tex")
		tab:SetFocusScale(base_size, base_size)
		tab:SetNormalScale(base_size, base_size)
		tab:SetText(data.text)
		tab:SetTextSize(22)
		tab:SetFont(HEADERFONT)
		tab:SetTextColour(UICOLOURS.GOLD)
		tab:SetTextFocusColour(UICOLOURS.GOLD)
		tab:SetTextSelectedColour(UICOLOURS.GOLD)
		tab.text:SetPosition(0, -4)
		tab.clickoffset = Vector3(0,5,0)
		tab:SetOnClick(function()
	        self.last_selected:Unselect()
	        self.last_selected = tab
			tab:Select()
			tab:MoveToFront()
			if self.panel ~= nil then
				self.panel:Kill()
			end
			self.panel = self.root:AddChild(data.build_panel_fn())

		    if TheInput:ControllerAttached() then
				self.panel.parent_default_focus:SetFocus()
			end

			ThePlantRegistry:SetFilter("tab", index)
		end)
		tab._tabindex = index - 1

		return tab
	end

	self.tabs = {}
	for i = 1, #button_data do
		table.insert(self.tabs, self.tab_root:AddChild(MakeTab(button_data[i], i)))
		self.tabs[#self.tabs]:MoveToBack()
	end
	self:_PositionTabs(self.tabs, 155, 285)

	-----
	local starting_tab = ThePlantRegistry:GetFilter("tab")
	if self.tabs[starting_tab] == nil then
		starting_tab = 1
	end
	self.last_selected = self.tabs[starting_tab]
	self.last_selected:Select()
	self.last_selected:MoveToFront()
	self.panel = self.root:AddChild(button_data[starting_tab].build_panel_fn())

	self.focus_forward = function() return self.panel.parent_default_focus end
end)

function MultiTabWidget:Kill()
	ThePlantRegistry:Save() -- for saving filter settings

	MultiTabWidget._base.Kill(self)
end

function MultiTabWidget:_PositionTabs(tabs, w, y)
	local offset = #self.tabs / 2
	for i = 1, #self.tabs do
		local x = (i - offset - 0.5) * w
		tabs[i]:SetPosition(x, y)
	end
end

function MultiTabWidget:OnControlTabs(control, down)
	if control == CONTROL_OPEN_CRAFTING then
		local tab = self.tabs[((self.last_selected._tabindex - 1) % #self.tabs) + 1]
		if not down then
			tab.onclick()
			return true
		end
	elseif control == CONTROL_OPEN_INVENTORY then
		local tab = self.tabs[((self.last_selected._tabindex + 1) % #self.tabs) + 1]
		if not down then
			tab.onclick()
			return true
		end
	end

end

function MultiTabWidget:OnControl(control, down)
    if MultiTabWidget._base.OnControl(self, control, down) then return true end

	if #self.tabs > 1 then
		return self:OnControlTabs(control, down)
	end
end

function MultiTabWidget:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

	if #self.tabs > 1 then
		table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_CRAFTING).."/"..TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_INVENTORY).. " " .. STRINGS.UI.HELP.CHANGE_TAB)
	end

    return table.concat(t, "  ")
end


return MultiTabWidget