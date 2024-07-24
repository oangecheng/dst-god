

local AWARD = UGTASKS.AWARD



local function win(inst, owner, rewards)
    if rewards ~= nil then
        for _, v in ipairs(rewards) do
            if v.type == AWARD.ITEM then
                local ent = SpawnPrefab(v.target)
                if ent ~= nil then
                    if ent.components.stackable ~= nil and v.num > 1 then
                        ent.components.stackable:SetStackSize(v.num)
                    end
                    if owner.components.inventory ~= nil then
                        owner.components.inventory:GiveItem(ent)
                    end
                end
            end
        end
    end
end


local function lose(inst, owner, punish)
    
end


return {
    winfn = win,
    losefn = lose
}


