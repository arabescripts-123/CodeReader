-- DETECTOR DE IMPACTO / FÍSICA

print("Detector de impacto iniciado")

local players = game:GetService("Players")

local function monitorCharacter(char)
    local root = char:WaitForChild("HumanoidRootPart")

    local lastVel = root.AssemblyLinearVelocity

    game:GetService("RunService").Heartbeat:Connect(function()
        local vel = root.AssemblyLinearVelocity

        local diff = (vel - lastVel).Magnitude

        if diff > 50 then
            print("💥 IMPACTO DETECTADO EM:", char.Name)
            print("Velocidade atual:", vel)
            print("Mudança:", diff)
            print("-----------------------")
        end

        lastVel = vel
    end)
end

for _,plr in pairs(players:GetPlayers()) do
    if plr.Character then
        monitorCharacter(plr.Character)
    end

    plr.CharacterAdded:Connect(monitorCharacter)
end
