-- DETECTOR SIMPLES (SEM BUG)

local player = game.Players.LocalPlayer

while true do
    task.wait(0.2)

    local char = player.Character
    if not char then continue end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then continue end

    local vel = root.Velocity

    if vel.Magnitude > 100 then
        print("🚨 FORÇA DETECTADA!")
        print("Velocidade:", vel)
        print("Magnitude:", vel.Magnitude)
    end
end
