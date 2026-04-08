-- SPY + IMPACTO COMBINADO

local mt = getrawmetatable(game)
local old = mt.__namecall

setreadonly(mt,false)

mt.__namecall = newcclosure(function(self,...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" then
        print("📡 Remote:", self:GetFullName())

        for i,v in ipairs(args) do
            print("Arg",i,":",v)
        end
    end

    return old(self,...)
end)

setreadonly(mt,true)
