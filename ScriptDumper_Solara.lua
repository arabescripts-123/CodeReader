-- ScriptCopier.lua - Copia códigos de scripts rodando + Monitor Runtime
-- Extrai fonte (decompile) + Espiona ações (hooks em remotes, Instance.new, print)
print("[ScriptCopier] Carregando... Pressione Z para toggle")

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local guiParent = gethui and gethui() or game.CoreGui
pcall(function() local existing = guiParent:FindFirstChild("ScriptCopierGui"); if existing then existing:Destroy() end end)

-- ========== HOOKS GLOBAIS ==========
local oldPrint, oldWarn, oldInstanceNew = print, warn, Instance.new
local spyLogs = {}
local hookCount = 0

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index

-- RemoteSpy principal (hook __namecall)
if hookmetamethod then
    local oldHook = hookmetamethod
    hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method == "FireServer" or method == "InvokeServer" then
            local path = self:GetFullName()
            local argStr = table.concat(args, ", ", 2) or ""
            table.insert(spyLogs, 1, string.format("[%.2f] %s:%s(%s)", tick()%60, path, method, argStr))
            hookCount = hookCount + 1
            if #spyLogs > 50 then table.remove(spyLogs) end
        end
        return oldHook(self, ...)
    end)
end

-- Instance.new spy
Instance.new = function(class, parent)
    hookCount = hookCount + 1
    table.insert(spyLogs, 1, string.format("[%.2f] Instance.new(&#39;%s&#39;, %s)", tick()%60, class, parent and parent.Name or "nil"))
    if #spyLogs > 50 then table.remove(spyLogs) end
    return oldInstanceNew(class, parent)
end

-- Print/Warn spy
print = function(...)
    local args = {...}
    table.insert(spyLogs, 1, "[PRINT] " .. table.concat(args, " "))
    return oldPrint(...)
end
warn = function(...)
    local args = {...}
    table.insert(spyLogs, 1, "[WARN] " .. table.concat(args, " "))
    return oldWarn(...)
end

-- ========== GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptCopierGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = guiParent

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 800, 0, 500)
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke"); stroke.Parent = MainFrame; stroke.Color = Color3.fromRGB(100, 100, 200); stroke.Thickness = 2

-- Title/Drag
local TitleBar = Instance.new("Frame"); TitleBar.Parent = MainFrame; TitleBar.Size = UDim2.new(1, 0, 0, 40); TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
local Title = Instance.new("TextLabel"); Title.Parent = TitleBar; Title.Size = UDim2.new(1, 0, 1, 0); Title.BackgroundTransparency = 1; Title.Text = "📋 ScriptCopier - Hooks Ativos: 0"; Title.TextColor3 = Color3.fromRGB(200, 200, 255); Title.TextSize = 16; Title.Font = Enum.Font.GothamBold

