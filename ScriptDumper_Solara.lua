-- Game Analyzer - Versão Universal
-- Extrai estrutura, remotes, valores, atributos e propriedades úteis
print("[GameAnalyzer] Iniciando...")

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

pcall(function()
    if game.CoreGui:FindFirstChild("GameAnalyzerGui") then
        game.CoreGui:FindFirstChild("GameAnalyzerGui"):Destroy()
    end
end)

-- ============ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameAnalyzerGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
MainFrame.Position = UDim2.new(0.5, -450, 0.5, -320)
MainFrame.Size = UDim2.new(0, 900, 0, 640)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local ms = Instance.new("UIStroke")
ms.Parent = MainFrame
ms.Color = Color3.fromRGB(70, 45, 150)
ms.Thickness = 1.5

-- Title
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🔍 Game Analyzer - Escaneando..."
Title.TextColor3 = Color3.fromRGB(200, 180, 255)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Active = true

-- Dragging
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local d = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Tabs
local tabNames = {"Estrutura", "Remotes", "Valores", "Objetos 3D", "Player Info"}
local tabBtns = {}
local tabContents = {}

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(80, 50, 160) or Color3.fromRGB(35, 35, 50)
    btn.Position = UDim2.new(0, 10 + (i-1) * 110, 0, 44)
    btn.Size = UDim2.new(0, 105, 0, 26)
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 180, 255)
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    tabBtns[i] = btn

    local scroll = Instance.new("ScrollingFrame")
    scroll.Parent = MainFrame
    scroll.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    scroll.Position = UDim2.new(0, 10, 0, 75)
    scroll.Size = UDim2.new(1, -20, 1, -130)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 70, 220)
    scroll.BorderSizePixel = 0
    scroll.Visible = (i == 1)
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

    local txt = Instance.new("TextLabel")
    txt.Parent = scroll
    txt.BackgroundTransparency = 1
    txt.Position = UDim2.new(0, 8, 0, 5)
    txt.Size = UDim2.new(1, -16, 1, 0)
    txt.Font = Enum.Font.Code
    txt.Text = ""
    txt.TextColor3 = Color3.fromRGB(200, 195, 230)
    txt.TextSize = 12
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.TextYAlignment = Enum.TextYAlignment.Top
    txt.TextWrapped = true
    txt.AutomaticSize = Enum.AutomaticSize.Y
    txt.RichText = true

    tabContents[i] = {scroll = scroll, text = txt, data = ""}
end

local function switchTab(idx)
    for i, btn in ipairs(tabBtns) do
        btn.BackgroundColor3 = (i == idx) and Color3.fromRGB(80, 50, 160) or Color3.fromRGB(35, 35, 50)
        tabContents[i].scroll.Visible = (i == idx)
    end
end
for i, btn in ipairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() switchTab(i) end)
end

-- Botoes inferiores
local function makeBottomBtn(text, xPos, color)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = color
    btn.Position = UDim2.new(0, xPos, 1, -45)
    btn.Size = UDim2.new(0, 130, 0, 35)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 220, 255)
    btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local bStroke = Instance.new("UIStroke")
    bStroke.Parent = btn
    bStroke.Color = Color3.fromRGB(70, 45, 150)
    bStroke.Thickness = 1
    bStroke.Transparency = 0.5
    return btn
end

local copyBtn = makeBottomBtn("📋 Copiar Aba", 10, Color3.fromRGB(100, 60, 220))
local copyAllBtn = makeBottomBtn("📋 Copiar Tudo", 150, Color3.fromRGB(70, 45, 150))
local posBtn = makeBottomBtn("📍 Copiar Pos", 290, Color3.fromRGB(130, 80, 200))
local rejoinBtn = makeBottomBtn("🔄 Rejoin", 760, Color3.fromRGB(160, 40, 40))

-- ============ FUNCOES DE UPDATE ============
local function updateTab(idx)
    tabContents[idx].text.Text = tabContents[idx].data
    task.wait()
    tabContents[idx].scroll.CanvasSize = UDim2.new(0, 0, 0, tabContents[idx].text.AbsoluteSize.Y + 20)
