-----------------------------------------所有的一般物品都走这个逻辑处理--------------------------------------------------------
-----------------------------------------复杂的物品单独写文件加载--------------------------------------------------------


---创建预制物通用函数
---@param data table
---@return table inst
local function common_init_fn(prefab, data)

    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:SetPristine()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(data.bank)
    inst.AnimState:SetBuild(data.build)
    local scale = data.scale or 1
    inst.AnimState:SetScale(scale, scale, scale)
    data.anim = data.anim or "idle"
    inst.AnimState:PlayAnimation(data.anim, data.loop)

    MakeInventoryFloatable(inst, "med", nil, 0.75)
    
    if data.tags then
        for _, v in ipairs(data.tags) do
            inst:AddTag(v)
        end
    end

    if data.initfn then
        data.initfn(inst, prefab, TheWorld.ismastersim)
    end

    if not TheWorld.ismastersim then
        if data.clientfn then
            data.clientfn(inst)
        end
    end

    return inst
end


---构建一个可携带的物品
---@param prefab string
---@param data table 
---@return table 预制物 
local function MakeTemplateItem(prefab, data)
    local function fn()
        local inst = common_init_fn(prefab, data)
        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.imagename = data.image
        inst.components.inventoryitem.atlasname = "images/inventoryimages/"..data.atlas..".xml"

        if data.stack then
            inst:AddComponent("stackable")
            inst.components.stackable.maxsize = data.stack
        end

        if data.serverfn then
            data.serverfn(inst)
        end

        inst.GiveToFn = data.giveto
        inst.GiveByFn = data.giveby

        return inst
    end

    return Prefab(prefab, fn, data.assets)
end



--定义盒子
local function MakeTemplateBox(prefab, data)

    local function onopen(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
        if data.onopenfn then
            data.onopenfn(inst)
        end
    end
    
    local function onclose(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
        if data.onclosefn then
            data.onclosefn(inst)
        end
    end
    
    local function ondropped(inst)
        if inst.components.container ~= nil then
            inst.components.container:Close()
        end
    end
	
	local function fn()
	    local inst = common_init_fn(prefab, data)
	    inst.entity:AddSoundEmitter()

	    if not TheWorld.ismastersim then
	        return inst
	    end
	
	    inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.imagename = data.image
		inst.components.inventoryitem.atlasname = "images/inventoryimages/"..data.atlas..".xml"
		inst.components.inventoryitem:SetOnDroppedFn(ondropped)
		
	    inst:AddComponent("container")
	    inst.components.container:WidgetSetup(prefab)
	    inst.components.container.onopenfn = onopen
	    inst.components.container.onclosefn = onclose

        if data.freshrate ~= nil then
            inst:AddComponent("preserver")
	        inst.components.preserver:SetPerishRateMultiplier(data.freshrate)
        end

		--扩展函数
		if data.serverfn then
			data.serverfn(inst)
		end

        inst.GiveToFn = data.giveto
        inst.GiveByFn = data.giveby
	
	    return inst
	end
	
	return Prefab(prefab, fn, data.assets)
end


local items = require "defs/inventory_defs"
local prefabs = {}
for _, v in ipairs(items) do
    if v.type == 2 then
        table.insert(prefabs, MakeTemplateBox(v.name, v.data))
    else
        table.insert(prefabs, MakeTemplateItem(v.name, v.data))
    end
end
return unpack(prefabs)
