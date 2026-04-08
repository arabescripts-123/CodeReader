-- Game Analyzer - Versão Universal
-- Extrai estrutura, remotes, valores, atributos e propriedades úteis
print("[GameAnalyzer] Iniciando...")

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- Controle de busca
local alreadyScanned = false

local guiParent = gethui and gethui() or game:GetService("CoreGui")
if not guiParent then guiParent = player:WaitForChild("PlayerGui") end

pcall(function()
    local existing = guiParent:FindFirstChild("GameAnalyzerGui")
    if existing then existing:Destroy() end
end)

-- ============ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameAnalyzerGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

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
Title.Text = "🔍 Game Analyzer - Clique em Buscar"
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

-- ============ BARRA DE PESQUISA (FILTRO) ============
local SearchFrame = Instance.new("Frame")
SearchFrame.Parent = MainFrame
SearchFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
SearchFrame.Position = UDim2.new(1, -300, 0, 44)
SearchFrame.Size = UDim2.new(0, 290, 0, 26)
Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 6)

local SearchBox = Instance.new("TextBox")
SearchBox.Parent = SearchFrame
SearchBox.BackgroundTransparency = 1
SearchBox.Size = UDim2.new(1, -60, 1, 0)
SearchBox.Position = UDim2.new(0, 10, 0, 0)
SearchBox.Font = Enum.Font.Gotham
SearchBox.PlaceholderText = "🔍 Filtrar..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 150)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(200, 195, 230)
SearchBox.TextSize = 12
SearchBox.TextXAlignment = Enum.TextXAlignment.Left

local ClearFilterBtn = Instance.new("TextButton")
ClearFilterBtn.Parent = SearchFrame
ClearFilterBtn.BackgroundColor3 = Color3.fromRGB(80, 50, 160)
ClearFilterBtn.Position = UDim2.new(1, -50, 0, 3)
ClearFilterBtn.Size = UDim2.new(0, 44, 0, 20)
ClearFilterBtn.Font = Enum.Font.GothamBold
ClearFilterBtn.Text = "✕"
ClearFilterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearFilterBtn.TextSize = 12
ClearFilterBtn.BorderSizePixel = 0
Instance.new("UICorner", ClearFilterBtn).CornerRadius = UDim.new(0, 4)

ClearFilterBtn.MouseButton1Click:Connect(function()
    SearchBox.Text = ""
end)

-- Filtro em tempo real
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local filter = SearchBox.Text:lower()
    if filter == "" then
        -- Mostrar tudo
        for i = 1, #tabContents do
            tabContents[i].text.Text = tabContents[i].data
        end
    else
        -- Filtrar aba atual
        local currentData = tabContents[currentTab].data
        local lines = {}
        for line in currentData:gmatch("[^\n]+") do
            if line:lower():find(filter, 1, true) then
                table.insert(lines, line)
            end
        end
        
        local filtered = table.concat(lines, "\n")
        if #filtered == 0 then
            filtered = "<font color='\"#FF6B6B\"'>Nenhum resultado para: \"" .. SearchBox.Text .. "\"</font>"
        else
            -- Highlight
            filtered = filtered:gsub("(" .. filter:lower() .. ")", "<font color='\"#FFD93D\"'><b>$1</b></font>")
        end
        tabContents[currentTab].text.Text = filtered
    end
end)

-- Tabs
local tabNames = {"Copy Posição", "Estrutura", "Remotes", "Valores", "Objetos 3D", "Player Info", "Scripts", "Spy", "Script Detector"}
local tabBtns = {}
local tabContents = {}

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(80, 50, 160) or Color3.fromRGB(35, 35, 50)
    btn.Position = UDim2.new(0, 10 + (i-1) * 95, 0, 44)
    btn.Size = UDim2.new(0, 90, 0, 26)
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
local searchBtn = makeBottomBtn("🔍 Buscar", 290, Color3.fromRGB(60, 150, 60))
local helpBtn = makeBottomBtn("?", 430, Color3.fromRGB(255, 200, 0))
local saveBtn = makeBottomBtn("💾 Salvar .txt", 570, Color3.fromRGB(50, 130, 80))
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

