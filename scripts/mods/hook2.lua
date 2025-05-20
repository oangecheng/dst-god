---@diagnostic disable: duplicate-set-field


AddComponentPostInit("edible", function(self)
    local old_fn = self.GetHunger
    self.GetHunger = function(self, eater)
        if old_fn ~= nil then
            local hunger_value = old_fn(self, eater)
            local hunger_multi = GetUgData(eater, "eat_food_hunger_multi", 1)
            return hunger_value * hunger_multi
        end
    end
end)



AddComponentPostInit("health", function(self)
    local old_fn = self.DoDelta
    self.DoDelta = function(self, amount, ...)
        if old_fn ~= nil then
            local m = self.inst:HasTag("player") and GetUgData(self.inst, "health_delta", 1) or 1
            local v = amount > 0 and amount * m or amount
            return old_fn(self, v, ...)
        end
    end
end)



---hook状态机
---僵直和击飞抗性
AddStategraphPostInit("wilson", function(sg)
    --击飞抗性
    if sg.events and sg.events.knockback then
        local old_fn = sg.events.knockback.fn
        sg.events.knockback.fn = function(inst, data)
            if inst:HasTag("ughealth_master") then
                return
            elseif old_fn then
                return old_fn(inst, data)
            end
        end
    end

    --僵直抗性，概率抵抗
	if sg.events and sg.events.attacked then
		local old_fn = sg.events.attacked.fn
		sg.events.attacked.fn = function(inst, data)
            if inst:HasTag("ughealth_master") or inst:HasTag("playerghost") then
                return
            elseif old_fn then
                return old_fn(inst, data)
            end
        end
	end
end)



---hook烹饪组件
---在锅中收获自己做的料理的时候推送事件
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
        self.cooktimemult = oldmulti * (GetUgData(doer, "cook_time_mult") or 1)
        if oldStartCooking then
            oldStartCooking(self, doer)
        end
        self.cooktimemult = oldmulti
    end
end)



-- --- hook治疗组件
-- local old_heal_fn = ACTIONS.HEAL.fn
-- ACTIONS.HEAL.fn = function(act)
--     local doer = act.doer
--     local old_health = nil
--     local healer = act.invobject and act.invobject.components.healer
--     if doer ~= nil and healer ~= nil then
--         local mult = GetUgData(doer, UGMARK.HEAL_MULTI)
--         old_health = healer.health
--         if old_health ~= nil then
--             doer:PushEvent(UGEVENTS.HEAL, { target = act.target, health = old_health })
--             if mult ~= nil then
--                 healer.health = old_health * mult
--             end
--         end
--     end
--     local ret, str = old_heal_fn(act)
--     if healer ~= nil and old_health ~= nil then
--         healer.health = old_health
--     end
--     return ret, str
-- end





--- 晾晒加速hook， 由于晾晒的动作没有传入doer，所以hook比较麻烦
--- 实现方式，在执行晾晒之前打上标记，获取时间的时候就可以根据标记计算时间
local BATCH_KEY = "ugbatch_key"
AddComponentPostInit("dryable", function(self)
    local old_time_fn = self.GetDryTime
    self.GetDryTime = function(_)
        local mult = self.inst.drymulti or 1
        local time = old_time_fn(self)
        return time and time * mult or time
    end
end)
local function batc_dry(inst, dryable)
    if inst.components.ugmark ~= nil then
        local lv = inst.components.uglevel:GetLv()
        local st = dryable.components.stackable
        if lv > 0 and st ~= nil then
            local size = st:StackSize() - 1
            local cnt = math.min(lv, size)
            st:Get(cnt):Remove()
            inst.components.ugmark:Put(BATCH_KEY, cnt)
            return cnt
        end
    end
    return 0
