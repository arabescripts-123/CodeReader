-- SIMPLE REMOTE LOGGER (SEM ERRO)

print("Spy simples iniciado")

local function monitorRemote(obj)
    if obj:IsA("RemoteEvent") then
        
        obj.OnClientEvent:Connect(function(...)
            print("\n📡 RECEBIDO DO SERVIDOR:")
            print("Remote:", obj:GetFullName())

            local args = {...}
            for i,v in ipairs(args) do
                print("Arg",i,":",v)
            end
        end)

    elseif obj:IsA("RemoteFunction") then
        
        local old = obj.OnClientInvoke
        obj.OnClientInvoke = function(...)
            print("\n📞 INVOKE DO SERVIDOR:")
            print("Remote:", obj:GetFullName())

            local args = {...}
            for i,v in ipairs(args) do
                print("Arg",i,":",v)
            end

            if old then
                return old(...)
            end
        end
    end
end

-- SCAN
for _,v in pairs(game:GetDescendants()) do
    monitorRemote(v)
end

-- NOVOS REMOTES
game.DescendantAdded:Connect(function(v)
    monitorRemote(v)
end)