end

local function appendTab(idx, text)
    tabContents[idx].data = tabContents[idx].data .. text
end

-- ============ TAB 1: ESTRUTURA (arvore de scripts/pastas) ============
local function scanStructure(obj, path, indent, maxDepth)
    if indent > (maxDepth or 6) then return end
    local name = obj.Name
    local indentStr = string.rep("  ", indent)
    local currentPath = path .. "/" .. name

    local icon = ""
    if obj:IsA("LocalScript") then icon = "📜 [LocalScript]"
    elseif obj:IsA("ModuleScript") then icon = "📦 [Module]"
    elseif obj:IsA("Script") then icon = "⚙️ [Script]"
    elseif obj:IsA("Folder") then icon = "📁"
    elseif obj:IsA("Model") then icon = "📁"
    elseif obj:IsA("RemoteEvent") then icon = "🔴 [RemoteEvent]"
    elseif obj:IsA("RemoteFunction") then icon = "🟡 [RemoteFunc]"
    elseif obj:IsA("BindableEvent") then icon = "🟢 [Bindable]"
    elseif obj:IsA("ValueBase") then icon = "💎 [Value]"
    else return end -- so mostra objetos relevantes

    appendTab(1, indentStr .. icon .. " " .. name .. "\n")

    for _, child in pairs(obj:GetChildren()) do
        pcall(function() scanStructure(child, currentPath, indent + 1, maxDepth) end)
    end
end

-- ============ TAB 2: REMOTES (todos RemoteEvents/Functions com path) ============
local function scanRemotes()
    local count = 0
    local function scan(parent, path)
        for _, obj in pairs(parent:GetChildren()) do
            pcall(function()
                local p = path .. "/" .. obj.Name
                if obj:IsA("RemoteEvent") then
                    appendTab(2, "🔴 RemoteEvent: " .. obj.Name .. "\n   Path: " .. p .. "\n\n")
                    count = count + 1
                elseif obj:IsA("RemoteFunction") then
                    appendTab(2, "🟡 RemoteFunction: " .. obj.Name .. "\n   Path: " .. p .. "\n\n")
                    count = count + 1
                elseif obj:IsA("UnreliableRemoteEvent") then
                    appendTab(2, "🟠 UnreliableRemote: " .. obj.Name .. "\n   Path: " .. p .. "\n\n")
                    count = count + 1
                elseif obj:IsA("BindableEvent") then
                    appendTab(2, "🟢 BindableEvent: " .. obj.Name .. "\n   Path: " .. p .. "\n\n")
                    count = count + 1
                elseif obj:IsA("BindableFunction") then
                    appendTab(2, "🔵 BindableFunction: " .. obj.Name .. "\n   Path: " .. p .. "\n\n")
                    count = count + 1
                end
                scan(obj, p)
            end)
        end
    end

    appendTab(2, "=== ReplicatedStorage ===\n\n")
    scan(game:GetService("ReplicatedStorage"), "ReplicatedStorage")

    appendTab(2, "\n=== Workspace ===\n\n")
    scan(workspace, "Workspace")

    pcall(function()
        appendTab(2, "\n=== Players/LocalPlayer ===\n\n")
        scan(player, "Players/" .. player.Name)
    end)

    appendTab(2, "\n--- Total: " .. count .. " remotes encontrados ---\n")
end