end
AddPrefabPostInit("meatrack", function (inst)
    inst:AddComponent("uglevel")
    inst:AddComponent("ugmark")
    inst:AddComponent("ugsync")
    inst.components.uglevel:SetOnLvFn(function ()
        inst.components.ugsync:SyncLevel()
    end)
    inst:AddTag(UGTAGS.MAGIC_TARGET)
    inst:ListenForEvent("onremove", function ()
        if inst.components.uglevel then
            
        end
    end)
end)
AddComponentPostInit("dryer", function(self)
    local old_dry_fn = self.StartDrying
    self.StartDrying = function(_, dryable)
        dryable.drymulti = self.inst.drymulti
        local ret = old_dry_fn(self, dryable)
        dryable.drymulti = nil
        return ret
    end

    --- 推送收获事件
    local old_harvest_fn = self.Harvest
    self.Harvest = function(self, harvester)
        local product = self.product
        local success = old_harvest_fn(self, harvester)
        if success and product ~= nil then
            harvester:PushEvent(UGEVENTS.HARVEST_DRY, { product = product })
            if self.inst.components.ugmark ~= nil then
                local cnt = self.inst.components.ugmark:Poll(BATCH_KEY)
                if cnt ~= nil and cnt > 0 and harvester.components.inventory then
                    for i = 1, cnt do
                        local item = SpawnPrefab(product)
                        if item ~= nil then
                            harvester.components.inventory:GiveItem(item)
                        end
                    end
                end
            end
        end
        return success
    end
end)
--- hook 动作
local old_dry_action_fn = ACTIONS.DRY.fn
ACTIONS.DRY.fn = function(act)
    local obj = act.invobject
    local target = act.target
    local cnt = batc_dry(target, obj)
    if target and act.doer then
        target.drymulti = GetUgData(act.doer, "dry_time_mult") or 1
        if cnt > 0 and target.drymulti ~= nil then
            target.drymulti = target.drymulti * (cnt + 1)
        end
    end
    local ret, str = old_dry_action_fn(act)
    if act.target ~= nil then
        act.target.drymulti = nil
    end
    if not ret and cnt > 0 then
        target.components.ugmark:Clear(BATCH_KEY)
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



-- 根据用户等级计算肥力值的倍率对肥力值进行修改
-- 并且返回原始的肥力值，如果之前的肥力值不存在，则返回nil
local function tryModifyNutrients(fertilizer, deployer)
    if not fertilizer or not deployer then return nil end
    local cacheValue = fertilizer.nutrients
    if not cacheValue then return nil end

    local multi = GetUgData(deployer, "deployable_mult", 0) + 1
    local newValue = {}
    for i, v in ipairs(cacheValue) do
        -- 土地肥力值的上限就是100
        table.insert(newValue, math.min(math.floor(v * multi), 100))
    end
    fertilizer.nutrients = newValue
    return cacheValue
end

---comments hook 施肥组件
AddComponentPostInit("deployable", function(deployable)
    local oldfn = deployable.Deploy
    deployable.Deploy = function(self, pt, deployer, rot)
        local inst = self.inst
        local fertilizer = inst.components.fertilizer
        local ret = tryModifyNutrients(fertilizer, deployer)
        local deployed = oldfn(self, pt, deployer, rot)
        if ret then
            inst.components.fertilizer.nutrients = ret
        end
        return deployed
    end
end)


--- comment 照料作物巨大化
AddComponentPostInit("farmplanttendable", function(tendable)
    local oldfn = tendable.TendTo
    tendable.TendTo = function(self, doer)
        if doer:HasTag("ugfarm_master") and self.inst.components.ugmark then
            self.inst.components.ugmark:Put("oversized", true)
        end
        return oldfn(self, doer)
    end
end)


local farmplants = require("prefabs/farm_plant_defs").PLANT_DEFS
for k, v in pairs(farmplants) do
    AddPrefabPostInit(v.prefab, function(inst)
        if TheWorld.ismastersim then
            inst:AddComponent("ugmark")
            inst.components.ugmark:SetFunc("oversized", function(data)
                if data then
                    inst.force_oversized = true
                end
            end)
        end
    end)
