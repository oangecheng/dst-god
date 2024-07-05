-- 面板
local UgUserPopupScreen = require "ui/ugscreen"


AddClassPostConstruct("screens/playerhud", function(self, anim, owner)
	self.ShowUgUserScreen = function(_, holder)
		self.ugscreen = UgUserPopupScreen(self.owner)
        self:OpenScreenUnderPause(self.ugscreen)
        return self.ksfunscreen
	end

    self.CloseUgUserScreen = function(_)
		if self.ugscreen ~= nil then
            if self.ugscreen.inst:IsValid() then
                TheFrontEnd:PopScreen(self.ugscreen)
            end
            self.ugscreen = nil
        end
	end
end)


AddPopup("UGUSER_SCREEN")
POPUPS.UGUSER_SCREEN.fn = function(inst, show, holder)
    if inst.HUD then
        if not show then
            inst.HUD:CloseUgUserScreen()
        elseif not inst.HUD:CloseUgUserScreen(holder) then
            POPUPS.UGUSER_SCREEN:Close(inst)
        end
    end
end



TheInput:AddKeyDownHandler(108, function()
    if ThePlayer ~= nil and ThePlayer.HUD ~= nil then
        if ThePlayer.HUD.ugscreen ~= nil then
            ThePlayer.HUD:CloseUgUserScreen()
        else
            ThePlayer.HUD:ShowUgUserScreen()
        end
    end
end)