-- Dragging code (simplificado)
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UIS.InputChanged:Connect(function(input) if input == dragInput and dragging then local delta = input.Position - dragStart MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

-- Tabs
local tabs = {{"Dump Source", ""}, {"Remotes", ""}, {"Live Spy", table.concat(spyLogs, &#39;\\n&#39;)}}
local tabBtns, tabScrolls, tabTexts = {}, {}, {}
for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton"); btn.Parent = MainFrame; btn.Position = UDim2.new(0, 10+(i-1)*150, 0, 45); btn.Size = UDim2.new(0, 140, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70); btn.Text = tab[1]; btn.TextColor3 = Color3.fromRGB(200, 200, 255); btn.Font = Enum.Font.Gotham; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6); tabBtns[i] = btn
    
    local scroll = Instance.new("ScrollingFrame"); scroll.Parent = MainFrame; scroll.Position = UDim2.new(0, 10, 0, 80); scroll.Size = UDim2.new(1, -20, 1, -120); scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 30); scroll.CanvasSize = UDim2.new(0,0,0,0); scroll.ScrollBarThickness = 8; scroll.BorderSizePixel = 0; scroll.Visible = (i==1); Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6); tabScrolls[i] = scroll
    
    local txt = Instance.new("TextLabel"); txt.Parent = scroll; txt.BackgroundTransparency = 1; txt.Position = UDim2.new(0,10,0,5); txt.Size = UDim2.new(1,-20,1,0); txt.Font = Enum.Font.Code; txt.TextColor3 = Color3.fromRGB(220, 220, 255); txt.TextSize = 13; txt.TextXAlignment = Enum.TextXAlignment.Left; txt.TextYAlignment = Enum.TextYAlignment.Top; txt.TextWrapped = true; txt.AutomaticSize = Enum.AutomaticSize.Y; txt.RichText = true; tabTexts[i] = txt; tabs[i] = txt
end

local currentTab = 1
local function switchTab(i)
    for j, btn in ipairs(tabBtns) do btn.BackgroundColor3 = (j==i) and Color3.fromRGB(80, 80, 150) or Color3.fromRGB(50, 50, 70); tabScrolls[j].Visible = (j==i) end
    currentTab = i
end
for i, btn in ipairs(tabBtns) do btn.MouseButton1Click:Connect(function() switchTab(i) end) end

-- Buttons
local btnY = 1.02
local function btn(text, posX, cb)
    local b = Instance.new("TextButton"); b.Parent = MainFrame; b.Position = UDim2.new(0, posX, 1, -40); b.Size = UDim2.new(0, 100, 0, 32); b.BackgroundColor3 = Color3.fromRGB(60, 60, 120); b.Text = text; b.TextColor3 = Color3.fromRGB(255,255,255); b.Font = Enum.Font.GothamBold; b.TextSize = 12; Instance.new("UICorner", b).CornerRadius = UDim.new(0,6); b.MouseButton1Click:Connect(cb)
end
btn("Copiar", 10, function() setclipboard(tabTexts[currentTab].Text) end)
btn("Copiar Tudo", 120, function() 
    local all = "" 
    for i, t in ipairs(tabTexts) do all = all .. tabs[i+1][1] .. ":\\n" .. t.Text .. "\\n===\\n" end 
    setclipboard(all) 
end)
btn("Salvar", 240, function() writefile("ScriptCopier_Logs.txt", table.concat(spyLogs, &#39;\\n&#39;)) end)
btn("Rejoin", 700, function() game:GetService("TeleportService"):Teleport(game.PlaceId, player) end)

-- ========== DUMP SOURCE (Tab1) ==========
local hasDecompile = (function() local s = Instance.new("LocalScript"); local ok, _ = pcall(decompile, s); s:Destroy(); return ok end)()
local dumpData = {}
local function scanDump(obj, path, depth)
    if depth > 5 then return end
    local icon = obj:IsA("LocalScript") and "📜" or obj:IsA("ModuleScript") and "📦" or obj:IsA("Script") and "⚙️" or ""
    if icon ~= "" then
        table.insert(dumpData, path .. ": " .. icon .. obj.Name)
        if hasDecompile then
            local ok, src = pcall(decompile, obj)
            if ok and src and #src > 0 then table.insert(dumpData, "-- SOURCE: --" .. src:sub(1, 2000)) end
        end
    end
    for _, child in obj:GetChildren() do pcall(function() scanDump(child, path.."/"..obj.Name, depth+1) end) end
end

task.spawn(function()
    local services = {workspace, RS, game:GetService("ReplicatedFirst"), game:GetService("StarterGui")}
    for _, svc in ipairs(services) do
        for _, child in svc:GetChildren() do scanDump(child, svc.Name, 0) end
    end
    tabTexts[1].Text = table.concat(dumpData, "\\n")
    tabScrolls[1].CanvasSize = UDim2.new(0,0,0, tabTexts[1].AbsoluteSize.Y)
end)

-- ========== REMOTES (Tab2) ==========
task.spawn(function()
    local remotes = {}
    local function findRemotes(parent)
        for _, obj in parent:GetChildren() do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then table.insert(remotes, obj:GetFullName()) end
            findRemotes(obj)
        end
    end
    findRemotes(RS); findRemotes(workspace)
    tabTexts[2].Text = "Remotes encontrados:\\n" .. table.concat(remotes, "\\n")
    tabScrolls[2].CanvasSize = UDim2.new(0,0,0, tabTexts[2].AbsoluteSize.Y)
end)

-- ========== LIVE SPY (Tab3) - Update logs ==========
RunService.Heartbeat:Connect(function()
    Title.Text = string.format("📋 ScriptCopier - Hooks: %d | Logs: %d", hookCount, #spyLogs)
    if tabScrolls[3].Visible then
        tabTexts[3].Text = table.concat(spyLogs, "\\n")
        tabScrolls[3].CanvasSize = UDim2.new(0,0,0, tabTexts[3].AbsoluteSize.Y + 20)
    end
end)

-- Toggle Z
UIS.InputBegan:Connect(function(input) if not input.UserInputType == Enum.UserInputType.Keyboard then return end; if input.KeyCode == Enum.KeyCode.Z then MainFrame.Visible = not MainFrame.Visible end end)

print("[ScriptCopier] ✅ Ativo! Copia códigos + espiona scripts rodando.")
-- FIM DO SCRIPT