end



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
        local oldmin = self.minwaittime
        local oldmax = self.maxwaittime
        if mult ~= nil then
            -- 根据源码，这里同步缩小 min和max值 就能实现缩短时间，不需要copy代码
            if oldmin ~= nil and oldmax ~= nil then
                self.minwaittime = oldmin * mult
                self.maxwaittime = oldmax * mult
            end
        end
        
        if oldWaitForFish ~= nil then
            oldWaitForFish(self)
        end

        self.minwaittime = oldmin
        self.maxwaittime = oldmax
    end
end)







local function init_player_fn(player)

    local PLAYER = UGPOWERS.PLAYER
    local BLACK_NAMES = {
        wx78 = { PLAYER.SANITY, PLAYER.HEALTH, PLAYER.HUNGER }
    }

    local sys = player:AddComponent("ugsystem")
    local bnames = BLACK_NAMES[player.prefab]
    if bnames ~= nil then
        sys:SetAttachTestFn(function(name, ent)
            ---@diagnostic disable: undefined-field
            return not table.contains(bnames, name)
        end)
    end

    player:AddComponent("ugsync")
    player:ListenForEvent(UGEVENTS.TASK_FINISH, function(inst, data)
        sys:RemoveEntity(data.name)
    end)
    player:DoTaskInTime(0.1, function()
        player.components.ugsync:SyncPower()
    end)
end

AddPlayerPostInit(function(player)
    if TheWorld.ismastersim and player.prefab ~= "ugfoxgirl" then
        init_player_fn(player)
    end
end)





AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return
    end
    inst:ListenForEvent("ms_playerdespawnanddelete", function(_, player)
        inst.sys = player.components.ugsystem
    end)

    inst:ListenForEvent("ms_newplayerspawned", function(_, player)
        if inst.sys then
            inst.sys:Transform(player)
        end
    end)
end)





--添加镶嵌系统
local ITEMS_DEF = require("defs/ugitems_def")