-- ============ SISTEMA DE COMPORTAMENTO (ESSENCIAL) ============
local behaviorLog = {
    remotesFired = {},
    remotesInvoked = {},
    propertyChanges = {},
    loopsDetected = {},
    instancesCreated = {},
    servicesAccessed = {}
}

-- Sistema de risco
local riskScore = 0
local function addRisk(amount, reason)
    riskScore += amount
    appendTab(7, string.format("<font color='\"#FF6B6B\"'>🚨 +%d RISCO: %s</font>\n", amount, reason))
    updateTab(7)
end

-- ============ FUNÇÃO SAFE TOSTRING (evita crash) ============
local function safeToString(v)
    if v == nil then return "nil"
    elseif typeof(v) == "string" then return "\"" .. v .. "\""
    elseif typeof(v) == "Instance" then return "[Instance: " .. v:GetFullName() .. "]"
    elseif typeof(v) == "Vector3" then return string.format("Vector3(%.2f, %.2f, %.2f)", v.X, v.Y, v.Z)
    elseif typeof(v) == "CFrame" then return string.format("CFrame(%.2f, %.2f, %.2f)", v.Position.X, v.Position.Y, v.Position.Z)
    elseif typeof(v) == "Vector2" then return string.format("Vector2(%.2f, %.2f)", v.X, v.Y)
    elseif typeof(v) == "Color3" then return string.format("Color3(%.2f, %.2f, %.2f)", v.R, v.G, v.B)
    elseif typeof(v) == "UDim2" then return string.format("UDim2(%s, %s)", tostring(v.X.Scale), tostring(v.X.Offset))
    elseif typeof(v) == "BrickColor" then return "BrickColor." .. v.Name
    elseif typeof(v) == "boolean" then return v and "true" or "false"
    elseif typeof(v) == "number" then 
        if v == math.floor(v) then return tostring(v)
        else return string.format("%.4f", v) end
    elseif typeof(v) == "table" then 
        local keys = {}
        for k in pairs(v) do table.insert(keys, tostring(k)) end
        return "{table: " .. #keys .. " keys}"
    else return "[" .. typeof(v) .. "]" end
end

-- ============ INTERCEPTAR FireServer (GAME CHANGER) ============
local _behaviorHooked = false
local _playerMonitorConnections = {}

local function setupBehaviorInterceptor()
    if _behaviorHooked then
        appendTab(7, "⚠️ Interceptor já ativo\n")
        updateTab(7)
        return
    end
    
    pcall(function()
        local mt = getrawmetatable(game)
        if not mt then 
            appendTab(7, "❌ getrawmetatable não disponível\n")
            updateTab(7)
            return 
        end
        
        -- Salvar old com segurança
        local old = mt.__namecall
        
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- FireServer
            if method == "FireServer" then
                local name = self.Name
                behaviorLog.remotesFired[name] = (behaviorLog.remotesFired[name] or 0) + 1
                
                -- Verifica spam (10+ em 1 segundo = spam)
                if behaviorLog.remotesFired[name] > 10 then
                    addRisk(3, string.format("SPAM: %s chamado %dx", name, behaviorLog.remotesFired[name]))
                end
                
                -- Verifica argumentos suspeitos
                for i, arg in ipairs(args) do
                    local num = tonumber(arg)
                    if num and num > 9999 then
                        addRisk(5, string.format("VALOR EXTREMO: %s arg[%d] = %s", name, i, tostring(num)))
                    end
                end
                
                -- Log com safeToString
                local argStr = ""
                if #args > 0 then
                    local safeArgs = {}
                    for i, v in ipairs(args) do
                        table.insert(safeArgs, safeToString(v))
                    end
                    argStr = table.concat(safeArgs, ", ")
                else
                    argStr = "(sem args)"
                end
                
                appendTab(7, string.format(
                    "📡 <font color='\"#FF9500\"'>FireServer:</font> %s | <font color='\"#FFD700\"'>Calls: %d</font> | Args: %s\n",
                    name, behaviorLog.remotesFired[name], argStr
                ))
                updateTab(7)
                
            -- InvokeServer
            elseif method == "InvokeServer" then
                local name = self.Name
                behaviorLog.remotesInvoked[name] = (behaviorLog.remotesInvoked[name] or 0) + 1
                
                if behaviorLog.remotesInvoked[name] > 5 then
                    addRisk(2, string.format("InvokeServer spam: %s", name))
                end
                
                local argStr = ""
                if #args > 0 then
                    local safeArgs = {}
                    for i, v in ipairs(args) do
                        table.insert(safeArgs, safeToString(v))
                    end
                    argStr = table.concat(safeArgs, ", ")
                else
                    argStr = "(sem args)"
                end
                
                appendTab(7, string.format(
                    "📞 <font color='\"#00FF7F\"'>InvokeServer:</font> %s | Calls: %d | Args: %s\n",
                    name, behaviorLog.remotesInvoked[name], argStr
                ))
                updateTab(7)
            end
            
            -- Chamar old com segurança
            if old then
                return old(self, ...)
            end
        end)
        
        setreadonly(mt, true)
        _behaviorHooked = true
        appendTab(7, "✅ Interceptor de comportamento ativado\n")
        updateTab(7)
    end)
