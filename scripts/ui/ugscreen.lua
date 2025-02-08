local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local MultiTabWidget = require "ui/ugwidget"

local UgUserPopupScreen = Class(Screen, function(self, owner)
    self.owner = owner
    Screen._ctor(self, "UgUserPopupScreen")

    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black.image:SetVRegPoint(ANCHOR_MIDDLE)
    black.image:SetHRegPoint(ANCHOR_MIDDLE)
    black.image:SetVAnchor(ANCHOR_MIDDLE)
    black.image:SetHAnchor(ANCHOR_MIDDLE)
    black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    black.image:SetTint(0,0,0,.5)
    black:SetOnClick(function() TheFrontEnd:PopScreen() end)
    black:SetHelpTextMessage("")

	local root = self:AddChild(Widget("root"))
	root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    root:SetHAnchor(ANCHOR_MIDDLE)
    root:SetVAnchor(ANCHOR_MIDDLE)
	root:SetPosition(0, -25)
	self.ugscreen = root:AddChild(MultiTabWidget(owner))
	self.default_focus = self.ugscreen
    SetAutopaused(false)
end)

function UgUserPopupScreen:OnDestroy()
    SetAutopaused(false)
    POPUPS.UGUSER_SCREEN:Close(self.owner)
	UgUserPopupScreen._base.OnDestroy(self)
    ThePlayer.HUD.ugscreen = nil
end

function UgUserPopupScreen:OnBecomeInactive()
    UgUserPopupScreen._base.OnBecomeInactive(self)
end

function UgUserPopupScreen:OnBecomeActive()
    UgUserPopupScreen._base.OnBecomeActive(self)
end

function UgUserPopupScreen:OnControl(control, down)
    if UgUserPopupScreen._base.OnControl(self, control, down) then return true end
    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
		TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        TheFrontEnd:PopScreen()
        return true
    end

	return false
end

function UgUserPopupScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}
    table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
    return table.concat(t, "  ")
end

return UgUserPopupScreen
