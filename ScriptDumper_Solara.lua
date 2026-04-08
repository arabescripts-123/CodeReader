-- FIXED VERSION (SEM ERRO)

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()

local root = char:WaitForChild("HumanoidRootPart")

for _,plr in pairs(game.Players:GetPlayers()) do
    if plr ~= player then
        
        local targetChar = plr.Character
        if targetChar then
            
            local hrp = targetChar:FindFirstChild("HumanoidRootPart")

            if hrp then
                local distance = (hrp.Position - root.Position).Magnitude

                if distance < 10 then
                    local direction = (hrp.Position - root.Position)

                    if direction.Magnitude > 0 then
                        direction = direction.Unit

                        hrp.AssemblyLinearVelocity = direction * 300 + Vector3.new(0,150,0)
                    end
                end
            end
        end
    end
end