end

-- ============ DETECTAR ALTERAÇÕES NO PLAYER (com cleanup) ============
local function cleanupPlayerMonitor()
    for _, conn in pairs(_playerMonitorConnections) do
        pcall(function() conn:Disconnect() end)
    end
    _playerMonitorConnections = {}
end

local function setupPlayerMonitor()
    pcall(function()
        cleanupPlayerMonitor() -- Limpar conexões antigas
        
        local function monitorCharacter()
            cleanupPlayerMonitor() -- Limpar antes de monitorar
            
            local char = player.Character
            if not char then return end
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            
            -- WalkSpeed
            local wsConn = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if hum.WalkSpeed > 50 then
                    addRisk(10, string.format("⚠️ WALKSPEED EXTREMO: %d (normal: 16)", hum.WalkSpeed))
                elseif hum.WalkSpeed > 20 then
                    addRisk(3, string.format("⚠️ WalkSpeed alterado: %d", hum.WalkSpeed))
                end
                appendTab(7, string.format("<font color='\"#FF6B6B\"'>⚠️ WalkSpeed alterado: %d</font>\n", hum.WalkSpeed))
                updateTab(7)
            end)
            table.insert(_playerMonitorConnections, wsConn)
            
            -- JumpPower
            local jpConn = hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
                if hum.JumpPower > 100 then
                    addRisk(8, string.format("⚠️ JUMPPOWER EXTREMO: %d", hum.JumpPower))
                elseif hum.JumpPower > 50 then
                    addRisk(3, string.format("⚠️ JumpPower alterado: %d", hum.JumpPower))
                end
                appendTab(7, string.format("<font color='\"#FF6B6B\"'>⚠️ JumpPower alterado: %d</font>\n", hum.JumpPower))
                updateTab(7)
            end)
            table.insert(_playerMonitorConnections, jpConn)
            
            -- Health
            local hpConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
                if hum.Health > hum.MaxHealth then
                    addRisk(5, string.format("⚠️ HEALTH EXPLOIT: %.0f/%.0f", hum.Health, hum.MaxHealth))
                end
            end)
            table.insert(_playerMonitorConnections, hpConn)
            
            -- Health Max
            local maxHpConn = hum:GetPropertyChangedSignal("MaxHealth"):Connect(function()
                if hum.MaxHealth > 1000 then
                    addRisk(3, string.format("⚠️ MaxHealth alterado: %d", hum.MaxHealth))
                end
            end)
            table.insert(_playerMonitorConnections, maxHpConn)
            
            appendTab(7, "✅ Monitor de player ativado\n")
            updateTab(7)
        end
        
        monitorCharacter()
        local charConn = player.CharacterAdded:Connect(monitorCharacter)
        table.insert(_playerMonitorConnections, charConn)
    end)
end

-- ============ DETECTAR LOOPS SUSPEITOS (melhorado) ============
local _loopDetectorRunning = false

