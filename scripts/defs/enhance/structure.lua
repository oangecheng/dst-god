

--移除预制物(预制物,数量)
local function remove_item(item, num)
	if item.components.stackable then
		item.components.stackable:Get(num):Remove()
	else
		item:Remove()
	end
end

---------------------- 晾肉架升级 -------------------------
AddPrefabPostInit("meatrack", function (inst)
    inst:AddComponent("uglevel")
    inst:AddComponent("ugmark")
    if true then
       inst.components.uglevel:SetLv(10)
    end
end)