local function init_equip_fn(owner)

    local ENHANCE_ITEMS = ITEMS_DEF.enhance.items

    ---comment 尝试消耗
    ---@param user table 玩家
    ---@param target_prefab string
    ---@return table|nil 数量
    local function consum_items(user, target_prefab)
        local inventory = user.components.inventory
        if not inventory then
            return nil
        end

        local temp = inventory:FindItem(function(i) return i.prefab == target_prefab end)

        local cnt = 0
        if temp ~= nil then
            cnt = temp.components.stackable ~= nil and temp.components.stackable:StackSize() or 1
        end
        return {
            item = temp,
            cnt  = cnt
        }
    end


    local function valid_items(lv, name)
        local items = ENHANCE_ITEMS[name]
        ---@diagnostic disable-next-line: undefined-field
        local common_fns_reverse = table.reverse(items)
        for _, v in ipairs(common_fns_reverse) do
            if lv >= v.lv and v.it ~= nil then
                return v.it
            end
        end
    end


    local function upgrade_gem(doer, inst, name)
        local sys = inst.components.ugsystem
        if not (sys ~= nil and name ~= nil) then
            return
        end
        local ent = sys:GetEntity(name)
        if ent == nil then
            UgSay(doer, "宝石不存在")
            return
        end

        local lv = ent.components.uglevel:GetLv()
        local is = valid_items(lv, name)

        if is ~= nil then
            for k, v in pairs(is) do
                local d = consum_items(doer, k)
                if d ~= nil and d.cnt > 0 then
                    local exp = d.cnt * v
                    ent.components.uglevel:XpDelta(exp)
                    if d.item ~= nil then
                        d.item:Remove()
                    end
                    -- 每次只升级一次
                    return
                end
            end
        end
    end


    local function load_gem_fn(doer, inst, gem)
        local power = gem.power

        local equip_powers = ITEMS_DEF.equips[inst.prefab]
        if table.contains(equip_powers, power) then
            if inst.components.ugsystem:GetEntity(power) ~= nil then
                return false
            else
                local cache_data = gem.comments.ugmark:Get("power_data")
                inst.components.ugsystem:AddEntity(power)
                if cache_data ~= nil then
                    inst.components.ugentity:OnLoad(cache_data.entity)
                    inst.components.uglevel:OnLoad(cache_data.lv)
                end
                return true
            end

        else
            return false
        end

        
    end


    local function unload_gem_fn(doer, inst, name)
        local sys = inst.components.ugsystem
        if not (sys ~= nil and name ~= nil) then
            return
        end
        local ent = sys:RemoveEntity(name)
        if ent == nil then
            UgSay(doer, "宝石不存在")
            return
        end

        local ex_data = ent.components.ugentity:OnSave()
        local lv_data = ent.components.uglevel:OnSave()

        local cache = {
            entity = ex_data,
            lv = lv_data,
        }

        local gem = SpawnPrefab(name .. "_gem")

        if gem ~= nil then
            gem.components.ugmark:Put("power_data", cache)
            doer.components.inventory:GiveItem(gem)
            ent:Remove()
        end
    end

    local function operate_gem_fn(player, inst, name, mode)
        if name ~= nil and inst ~= nil then
            if TheWorld.ismastersim then
                if mode == 1 then
                    unload_gem_fn(player, inst, name)
                elseif mode == 2 then
                    upgrade_gem(player, inst, name)
                end
            else
                SendModRPCToServer(MOD_RPC.ugapi.UnLoadGem, inst, name, mode)
            end
        end
    end


    owner.ugunload_gem = operate_gem_fn
    owner.ugload_gem = load_gem_fn

    if TheWorld.ismastersim then
        owner:AddComponent("ugsystem")
        owner:AddComponent("ugsync")
        owner:DoTaskInTime(0.1, function()
            owner.components.ugsync:SyncPower()
        end)
    end
end



--添加镶嵌系统
local equips = ITEMS_DEF.equips
for k, v in pairs(equips) do
    AddPrefabPostInit(k, init_equip_fn)
end





local berrybushs = {
    "berrybush_juicy",
    "berrybush",
    "berrybush2"
}
for _, v in ipairs(berrybushs) do
    AddPrefabPostInit(v, function (inst)
        inst:AddTag(UGTAGS.MAGIC_TARGET)
    end)
end




local function get_lv(inst)
    local sync = TheWorld.ismastersim and inst.components.ugsync or inst.replica.ugsync
    if sync ~= nil then
        return sync:GetLevel()
    end
end

--- 显示物品的额外信息
AddClassPostConstruct("widgets/hoverer", function(hoverer)
	local oldSetString = hoverer.text.SetString
	hoverer.text.SetString = function(text, str)
		local target = GLOBAL.TheInput:GetHUDEntityUnderMouse()
		target = (target and target.widget and target.widget.parent ~= nil and target.widget.parent.item) or
		TheInput:GetWorldEntityUnderMouse() or nil
		if target and target.GUID then
            local lv = get_lv(target)
			if lv ~= nil then
				str = str .."\n lv".. tostring(lv)
			end
		end
		return oldSetString(text, str)
	end
end)









local ITEM_DIR = "images/inventoryimages/"
local SKIN_DIR = "images/zxskins/"


local MOD_ITEMS = {  
    "zxstone", 
    "zxboss_proof"
 }

local SP_ITEMS = { 
    sanity = function (num)
        return Ingredient(CHARACTER_INGREDIENT.SANITY, num)
    end 
}


local function recipe_ingredients_fn(make)
    local ingredients = {}
    for k, v in pairs(make) do
        local i = nil
        if SP_ITEMS[k] ~= nil then
            i = SP_ITEMS[k](v)
        elseif table.contains(MOD_ITEMS, k) then
            i = Ingredient(k, v, ITEM_DIR .. k .. ".xml")
        else
            i = Ingredient(k, v)
        end
        table.insert(ingredients, i)
    end
    return ingredients
