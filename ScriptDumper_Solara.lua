-- Script Dumper - Versão Solara (sem decompile)
print("[ScriptDumper] Iniciando...")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptDumperGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
MainFrame.Size = UDim2.new(0, 800, 0, 600)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Script Explorer - Extraindo..."
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

local RejoinBtn = Instance.new("TextButton")
RejoinBtn.Parent = MainFrame
RejoinBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
RejoinBtn.Position = UDim2.new(1, -40, 0, 5)
RejoinBtn.Size = UDim2.new(0, 35, 0, 30)
RejoinBtn.Font = Enum.Font.GothamBold
RejoinBtn.Text = "R"
RejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RejoinBtn.TextSize = 14

local RejoinCorner = Instance.new("UICorner")
RejoinCorner.CornerRadius = UDim.new(0, 6)
RejoinCorner.Parent = RejoinBtn

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ScrollFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollFrame.Size = UDim2.new(1, -20, 1, -100)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.BorderSizePixel = 0

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 6)
ScrollCorner.Parent = ScrollFrame

local TextBox = Instance.new("TextLabel")
TextBox.Parent = ScrollFrame
TextBox.BackgroundTransparency = 1
TextBox.Position = UDim2.new(0, 10, 0, 10)
TextBox.Size = UDim2.new(1, -20, 1, 0)
TextBox.Font = Enum.Font.Code
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(200, 200, 200)
TextBox.TextSize = 12
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.TextYAlignment = Enum.TextYAlignment.Top
TextBox.TextWrapped = true
TextBox.AutomaticSize = Enum.AutomaticSize.Y

local CopyBtn = Instance.new("TextButton")
CopyBtn.Parent = MainFrame
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
CopyBtn.Position = UDim2.new(1, -110, 1, -45)
CopyBtn.Size = UDim2.new(0, 100, 0, 35)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.Text = "Copiar"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.TextSize = 14

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyBtn

local CopyPosBtn = Instance.new("TextButton")
CopyPosBtn.Parent = MainFrame
CopyPosBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
CopyPosBtn.Position = UDim2.new(0, 10, 1, -45)
CopyPosBtn.Size = UDim2.new(0, 120, 0, 35)
CopyPosBtn.Font = Enum.Font.GothamBold
CopyPosBtn.Text = "📍 Copiar Pos"
CopyPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyPosBtn.TextSize = 14

local CopyPosCorner = Instance.new("UICorner")
CopyPosCorner.CornerRadius = UDim.new(0, 6)
CopyPosCorner.Parent = CopyPosBtn

local allScripts = ""

local function scanObject(obj, path, indent)
    local currentPath = path .. "/" .. obj.Name
    local indentStr = string.rep("  ", indent)
    
    if obj:IsA("LocalScript") then
        allScripts = allScripts .. indentStr .. "📜 [LocalScript] " .. obj.Name .. "\n"
        allScripts = allScripts .. indentStr .. "   Path: " .. currentPath .. "\n"
    elseif obj:IsA("ModuleScript") then
        allScripts = allScripts .. indentStr .. "📦 [ModuleScript] " .. obj.Name .. "\n"
        allScripts = allScripts .. indentStr .. "   Path: " .. currentPath .. "\n"
    elseif obj:IsA("Script") then
        allScripts = allScripts .. indentStr .. "⚙️ [Script] " .. obj.Name .. "\n"
        allScripts = allScripts .. indentStr .. "   Path: " .. currentPath .. "\n"
    elseif obj:IsA("Folder") or obj:IsA("Model") then
        allScripts = allScripts .. indentStr .. "📁 " .. obj.Name .. "\n"
    end
    
    TextBox.Text = allScripts
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, TextBox.AbsoluteSize.Y + 20)
    
    for _, child in pairs(obj:GetChildren()) do
        pcall(function()
            scanObject(child, currentPath, indent + 1)
        end)
    end
end

allScripts = "-- ESTRUTURA DO JOGO\n-- Gerado por Script Explorer\n\n"
TextBox.Text = allScripts

task.spawn(function()
    allScripts = allScripts .. "\n=== WORKSPACE ===\n"
    scanObject(game.Workspace, "Workspace", 0)
    
    allScripts = allScripts .. "\n=== REPLICATED STORAGE ===\n"
    scanObject(game.ReplicatedStorage, "ReplicatedStorage", 0)
    
    allScripts = allScripts .. "\n=== REPLICATED FIRST ===\n"
    scanObject(game.ReplicatedFirst, "ReplicatedFirst", 0)
    
    allScripts = allScripts .. "\n=== STARTER GUI ===\n"
    scanObject(game.StarterGui, "StarterGui", 0)
    
    allScripts = allScripts .. "\n=== STARTER PLAYER ===\n"
    scanObject(game.StarterPlayer, "StarterPlayer", 0)
    
    allScripts = allScripts .. "\n=== LOCAL PLAYER ===\n"
    scanObject(game.Players.LocalPlayer, "Players/LocalPlayer", 0)
    
    Title.Text = "Script Explorer - Concluído!"
    Title.TextColor3 = Color3.fromRGB(0, 255, 0)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, TextBox.AbsoluteSize.Y + 20)
end)

CopyBtn.MouseButton1Click:Connect(function()
    setclipboard(TextBox.Text)
    CopyBtn.Text = "Copiado!"
    CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    task.wait(1)
    CopyBtn.Text = "Copiar"
    CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
end)

CopyPosBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = player.Character.HumanoidRootPart.Position
            local posText = string.format("CFrame.new(%.0f, %.0f, %.0f)", pos.X, pos.Y, pos.Z)
            setclipboard(posText)
            CopyPosBtn.Text = "✓ Copiado!"
            CopyPosBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            task.wait(1)
            CopyPosBtn.Text = "📍 Copiar Pos"
            CopyPosBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end
    end)
end)

RejoinBtn.MouseButton1Click:Connect(function()
    local TeleportService = game:GetService("TeleportService")
    local player = game.Players.LocalPlayer
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
end)

local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Z then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("[ScriptDumper] Interface carregada!")
