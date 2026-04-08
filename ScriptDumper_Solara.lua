-- SUPER REMOTE SPY (FOCADO EM AÇÕES)

print("Spy iniciado")

local mt = getrawmetatable(game)
local old = mt.__namecall

setreadonly(mt,false)

mt.__namecall = newcclosure(function(self,...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" or method == "InvokeServer" then
        
        print("\n==============================")
        print("📡 REMOTE DETECTADO")
        print("Nome:", self.Name)
        print("Caminho:", self:GetFullName())
        print("Método:", method)

        for i,v in ipairs(args) do
            print("Arg",i,":",typeof(v), v)
        end

        print("==============================\n")
    end

    return old(self,...)
end)

setreadonly(mt,true)
