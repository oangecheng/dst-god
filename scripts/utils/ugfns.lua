

function UgGainPowerExp(owner, name, exp)
    if exp ~= 0 then
        if owner.components.ugsystem then
            exp = math.max(1, math.floor(exp + 0.5))
            local power = owner.components.ugsystem:GetEntity(name)
            if power and power.components.uglevel then
                power.components.uglevel:XpDelta(exp)
            end
        end
    end
end


function PutUgData(owner, key, value)
    UgLog("PutUgData", key, value)
    local datas = owner.ugdata or {}
    datas[key] = value
    owner.ugdata = datas
end


function GetUgData(owner, key)
    if owner ~= nil and owner.ugdata ~= nil then
        return owner.ugdata[key]
    end
end