end


---添加配方通用函数
---@param name string 预制物名称
---@param data table 包含配方，科技和tab
local function add_mod_recipe(name, data)
    local extra = data.extra or {}
    local res   = data.res or {}

    local xml = res.xml or res.file or name
    local img = res.img or res.file or name

    if res.skinable then
        extra.atlas  = SKIN_DIR .. name .. "/" .. xml .. ".xml"
        extra.image  = img .. ".tex"
        if not res.noplace then
            extra.placer = name .. "_placer"
       end
    else
        extra.atlas = ITEM_DIR .. xml .. ".xml"
        extra.image = img .. ".tex"
    end

    AddRecipe2(
        name, 
        recipe_ingredients_fn(data.make), 
        data.tech, 
        extra, 
        data.filter
    )
end


local recipes = require("defs/ugrecipe_defs")
for _, v in ipairs(recipes) do
    add_mod_recipe(v.name, v.data)
end








local pcall = GLOBAL.pcall
local require = GLOBAL.require


-----------------------------------动作相关---------------------------------
local queueractlist = {} --可兼容排队论的动作
local actions_status, actions_data = pcall(require, "defs/ugaction_defs")
if actions_status then
    -- 导入自定义动作
    if actions_data.actions then
        for _, act in pairs(actions_data.actions) do

            local action = Action()
            action.id = act.id
            action.str = act.str
            action.fn = act.fn

            if act.actiondata then
                for k, data in pairs(act.actiondata) do
                    action[k] = data
                end
            end

            AddAction(action)

            --兼容排队论
            if act.canqueuer then
                queueractlist[act.id] = act.canqueuer
            end
            AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(action, act.state))
            AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(action, act.state))
        end
    end

    -- 导入动作与组件的绑定
    if actions_data.component_actions then
        for _, v in pairs(actions_data.component_actions) do
            local testfn = function(...)
                local actions = GLOBAL.select(-2, ...)
                for _, data in pairs(v.tests) do
                    if data and data.testfn and data.testfn(...) then
                        data.action = string.upper(data.action)
                        table.insert(actions, GLOBAL.ACTIONS[data.action])
                    end
                end
            end
            AddComponentAction(v.type, v.component, testfn)
        end
    end
    --修改老动作
    if actions_data.old_actions then
        for _, act in pairs(actions_data.old_actions) do
            if act.switch then
                local action = GLOBAL.ACTIONS[act.id]
                if act.actiondata then
                    for k, data in pairs(act.actiondata) do
                        action[k] = data
                    end
                end
                if act.state then
                    local testfn = act.state.testfn
                    AddStategraphPostInit("wilson", function(sg)
                        local old_handler = sg.actionhandlers[action].deststate
                        sg.actionhandlers[action].deststate = function(inst, action)
                            if testfn and testfn(inst, action) and act.state.deststate then
                                return act.state.deststate(inst, action)
                            end
                            return old_handler(inst, action)
                        end
                    end)
                    if act.state.client_testfn then
                        testfn = act.state.client_testfn
                    end
                    AddStategraphPostInit("wilson_client", function(sg)
                        local old_handler = sg.actionhandlers[action].deststate
                        sg.actionhandlers[action].deststate = function(inst, action)
                            if testfn and testfn(inst, action) and act.state.deststate then
                                return act.state.deststate(inst, action)
                            end
                            return old_handler(inst, action)
                        end
                    end)
                end
            end
        end
    end
end

--动作兼容行为排队论
local actionqueuer_status, actionqueuer_data = pcall(require, "components/actionqueuer")
if actionqueuer_status then
    if AddActionQueuerAction and next(queueractlist) then
        for k, v in pairs(queueractlist) do
            AddActionQueuerAction(v, k, true)
        end
    end
end
