--- 这个是物品的代码，可以不用修改
local PREFAB_NAME = "testitem"
----这个是皮肤文件的名称，也就是Spriter文件的名字
local SKIN_NAME = "testitem1"
--- 一般都会有一个初始动画，命名为idle，这个是你建造的时候预览的动画
--- 如果是t键生成的，是看不到这个显示的，可以不用加，只是在建造的时候看不见预览图，建好了依旧可以看到
local IDLEANIM = "idle"
--- 需要测试的动画名称，想测试文件当中的哪个动画，就改成那个动画的名称
local TESTANIM = "idle"


local assets = {
    Asset("ANIM", "anim/"..SKIN_NAME..".zip"),
}

local function MakeTestItem(item)

    local function fn()
        local inst = CreateEntity()
        
        inst.entity:AddTransform()
        inst.entity:AddAnimState() 
        inst.entity:AddMiniMapEntity()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()
        inst:AddTag("structure")
        MakeObstaclePhysics(inst, .2)

        inst.AnimState:SetBank(SKIN_NAME) 
        inst.AnimState:SetBuild(SKIN_NAME)
        inst.AnimState:PlayAnimation(TESTANIM)
    
        inst.entity:SetPristine()
        
        if not TheWorld.ismastersim then
            return inst
        end
    
        inst:AddComponent("inspectable")
    
        return inst
    end
    
    return Prefab(item, fn, assets, nil)
end


return MakeTestItem(PREFAB_NAME),
MakePlacer(PREFAB_NAME.."_placer", SKIN_NAME, SKIN_NAME, IDLEANIM)