-- ============ TAB 3: VALORES (IntValue, StringValue, BoolValue, Attributes) ============
local function scanValues()
    local function scanVal(parent, path)
        for _, obj in pairs(parent:GetChildren()) do
            pcall(function()
                local p = path .. "/" .. obj.Name
                if obj:IsA("ValueBase") then
                    local val = "?"
                    pcall(function() val = tostring(obj.Value) end)
                    appendTab(3, "💎 " .. obj.ClassName .. ": " .. obj.Name .. " = " .. val .. "\n   Path: " .. p .. "\n\n")
                end

                -- Atributos
                local attrs = obj:GetAttributes()
                if attrs and next(attrs) then
                    for k, v in pairs(attrs) do
                        appendTab(3, "🏷️ Attribute: " .. obj.Name .. "." .. k .. " = " .. tostring(v) .. " (" .. typeof(v) .. ")\n   Path: " .. p .. "\n\n")
                    end
                end

                scanVal(obj, p)
            end)
        end
    end

    appendTab(3, "=== ReplicatedStorage ===\n\n")
    scanVal(game:GetService("ReplicatedStorage"), "ReplicatedStorage")

    appendTab(3, "\n=== Workspace ===\n\n")
    scanVal(workspace, "Workspace")

    pcall(function()
        appendTab(3, "\n=== Player Character ===\n\n")
        if player.Character then
            scanVal(player.Character, "Character")
        end
    end)

    pcall(function()
        appendTab(3, "\n=== PlayerGui ===\n\n")
        scanVal(player:WaitForChild("PlayerGui", 2), "PlayerGui")
    end)

    pcall(function()
        appendTab(3, "\n=== Leaderstats ===\n\n")
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            for _, v in pairs(ls:GetChildren()) do
                pcall(function()
                    appendTab(3, "⭐ " .. v.ClassName .. ": " .. v.Name .. " = " .. tostring(v.Value) .. "\n")
                end)
            end
        else
            appendTab(3, "(sem leaderstats)\n")
        end
    end)
end

-- ============ TAB 4: OBJETOS 3D (BaseParts importantes, Tools, etc) ============
local function scanObjects()
    -- Pastas importantes no workspace
    appendTab(4, "=== FILHOS DIRETOS DO WORKSPACE ===\n\n")
    for _, obj in pairs(workspace:GetChildren()) do
        pcall(function()
            local info = obj.ClassName
            if obj:IsA("BasePart") then
                info = info .. string.format(" | Pos:(%.0f,%.0f,%.0f) Size:(%.0f,%.0f,%.0f) Anchored:%s CanCollide:%s",
                    obj.Position.X, obj.Position.Y, obj.Position.Z,
                    obj.Size.X, obj.Size.Y, obj.Size.Z,
                    tostring(obj.Anchored), tostring(obj.CanCollide))
                if obj.Velocity.Magnitude > 0.1 then
                    info = info .. string.format(" Vel:(%.0f,%.0f,%.0f) Speed:%.0f",
                        obj.Velocity.X, obj.Velocity.Y, obj.Velocity.Z, obj.Velocity.Magnitude)
                end
            elseif obj:IsA("Model") then
                local count = #obj:GetDescendants()
                info = info .. " | " .. count .. " descendentes"
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if hrp then
                    info = info .. string.format(" | Pos:(%.0f,%.0f,%.0f)", hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
                end
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum then
                    info = info .. string.format(" | HP:%.0f/%.0f WalkSpeed:%.0f", hum.Health, hum.MaxHealth, hum.WalkSpeed)
                end
            elseif obj:IsA("Folder") then
                info = info .. " | " .. #obj:GetChildren() .. " filhos"
            end
            appendTab(4, "📦 " .. obj.Name .. " [" .. info .. "]\n")
        end)
    end

    -- Bolas / Projeteis (busca especifica)
    appendTab(4, "\n=== BUSCA: BOLAS / PROJETEIS ===\n\n")
    local found = false
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("BasePart") and (
                obj.Name:lower():find("ball") or
                obj.Name:lower():find("projectile") or
                obj.Name:lower():find("bullet") or
                obj.Name:lower():find("bola")
            ) then
                found = true
                local info = string.format("Pos:(%.0f,%.0f,%.0f) Vel:(%.0f,%.0f,%.0f) Speed:%.0f Size:(%.1f,%.1f,%.1f) Anchored:%s",
                    obj.Position.X, obj.Position.Y, obj.Position.Z,
                    obj.Velocity.X, obj.Velocity.Y, obj.Velocity.Z, obj.Velocity.Magnitude,
                    obj.Size.X, obj.Size.Y, obj.Size.Z,
                    tostring(obj.Anchored))
                local path = obj:GetFullName()
                appendTab(4, "🔵 " .. obj.Name .. "\n   " .. info .. "\n   Path: " .. path .. "\n")

                -- Atributos da bola
                local attrs = obj:GetAttributes()
                if attrs and next(attrs) then
                    for k, v in pairs(attrs) do
                        appendTab(4, "   Attr: " .. k .. " = " .. tostring(v) .. "\n")
                    end
                end
                -- Filhos da bola
                for _, child in pairs(obj:GetChildren()) do
                    appendTab(4, "   Child: " .. child.Name .. " [" .. child.ClassName .. "]\n")
                end
                appendTab(4, "\n")
            end
        end)
    end
    if not found then appendTab(4, "(nenhuma bola/projetil encontrado)\n") end

    -- NPCs / Humanoids no workspace
    appendTab(4, "\n=== HUMANOIDS NO WORKSPACE ===\n\n")
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Humanoid") and obj.Parent and not game.Players:GetPlayerFromCharacter(obj.Parent) then
                local char = obj.Parent
                local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
                local posStr = hrp and string.format("Pos:(%.0f,%.0f,%.0f)", hrp.Position.X, hrp.Position.Y, hrp.Position.Z) or ""
                appendTab(4, "🤖 " .. char.Name .. " | HP:%.0f/%.0f WalkSpeed:%.0f " .. posStr .. "\n   Path: " .. char:GetFullName() .. "\n\n")
            end
        end)
    end
