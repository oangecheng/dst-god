local MakePlayerCharacter = require("prefabs/player_common")

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/ugfoxgirl.zip")
    --- 添加人物动画 
}

local prefabs = {}
-- 开始物品
local start_inv = {}
prefabs = FlattenTree({ prefabs, start_inv }, true)


local common_postinit = function(inst)
	inst.MiniMapEntity:SetIcon( "ugfoxgirl.tex" )
	inst.soundsname = "willow"
	inst:AddTag("ugplayer")
end


local function master_postinit(inst)
    inst.components.health:SetMaxHealth(150)
    inst.components.hunger:SetMax(150)
    inst.components.sanity:SetMax(200)

    local sys = inst:AddComponent("ugsystem")
    inst:AddComponent("ugsync")
    inst:ListenForEvent(UGEVENTS.TASK_FINISH, function (inst, data)
        sys:RemoveEntity(data.name)
    end)
    inst:DoTaskInTime(0.1, function ()
        inst.components.ugsync:SyncPower()
    end)
end

return MakePlayerCharacter("ugfoxgirl", prefabs, assets, common_postinit, master_postinit)
