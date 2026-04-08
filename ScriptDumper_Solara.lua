local lastVelocity = {}

game:GetService("RunService").Heartbeat:Connect(function()
    local player = game.Players.LocalPlayer
    if not player.Character then return end
    
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local vel = root.Velocity

    if lastVelocity[player] then
        local change = (vel - lastVelocity[player]).Magnitude

        if change > 100 then
            print("🚨 IMPACTO FORTE DETECTADO!")
            print("Velocidade:", vel)
            print("Mudança:", change)
        end
    end

    lastVelocity[player] = vel
end)
