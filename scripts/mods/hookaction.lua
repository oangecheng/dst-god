local pcall = GLOBAL.pcall
local require = GLOBAL.require




-----------------------------------动作相关---------------------------------
local queueractlist = {} --可兼容排队论的动作
local actions_status, actions_data = pcall(require, "defs/global/actions")
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