end

-- ============ TAB 5: PLAYER INFO ============
local function scanPlayer()
    appendTab(5, "=== INFO DO JOGADOR ===\n\n")
    appendTab(5, "Nome: " .. player.Name .. "\n")
    appendTab(5, "DisplayName: " .. player.DisplayName .. "\n")
    appendTab(5, "UserId: " .. player.UserId .. "\n")
    pcall(function() appendTab(5, "Team: " .. tostring(player.Team and player.Team.Name or "nenhum") .. "\n") end)
    appendTab(5, "PlaceId: " .. game.PlaceId .. "\n")
    appendTab(5, "JobId: " .. game.JobId .. "\n\n")

    -- Character info
    if player.Character then
        local char = player.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if hum then
            appendTab(5, "=== CHARACTER ===\n\n")
            appendTab(5, "Health: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. "\n")
            appendTab(5, "WalkSpeed: " .. hum.WalkSpeed .. "\n")
            appendTab(5, "JumpPower: " .. hum.JumpPower .. "\n")
            appendTab(5, "JumpHeight: " .. hum.JumpHeight .. "\n")
        end
        if root then
            appendTab(5, string.format("Position: (%.0f, %.0f, %.0f)\n", root.Position.X, root.Position.Y, root.Position.Z))
        end

        -- Scripts no character
        appendTab(5, "\n=== SCRIPTS NO CHARACTER ===\n\n")
        for _, obj in pairs(char:GetDescendants()) do
            pcall(function()
                if obj:IsA("LocalScript") or obj:IsA("Script") or obj:IsA("ModuleScript") then
                    local icon = obj:IsA("LocalScript") and "📜" or obj:IsA("ModuleScript") and "📦" or "⚙️"
                    appendTab(5, icon .. " " .. obj.Name .. " [" .. obj.ClassName .. "]\n   Path: " .. obj:GetFullName() .. "\n")
                end
            end)
        end

        -- Atributos do character
        appendTab(5, "\n=== ATRIBUTOS DO CHARACTER ===\n\n")
        local attrs = char:GetAttributes()
        if attrs and next(attrs) then
            for k, v in pairs(attrs) do
                appendTab(5, "🏷️ " .. k .. " = " .. tostring(v) .. " (" .. typeof(v) .. ")\n")
            end
        else
            appendTab(5, "(sem atributos)\n")
        end

        -- Atributos do Humanoid
        if hum then
            local hAttrs = hum:GetAttributes()
            if hAttrs and next(hAttrs) then
                appendTab(5, "\n=== ATRIBUTOS DO HUMANOID ===\n\n")
                for k, v in pairs(hAttrs) do
                    appendTab(5, "🏷️ " .. k .. " = " .. tostring(v) .. " (" .. typeof(v) .. ")\n")
                end
            end
        end
    end

    -- Backpack (tools)
    appendTab(5, "\n=== BACKPACK (TOOLS) ===\n\n")
    pcall(function()
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, tool in pairs(bp:GetChildren()) do
                if tool:IsA("Tool") then
                    appendTab(5, "🗡️ " .. tool.Name .. "\n")
                    for _, child in pairs(tool:GetDescendants()) do
                        if child:IsA("LocalScript") or child:IsA("Script") or child:IsA("ModuleScript") then
                            appendTab(5, "   " .. child.ClassName .. ": " .. child.Name .. "\n")
                        end
                    end
                end
            end
        end
    end)

    -- PlayerGui
    appendTab(5, "\n=== PLAYER GUI (telas) ===\n\n")
    pcall(function()
        local pg = player:FindFirstChild("PlayerGui")
        if pg then
            for _, gui in pairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    appendTab(5, "🖥️ " .. gui.Name .. " | Enabled:" .. tostring(gui.Enabled) .. " | " .. #gui:GetDescendants() .. " descendentes\n")
                end
            end
        end
    end)
end

-- ============ EXECUTAR SCANS ============
task.spawn(function()
    -- Tab 1: Estrutura
    appendTab(1, "=== WORKSPACE ===\n\n")
    for _, child in pairs(workspace:GetChildren()) do
        pcall(function() scanStructure(child, "Workspace", 0, 4) end)
    end
    appendTab(1, "\n=== REPLICATED STORAGE ===\n\n")
    for _, child in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
        pcall(function() scanStructure(child, "ReplicatedStorage", 0, 4) end)
    end
    appendTab(1, "\n=== STARTER GUI ===\n\n")
    for _, child in pairs(game:GetService("StarterGui"):GetChildren()) do
        pcall(function() scanStructure(child, "StarterGui", 0, 3) end)
    end
    updateTab(1)

    -- Tab 2: Remotes
    scanRemotes()
    updateTab(2)

    -- Tab 3: Valores
    scanValues()
    updateTab(3)

    -- Tab 4: Objetos 3D
    scanObjects()
    updateTab(4)

    -- Tab 5: Player
    scanPlayer()
    updateTab(5)

    Title.Text = "🔍 Game Analyzer - Concluído! (" .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. ")"
    Title.TextColor3 = Color3.fromRGB(180, 140, 255)
end)

-- ============ BOTOES ============
local currentTab = 1

for i, btn in ipairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() currentTab = i; switchTab(i) end)
end

copyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        setclipboard(tabContents[currentTab].data)
        copyBtn.Text = "✓ Copiado!"
        task.wait(1)
        copyBtn.Text = "📋 Copiar Aba"
    end)
end)

copyAllBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local all = ""
        for i, name in ipairs(tabNames) do
            all = all .. "\n\n========== " .. name:upper() .. " ==========\n\n" .. tabContents[i].data
        end
        setclipboard(all)
        copyAllBtn.Text = "✓ Copiado!"
        task.wait(1)
        copyAllBtn.Text = "📋 Copiar Tudo"
    end)
end)

posBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            setclipboard(string.format("CFrame.new(%.0f, %.0f, %.0f)", root.Position.X, root.Position.Y, root.Position.Z))
            posBtn.Text = "✓ Copiado!"
            task.wait(1)
            posBtn.Text = "📍 Copiar Pos"
        end
    end)
end)

rejoinBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Z then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("[GameAnalyzer] Carregado! Z=Mostrar/Esconder")