local function setupLoopDetector()
    if _loopDetectorRunning then return end
    _loopDetectorRunning = true
    
    task.spawn(function()
        local lastTick = tick()
        local loopCount = 0
        local loopSamples = {}
        local thresholds = {
            {limit = 500, risk = 10, msg = "LOOP EXTREMO"},  -- Muito suspeito
            {limit = 350, risk = 5, msg = "Loop muito rápido"},
            {limit = 250, risk = 2, msg = "Loop rápido"},
        }
        
        while _loopDetectorRunning do
            task.wait(0.01) -- 100Hz sample
            loopCount += 1
            
            local now = tick()
            if now - lastTick >= 1 then
                -- Calcular média de loops
                table.insert(loopSamples, loopCount)
                if #loopSamples > 10 then table.remove(loopSamples, 1) end
                
                local sum = 0
                for _, v in ipairs(loopSamples) do sum = sum + v end
                local avgSpeed = sum / #loopSamples
                
                -- Verificar thresholds
                for _, t in ipairs(thresholds) do
                    if loopCount > t.limit then
                        addRisk(t.risk, string.format("⚠️ %s: %d iter/seg (média: %.0f)", t.msg, loopCount, avgSpeed))
                        appendTab(7, string.format("<font color='\"#FF0000\"'>⚠️ %s: %d iter/seg (média: %.0f)</font>\n", t.msg, loopCount, avgSpeed))
                        updateTab(7)
                        break
                    end
                end
                
                loopCount = 0
                lastTick = now
            end
        end
    end)
end

-- ============ VARIÁVEIS PARA ANÁLISE ============
local importantRemotes = {}
local possibleExploits = {}
local possibleExploitsCode = {}
local detectedAntiCheats = {}

-- Palavras-chave para remotes importantes
local importantKeywords = {
    "attack", "damage", "hit", "fire", "shoot", "give", "reward",
    "money", "cash", "coin", "gold", "xp", "level", "exp",
    "health", "hp", "life", "kill", "death", "respawn",
    "admin", "mod", "owner", "ban", "kick", "warn",
    "teleport", "warp", "tp", "goto", "bring",
    "item", "equip", "inventory", "backpack", "drop",
    "trade", "transfer", "send", "receive",
    "vote", "report", "chat", "message",
    "unlock", "unban", "remove", "delete"
}

-- Padrões de exploits
local exploitPatterns = {
    {name = "AddMoney", pattern = {"money", "cash", "coin", "gold", "currency"}, argType = "number", suggestion = "AddMoney(value)", desc = "Adiciona dinheiro"},
    {name = "SetMoney", pattern = {"setmoney", "setcash", "setcoins"}, argType = "number", suggestion = "SetMoney(value)", desc = "Define valor de dinheiro"},
    {name = "AddXP", pattern = {"xp", "exp", "experience", "levelup"}, argType = "number", suggestion = "AddXP(value)", desc = "Adiciona experiência"},
    {name = "SetHealth", pattern = {"health", "hp", "life", "heal"}, argType = "number", suggestion = "SetHealth(value)", desc = "Define vida"},
    {name = "Teleport", pattern = {"teleport", "tp", "warp", "goto"}, argType = "any", suggestion = "Teleport(destination)", desc = "Teleporta para local"},
    {name = "GiveItem", pattern = {"give", "reward", "item", "gift"}, argType = "any", suggestion = "GiveItem(itemId, quantity)", desc = "Dá item ao jogador"},
    {name = "KickPlayer", pattern = {"kick", "ban", "remove"}, argType = "any", suggestion = "KickPlayer(playerId)", desc = "Expulsa jogador"},
    {name = "SetLevel", pattern = {"level", "rank", "rankup"}, argType = "number", suggestion = "SetLevel(value)", desc = "Define nível"},
    {name = "SpeedHack", pattern = {"speed", "walkspeed"}, argType = "number", suggestion = "SetSpeed(value)", desc = "Muda velocidade"},
    {name = "GodMode", pattern = {"god", "invincible", "immune"}, argType = "nil", suggestion = "GodMode()", desc = "Modo deus"},
    {name = "NoClip", pattern = {"noclip", "noclip"}, argType = "nil", suggestion = "NoClip()", desc = "Atravessa paredes"},
    {name = "ESP", pattern = {"esp", "hud", "visual"}, argType = "nil", suggestion = "ESP()", desc = "Mostra jogadores"}
}

