-- KICK BUTTON SCRIPT

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local UIS = game:GetService("UserInputService")

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0,120,0,50)
btn.Position = UDim2.new(0,50,0.5,0)
btn.Text = "CHUTAR"
btn.BackgroundColor3 = Color3.fromRGB(60,200,60)

-- ANIMAÇÃO (pode trocar se quiser outra)
local anim = Instance.new("Animation")
anim.AnimationId = "rbxassetid://522635514" -- animação de chute (padrão Roblox)

local humanoid = char:WaitForChild("Humanoid")
local track = humanoid:LoadAnimation(anim)

-- CONTROLE
local canKick = true

btn.MouseButton1Click:Connect(function()
    if not canKick then return end
    canKick = false

    track:Play()

    local root = char:FindFirstChild("HumanoidRootPart")

    -- DETECTAR CONTATO
    local conn
    conn = root.Touched:Connect(function(hit)
        local targetChar = hit.Parent
        local targetHum = targetChar and targetChar:FindFirstChild("Humanoid")

        if targetHum and targetChar ~= char then
            local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")

            if targetRoot then
                -- DIREÇÃO DO CHUTE
                local direction = (targetRoot.Position - root.Position).Unit

                -- FORÇA
                targetRoot.Velocity = direction * 100 + Vector3.new(0,50,0)
            end
        end
    end)

    -- tempo do chute
    task.wait(0.5)

    if conn then conn:Disconnect() end

    task.wait(1)
    canKick = true
end)