-- Palavras-chave de anti-cheat
local antiCheatKeywords = {
    "kick(", "ban(", "detect", "anticheat", "anti_cheat", "anticheat",
    "sheriff", "moderator", "admincheck", "validation", "verify",
    "checkspeed", "checkfly", "checknoclip", "sanity", "report",
    "logsuspicious", "flagged", "punish", "warn(", "exploit", "injection"
}

-- ============ TAB 2: REMOTES (com highlight e análise) ============
local function scanRemotes()
    local count = 0
    importantRemotes = {}
    possibleExploits = {}
    possibleExploitsCode = {}
    
    local function isImportant(name)
        local n = name:lower()
        for _, kw in ipairs(importantKeywords) do
            if n:find(kw) then return true end
        end
        return false
    end
    
    local function findExploit(name)
        local n = name:lower()
        for _, pattern in ipairs(exploitPatterns) do
            for _, kw in ipairs(pattern.pattern) do
                if n:find(kw) then
                    return pattern
                end
            end
        end
        return nil
    end
    
    local function scan(parent, path)
        for _, obj in pairs(parent:GetChildren()) do
            pcall(function()
                local p = path .. "/" .. obj.Name
                local isImp = isImportant(obj.Name)
                local exploit = findExploit(obj.Name)
                
                if obj:IsA("RemoteEvent") then
                    count = count + 1
                    if isImp then
                        appendTab(2, "<font color='\"#FF4757\"'>🔴 [!!! IMPORTANTE !!!] RemoteEvent: " .. obj.Name .. "\n   Path: " .. p .. "\n</font>\n")
                        table.insert(importantRemotes, {name = obj.Name, path = p, type = "RemoteEvent"})
                    else
                        appendTab(2, "🔴 RemoteEvent: " .. obj.Name .. "\n   Path: " .. p .. "\n\n")
                    end
                    if exploit then
                        appendTab(2, "<font color='\"#FF6B6B\"'>   💣 POSSÍVEL EXPLOIT: " .. exploit.desc .. "\n   Sugestão: " .. exploit.suggestion .. "\n</font>\n")
                        table.insert(possibleExploits, {remote = obj.Name, path = p, exploit = exploit})
                    end
                elseif obj:IsA("RemoteFunction") then
                    count = count + 1
                    if isImp then
                        appendTab(2, "<font color='\"#FF4757\"'>🟡 [!!! IMPORTANTE !!!] RemoteFunction: " .. obj.Name .. "\n   Path: " .. p .. "\n</font>\n")
                        table.insert(importantRemotes, {name = obj.Name, path = p, type = "RemoteFunction"})
                    else
                        appendTab(2, "🟡 RemoteFunction: " .. obj.Name .. "\n   Path: " .. p .. "\n\n")
                    end
                    if exploit then
                        appendTab(2, "<font color='\"#FF6B6B\"'>   💣 POSSÍVEL EXPLOIT: " .. exploit.desc .. "\n   Sugestão: " .. exploit.suggestion .. "\n</font>\n")
                        table.insert(possibleExploits, {remote = obj.Name, path = p, exploit = exploit})
                    end
                elseif obj:IsA("UnreliableRemoteEvent") then
                    count = count + 1
                    appendTab(2, "🟠 UnreliableRemote: " .. obj.Name .. "\n   Path: " .. p .. "\n\n")
                elseif obj:IsA("BindableEvent") then
                    appendTab(2, "🟢 BindableEvent: " .. obj.Name .. "\n   Path: " .. p .. "\n\n")
                elseif obj:IsA("BindableFunction") then
                    appendTab(2, "🔵 BindableFunction: " .. obj.Name .. "\n   Path: " .. p .. "\n\n")
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

    -- Resumo de importantes
    if #importantRemotes > 0 then
        appendTab(2, "\n\n🔥━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━🔥\n")
        appendTab(2, "🔥 POSSÍVEIS REMOTES IMPORTANTES (" .. #importantRemotes .. ")\n")
        appendTab(2, "🔥━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━🔥\n\n")
        for _, r in ipairs(importantRemotes) do
            appendTab(2, "<font color='\"#FF4757\"'>[!!!] " .. r.name .. "\n   " .. r.path .. "\n   Tipo: " .. r.type .. "\n</font>\n")
        end
    end
    
    -- Resumo de exploits
    if #possibleExploits > 0 then
        appendTab(2, "\n\n💣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━💣\n")
        appendTab(2, "💣 POSSÍVEIS EXPLOITS ENCONTRADOS (" .. #possibleExploits .. ")\n")
        appendTab(2, "💣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━💣\n\n")
        for _, e in ipairs(possibleExploits) do
            appendTab(2, "<font color='\"#FF6B6B\"'>💣 Remote: " .. e.remote .. "\n   Path: " .. e.path .. "\n   Tipo: " .. e.exploit.desc .. "\n   Código: game." .. e.path:gsub("/", ".") .. ":FireServer(" .. (e.exploit.argType == "number" and "999999" or e.exploit.argType == "nil" and "" or "arg1") .. ")\n</font>\n")
        end
    end

    appendTab(2, "\n\n--- Total: " .. count .. " remotes encontrados ---\n")
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
                appendTab(4, string.format("🤖 %s | HP:%.0f/%.0f WalkSpeed:%.0f %s\n   Path: %s\n\n", char.Name, obj.Health, obj.MaxHealth, obj.WalkSpeed, posStr, char:GetFullName()))
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

-- ============ TAB 6: SCRIPTS (decompila codigo fonte) ============
local function scanScripts()
    local hasDecompile = decompile ~= nil
    if not hasDecompile then
        appendTab(6, "⚠ decompile() nao disponivel neste executor.\nListando scripts sem codigo fonte.\n\n")
    end

    local scriptCount = 0
    local function extractScript(obj, path)
        pcall(function()
            if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                scriptCount = scriptCount + 1
                local icon = obj:IsA("LocalScript") and "📜" or "📦"
                local fullPath = path .. "/" .. obj.Name
                appendTab(6, "\n" .. string.rep("=", 60) .. "\n")
                appendTab(6, icon .. " " .. obj.ClassName .. ": " .. obj.Name .. "\n")
                appendTab(6, "Path: " .. fullPath .. "\n")
                appendTab(6, string.rep("=", 60) .. "\n")

                if hasDecompile then
                    local ok, src = pcall(decompile, obj)
                    if ok and src and #src > 0 then
                        -- Limita a 3000 chars por script pra nao travar
                        if #src > 3000 then
                            appendTab(6, src:sub(1, 3000) .. "\n... [TRUNCADO - " .. #src .. " chars total]\n")
                        else
                            appendTab(6, src .. "\n")
                        end
                    else
                        appendTab(6, "-- [ERRO ao decompile ou script vazio]\n")
                    end
                else
                    appendTab(6, "-- [sem decompile disponivel]\n")
                end
            end
            for _, child in pairs(obj:GetChildren()) do
                extractScript(child, path .. "/" .. obj.Name)
            end
        end)
    end

    local services = {
        {game:GetService("ReplicatedStorage"), "ReplicatedStorage"},
        {workspace, "Workspace"},
    }
    pcall(function() table.insert(services, {game:GetService("ReplicatedFirst"), "ReplicatedFirst"}) end)
    pcall(function() table.insert(services, {game:GetService("StarterGui"), "StarterGui"}) end)
    pcall(function() table.insert(services, {game:GetService("StarterPlayer"), "StarterPlayer"}) end)
    pcall(function()
        if player.Character then table.insert(services, {player.Character, "Character"}) end
    end)
    pcall(function()
        local bp = player:FindFirstChild("Backpack")
        if bp then table.insert(services, {bp, "Backpack"}) end
    end)
    pcall(function()
        local pg = player:FindFirstChild("PlayerGui")
        if pg then table.insert(services, {pg, "PlayerGui"}) end
    end)

    for _, svc in ipairs(services) do
        appendTab(6, "\n>>> " .. svc[2] .. " <<<\n")
        for _, child in pairs(svc[1]:GetChildren()) do
            extractScript(child, svc[2])
        end
    end

    appendTab(6, "\n--- Total: " .. scriptCount .. " scripts encontrados ---\n")
end

-- ============ TAB 7: SPY REMOTES (monitora chamadas em tempo real) ============
local spyEnabled = false
local spyConnections = {}

local function startSpy()
    spyEnabled = true
    riskScore = 0 -- Reset risk score
    
    -- Ativar interceptadores de comportamento
    setupBehaviorInterceptor()
    setupPlayerMonitor()
    setupLoopDetector()
    
    appendTab(7, "\n")
    appendTab(7, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    appendTab(7, "🛡️ SISTEMA DE ANÁLISE COMPORTAMENTAL ATIVO\n")
    appendTab(7, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")
    appendTab(7, "📊 Monitorando:\n")
    appendTab(7, "  • FireServer/InvokeServer\n")
    appendTab(7, "  • Alterações de player (WalkSpeed, etc)\n")
    appendTab(7, "  • Loops suspeitos\n")
    appendTab(7, "  • Valores extremos\n")
    appendTab(7, "\n⚠️ Score de Risco atual: 0\n")
    appendTab(7, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")
    updateTab(7)
    appendTab(7, "🟢 Spy ativo - monitorando remotes...\n\n")
    updateTab(7)

    local function hookRemote(obj, path)
        pcall(function()
            if obj:IsA("RemoteEvent") then
                local oldFire = obj.FireServer
                local conn
                conn = hookmetamethod and nil or nil -- fallback
                -- Usa .OnClientEvent pra ver o que o server manda
                local c = obj.OnClientEvent:Connect(function(...)
                    if not spyEnabled then return end
                    local args = {...}
                    local argStr = ""
                    for i, v in ipairs(args) do
                        argStr = argStr .. tostring(v) .. (i < #args and ", " or "")
                    end
                    appendTab(7, string.format("🔴 [%.1f] %s\n   Args: %s\n\n", tick() % 1000, path .. "/" .. obj.Name, argStr))
                    updateTab(7)
                end)
                table.insert(spyConnections, c)
            elseif obj:IsA("RemoteFunction") then
                local c = nil
                pcall(function()
                    local oldInvoke = obj.OnClientInvoke
                    obj.OnClientInvoke = function(...)
                        if spyEnabled then
                            local args = {...}
                            local argStr = ""
                            for i, v in ipairs(args) do
                                argStr = argStr .. tostring(v) .. (i < #args and ", " or "")
                            end
                            appendTab(7, string.format("🟡 [%.1f] %s\n   Args: %s\n\n", tick() % 1000, path .. "/" .. obj.Name, argStr))
                            updateTab(7)
                        end
                        if oldInvoke then return oldInvoke(...) end
                    end
                end)
            end
        end)
    end

    local function scanForRemotes(parent, path)
        for _, obj in pairs(parent:GetChildren()) do
            pcall(function()
                hookRemote(obj, path)
                scanForRemotes(obj, path .. "/" .. obj.Name)
            end)
        end
    end

    scanForRemotes(game:GetService("ReplicatedStorage"), "ReplicatedStorage")
    scanForRemotes(workspace, "Workspace")
end

local function stopSpy()
    spyEnabled = false
    _loopDetectorRunning = false
    
    for _, c in pairs(spyConnections) do pcall(function() c:Disconnect() end) end
    spyConnections = {}
    
    appendTab(7, "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    appendTab(7, "📊 RESUMO FINAL\n")
    appendTab(7, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n")
    
    local scoreColor = "#00FF00"
    local scoreText = "🟢 SEGURO"
    if riskScore >= 30 then
        scoreColor = "#FF0000"
        scoreText = "🔴 PERIGOSO"
    elseif riskScore >= 10 then
        scoreColor = "#FFD700"
        scoreText = "🟡 SUSPEITO"
    end
    
    appendTab(7, string.format("⚠️ Score Final: <font color='\"%s\"'>%d</font> (%s)\n\n", scoreColor, riskScore, scoreText))
    
    local totalFire = 0
    local totalInvoke = 0
    for name, count in pairs(behaviorLog.remotesFired) do totalFire = totalFire + count end
    for name, count in pairs(behaviorLog.remotesInvoked) do totalInvoke = totalInvoke + count end
    
    appendTab(7, string.format("📡 FireServer: %d | 📞 InvokeServer: %d\n\n", totalFire, totalInvoke))
    
    if next(behaviorLog.remotesFired) then
        appendTab(7, "🔥 Top Remotes:\n")
        local sorted = {}
        for name, count in pairs(behaviorLog.remotesFired) do
            table.insert(sorted, {name = name, count = count})
        end
        table.sort(sorted, function(a, b) return a.count > b.count end)
        for i, entry in ipairs(sorted) do
            if i <= 5 then
                appendTab(7, string.format("   %d x %s\n", entry.count, entry.name))
            end
        end
    end
    
    appendTab(7, "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    appendTab(7, "🛡️ Monitoramento parado\n")
    appendTab(7, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
    updateTab(7)
    
    cleanupPlayerMonitor()
end



-- ============ BOTOES ============
local currentTab = 1

for i, btn in ipairs(tabBtns) do
    btn.MouseButton1Click:Connect(function() 
        currentTab = i
        switchTab(i) 
    end)
end

copyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        setclipboard(tabContents[currentTab].data)
        copyBtn.Text = "✓ Copiado!"
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(1)
        copyBtn.Text = "📋 Copiar Aba"
        copyBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 220)
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

saveBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local all = "-- Game Analyzer Export\n-- Game: " .. game.PlaceId .. "\n-- Data: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n"
        for i, name in ipairs(tabNames) do
            all = all .. "\n\n" .. string.rep("=", 60) .. "\n" .. name:upper() .. "\n" .. string.rep("=", 60) .. "\n\n" .. tabContents[i].data
        end
        local fileName = "GameAnalyzer_" .. game.PlaceId .. ".txt"
        writefile(fileName, all)
        saveBtn.Text = "✓ Salvo!"
        task.wait(1)
        saveBtn.Text = "💾 Salvar .txt"
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

-- ========== TAB 8: SCRIPT DETECTOR (detecta novos scripts executados) ==========
local scriptDetectorEnabled = true
local detectedScripts = {}
local detectorConnections = {}

task.spawn(function()
    appendTab(8, "🔍 Detector ativo - aguardando novos scripts...\n\n")
    
    -- Detecta novos LocalScript no PlayerGui/CoreGui
    local function monitorScripts(parent)
        for _, obj in pairs(parent:GetDescendants()) do
            if obj:IsA("LocalScript") then
                local found = false
                for _, known in pairs(detectedScripts) do
                    if known.Source == obj.Source and known.Name == obj.Name then found = true break end
                end
                if not found then
                    local path = obj:GetFullName()
                    local decompiled = ""
                    pcall(function()
                        decompiled = decompile(obj)
                    end)
                    table.insert(detectedScripts, {Name = obj.Name, Source = obj.Source, Path = path, Code = decompiled})
                    appendTab(8, string.format("\n🚨 NOVO SCRIPT DETECTADO!\n📜 %s\n📍 Path: %s\n\n🗳️ CÓDIGO:\n%s\n", obj.Name, path, decompiled:sub(1, 3000)))
                    updateTab(8)
                end
            end
        end
    end
    
    detectorConnections.PlayerGui = player.PlayerGui.DescendantAdded:Connect(function(obj)
        if scriptDetectorEnabled and obj:IsA("LocalScript") then monitorScripts(player.PlayerGui) end
    end)
    
    detectorConnections.CoreGui = guiParent.DescendantAdded:Connect(function(obj)
        if scriptDetectorEnabled and obj:IsA("LocalScript") then monitorScripts(guiParent) end
    end)
end)

-- Botão toggle detector
local detectorBtn = makeBottomBtn("Script Detector", 570, Color3.fromRGB(255, 100, 100))
detectorBtn.MouseButton1Click:Connect(function()
    scriptDetectorEnabled = not scriptDetectorEnabled
    detectorBtn.Text = scriptDetectorEnabled and "Detector ON" or "Detector OFF"
    detectorBtn.BackgroundColor3 = scriptDetectorEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
end)

-- Toggle Spy com tecla V
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.V then
        if spyEnabled then stopSpy() else startSpy() end
    end
end)

print("[GameAnalyzer] Carregado! Z=Mostrar/Esconder | V=Toggle Spy")
