--[[ 
    KIRIK LUXURY HUB v6.7 (PRO MOBILE EDITION)
    Added: Custom Zone Center Saving with File Persistence (JSON)
    Fixed: Inaccurate Pre-Teleports in PS99
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local IsAdmin = (LocalPlayer.UserId == 5463685844) -- Твой ID

-- Защита от дубликатов
local HubName = "KirikLuxuryHub_V6"
local targetGui = (gethui and gethui()) or CoreGui
if targetGui:FindFirstChild(HubName) then
    targetGui[HubName]:Destroy()
end

-- Основные настройки цветов
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(22, 22, 28),
    TopBar = Color3.fromRGB(18, 18, 24),
    Accent = Color3.fromRGB(0, 255, 128),
    DragMode = Color3.fromRGB(255, 170, 0),
    Text = Color3.fromRGB(240, 240, 240),
    ElementBg = Color3.fromRGB(30, 30, 38),
    ElementHover = Color3.fromRGB(40, 40, 50),
    AdminAccent = Color3.fromRGB(255, 50, 100)
}

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = HubName
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = targetGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 320)
MainFrame.AnchorPoint = Vector2.new(0.5, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true 
MainFrame.Parent = ScreenGui

local MainScale = Instance.new("UIScale")
MainScale.Scale = 1
MainScale.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- ВЕРХНЯЯ ПАНЕЛЬ
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Theme.TopBar
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 300, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KIRIK LUXURY <font color='#00ff80'>HUB</font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.Text
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- КНОПКИ ЗАКРЫТИЯ/СВОРАЧИВАНИЯ
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -75, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local isMinimized = false
local normalSize = UDim2.new(0, 500, 0, 320)
local minSize = UDim2.new(0, 500, 0, 40)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinBtn.Text = "+"
        TopBarFix.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = minSize}):Play()
    else
        MinBtn.Text = "-"
        TopBarFix.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = normalSize}):Play()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0}):Play()
    task.wait(0.2)
    ScreenGui:Destroy()
end)

-- ЛОГИКА ПЕРЕТАСКИВАНИЯ (ДВОЙНОЙ ТАП)
local dragMode = false
local lastTap = 0
local dragInput, dragStart, startPos = nil, nil, nil

MainFrame.InputBegan:Connect(function(input)
    if UserInputService:GetFocusedTextBox() then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local now = tick()
        if now - lastTap < 0.05 then return end 
        if now - lastTap <= 0.4 then
            dragMode = not dragMode
            if dragMode then
                MainStroke.Color = Theme.DragMode
                Title.Text = "KIRIK LUXURY <font color='#00ff80'>HUB</font> <font color='#ffaa00' size='12'>[DRAG MODE]</font>"
            else
                MainStroke.Color = Theme.Accent
                Title.Text = "KIRIK LUXURY <font color='#00ff80'>HUB</font>"
            end
            lastTap = 0
        else
            lastTap = now
        end
        if dragMode then
            dragInput = input
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input == dragInput then dragInput = nil end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragMode and input == dragInput then
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    end
end)

-- БОКОВАЯ ПАНЕЛЬ И КОНТЕЙНЕР
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 130, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 0
Sidebar.Active = true
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.Parent = Sidebar
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -130, 1, -40)
ContentContainer.Position = UDim2.new(0, 130, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- UI БИБЛИОТЕКА
local Tabs = {}
local Pages = {}
local CurrentTab = nil

local function CreateTab(name, isSpecial)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0.9, 0, 0, 40)
    TabBtn.BackgroundColor3 = Theme.ElementBg
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextColor3 = isSpecial and Theme.AdminAccent or Theme.Text
    TabBtn.TextSize = 14
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    
    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = isSpecial and Theme.AdminAccent or Theme.Accent
    TabStroke.Transparency = 1
    TabStroke.Parent = TabBtn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = isSpecial and Theme.AdminAccent or Theme.Accent
    Page.Visible = false
    Page.Parent = ContentContainer

    local PageLayout = Instance.new("UIListLayout")
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageLayout.Parent = Page

    local PagePadding = Instance.new("UIPadding")
    PagePadding.PaddingTop = UDim.new(0, 10)
    PagePadding.PaddingBottom = UDim.new(0, 10)
    PagePadding.Parent = Page

    Tabs[name] = TabBtn
    Pages[name] = Page

    TabBtn.MouseButton1Click:Connect(function()
        for tName, tBtn in pairs(Tabs) do
            TweenService:Create(tBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBg}):Play()
            tBtn.UIStroke.Transparency = 1
            Pages[tName].Visible = false
        end
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play()
        TabStroke.Transparency = 0
        Page.Visible = true
    end)

    if not CurrentTab then
        TabBtn.BackgroundColor3 = Theme.ElementHover
        TabStroke.Transparency = 0
        Page.Visible = true
        CurrentTab = name
    end

    return Page
end

local function CreateButton(page, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.95, 0, 0, 45)
    Btn.BackgroundColor3 = Theme.ElementBg
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextColor3 = Theme.Text
    Btn.TextSize = 14
    Btn.Parent = page
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Btn).Color = Color3.fromRGB(60, 60, 70)

    Btn.MouseButton1Down:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.9, 0, 0, 42)}):Play() end)
    Btn.MouseButton1Up:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0, 45)}):Play() end)
    Btn.MouseButton1Click:Connect(function() task.spawn(callback) end)
end

local function CreateToggle(page, text, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0.95, 0, 0, 45)
    ToggleFrame.BackgroundColor3 = Theme.ElementBg
    ToggleFrame.Parent = page
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", ToggleFrame).Color = Color3.fromRGB(60, 60, 70)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text; Label.Font = Enum.Font.GothamBold; Label.TextColor3 = Theme.Text; Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local SwitchBg = Instance.new("Frame")
    SwitchBg.Size = UDim2.new(0, 40, 0, 20)
    SwitchBg.Position = UDim2.new(1, -55, 0.5, -10)
    SwitchBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SwitchBg.Parent = ToggleFrame
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

    local SwitchKnob = Instance.new("Frame")
    SwitchKnob.Size = UDim2.new(0, 16, 0, 16)
    SwitchKnob.Position = UDim2.new(0, 2, 0.5, -8)
    SwitchKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    SwitchKnob.Parent = SwitchBg
    Instance.new("UICorner", SwitchKnob).CornerRadius = UDim.new(1, 0)

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
    ToggleBtn.BackgroundTransparency = 1
    ToggleBtn.Text = ""
    ToggleBtn.Parent = ToggleFrame

    local state = false
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        local knobPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local bgColor = state and Theme.Accent or Color3.fromRGB(50, 50, 50)
        TweenService:Create(SwitchKnob, TweenInfo.new(0.2), {Position = knobPos}):Play()
        TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = bgColor}):Play()
        task.spawn(function() callback(state) end)
    end)
end

local function CreateTextBox(page, text, callback)
    local TextBoxFrame = Instance.new("Frame")
    TextBoxFrame.Size = UDim2.new(0.95, 0, 0, 45)
    TextBoxFrame.BackgroundColor3 = Theme.ElementBg
    TextBoxFrame.Parent = page
    Instance.new("UICorner", TextBoxFrame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", TextBoxFrame).Color = Color3.fromRGB(60, 60, 70)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text; Label.Font = Enum.Font.GothamBold; Label.TextColor3 = Theme.Text; Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TextBoxFrame

    local TextBoxBg = Instance.new("Frame")
    TextBoxBg.Size = UDim2.new(0.4, 0, 0.7, 0)
    TextBoxBg.Position = UDim2.new(0.98, 0, 0.15, 0)
    TextBoxBg.AnchorPoint = Vector2.new(1, 0)
    TextBoxBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    TextBoxBg.Parent = TextBoxFrame
    Instance.new("UICorner", TextBoxBg).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", TextBoxBg).Color = Color3.fromRGB(60, 60, 70)

    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, 0, 1, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Text = ""; TextBox.PlaceholderText = "..."
    TextBox.Font = Enum.Font.GothamBold; TextBox.TextColor3 = Theme.Text; TextBox.TextSize = 14
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = TextBoxBg

    TextBox.FocusLost:Connect(function() callback(TextBox.Text) end)
end

-- ========================================= --
-- ADMIN DEBUG SYSTEM
-- ========================================= --
local DebugPage = nil
if IsAdmin then DebugPage = CreateTab("Debug [ADMIN]", true) end

local function KLog(msg)
    print("[KIRIK HUB]: " .. tostring(msg))
    if IsAdmin and DebugPage then
        local logMsg = Instance.new("TextLabel")
        logMsg.Size = UDim2.new(0.95, 0, 0, 25)
        logMsg.BackgroundTransparency = 1
        logMsg.Text = "» " .. tostring(msg); logMsg.Font = Enum.Font.Code; logMsg.TextColor3 = Color3.fromRGB(200, 200, 200)
        logMsg.TextSize = 12; logMsg.TextWrapped = true; logMsg.TextXAlignment = Enum.TextXAlignment.Left
        logMsg.Parent = DebugPage
        DebugPage.CanvasPosition = Vector2.new(0, 999999)
    end
end

if IsAdmin then KLog("Welcome to Admin Mode, Creator!") end

--=========================================--
--           ФУНКЦИОНАЛ ХАБА               --
--=========================================--

local UniversalPage = CreateTab("Universal", false)
local PS99Page = CreateTab("PS99", false)
local MM2Page = CreateTab("MM2", false)
local SettingsPage = CreateTab("Settings", false)

-- ===================================
-- UNIVERSAL FUNCTIONS
-- ===================================
local FlySpeed = 50
local FlyLoop, NoclipLoop, ESP_Loop

local function ToggleFly(state)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if FlyLoop then FlyLoop:Disconnect() FlyLoop = nil end
    if hrp then for _, v in pairs(hrp:GetChildren()) do if v.Name == "KirikFly" then v:Destroy() end end end
    if state and char and hrp then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "KirikFly"; bv.MaxForce = Vector3.new(10^6, 10^6, 10^6); bv.Velocity = Vector3.zero; bv.Parent = hrp
        FlyLoop = RunService.Heartbeat:Connect(function()
            local cam = workspace.CurrentCamera
            local PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
            local moveVector = PlayerModule:GetControls():GetMoveVector()
            if moveVector.Magnitude > 0 then
                bv.Velocity = ((cam.CFrame.LookVector * -moveVector.Z) + (cam.CFrame.RightVector * moveVector.X)) * FlySpeed
            else
                bv.Velocity = Vector3.zero
            end
        end)
    end
end

local function ToggleNoclip(state)
    if NoclipLoop then NoclipLoop:Disconnect() NoclipLoop = nil end
    if state then
        NoclipLoop = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end)
    end
end

local function ToggleESP(state)
    if ESP_Loop then ESP_Loop:Disconnect() ESP_Loop = nil end
    if state then
        ESP_Loop = RunService.Heartbeat:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if not p.Character:FindFirstChild("KirikESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "KirikESP"; hl.FillColor = Theme.Accent; hl.OutlineColor = Color3.new(1, 1, 1); hl.FillTransparency = 0.5; hl.Parent = p.Character
                    end
                end
            end
        end)
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("KirikESP") then p.Character.KirikESP:Destroy() end
        end
    end
end

CreateToggle(UniversalPage, "Mobile Fly", ToggleFly)
CreateButton(UniversalPage, "Fly Speed: 50 (Default)", function() FlySpeed = 50 end)
CreateButton(UniversalPage, "Fly Speed: 100 (Fast)", function() FlySpeed = 100 end)
CreateToggle(UniversalPage, "Noclip", ToggleNoclip)
CreateToggle(UniversalPage, "Player ESP", ToggleESP)

-- ===================================
-- PET SIMULATOR 99 (CUSTOM ZONES SYSTEM)
-- ===================================
local TargetPS99Zone = 1
local SavedZonesFile = "KirikHub_PS99_Zones.json"
local SavedZones = {}

-- Загрузка сохраненных зон из файла (если поддерживается экзекутором)
local function LoadZones()
    pcall(function()
        if isfile and isfile(SavedZonesFile) and readfile then
            local data = readfile(SavedZonesFile)
            local decoded = HttpService:JSONDecode(data)
            if type(decoded) == "table" then
                SavedZones = decoded
                KLog("Successfully loaded saved zones from device.")
            end
        end
    end)
end
LoadZones()

CreateTextBox(PS99Page, "Set Target Zone (ex: 33)", function(text)
    local num = tonumber(text:match("%d+"))
    if num then
        TargetPS99Zone = num
        KLog("Target Zone changed to: " .. tostring(TargetPS99Zone))
    else
        KLog("Invalid Zone Number!")
    end
end)

-- КНОПКА СОХРАНЕНИЯ ЦЕНТРА ЗОНЫ
CreateButton(PS99Page, "Save Current Pos as Zone Center", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return KLog("Error: Character not found") end

    local pos = hrp.Position
    SavedZones[tostring(TargetPS99Zone)] = {X = pos.X, Y = pos.Y, Z = pos.Z}
    
    -- Пытаемся сохранить в файл
    pcall(function()
        if writefile then
            local json = HttpService:JSONEncode(SavedZones)
            writefile(SavedZonesFile, json)
            KLog("File written successfully.")
        end
    end)
    
    KLog("SAVED! Zone " .. TargetPS99Zone .. " center set to your current position.")
end)

CreateButton(PS99Page, "TP to Best Drop in Zone", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return KLog("Error: No Character found.") end

    KLog("Initiating TP to Zone: " .. tostring(TargetPS99Zone))

    -- 1. Определяем, куда сначала прыгать для прогрузки (Pre-Teleport)
    local preTpPos = nil
    local savedData = SavedZones[tostring(TargetPS99Zone)]

    if savedData then
        -- Если игрок сохранил центр вручную (Идеальный вариант)
        preTpPos = Vector3.new(savedData.X, savedData.Y, savedData.Z)
        KLog("Using Custom Saved Center for Zone " .. TargetPS99Zone)
    else
        -- Если не сохранил, ищем как раньше (может быть криво)
        KLog("Warning: No custom center saved. Auto-detecting... (Might be inaccurate)")
        local mapFolder = workspace:FindFirstChild("Map")
        if mapFolder then
            for _, folder in pairs(mapFolder:GetChildren()) do
                local num = tonumber(folder.Name:match("^%d+"))
                if num == TargetPS99Zone then
                    local part = folder:FindFirstChildWhichIsA("BasePart", true)
                    if part then preTpPos = part.Position end
                    break
                end
            end
        end
    end

    if not preTpPos then
        return KLog("Error: Couldn't find or generate a center for Zone " .. TargetPS99Zone)
    end

    -- Прыгаем в центр и ждем прогрузки
    hrp.CFrame = CFrame.new(preTpPos + Vector3.new(0, 10, 0))
    task.wait(1.5)

    -- 2. Ищем самый ФИЗИЧЕСКИ БОЛЬШОЙ объект вокруг (радиус 300 студов от центра)
    local things = workspace:FindFirstChild("__THINGS")
    local breakables = things and things:FindFirstChild("Breakables")
    if not breakables then return KLog("Error: Breakables folder not found!") end

    KLog("Scanning for the biggest object...")
    local bestTarget = nil
    local maxVolume = -1

    for _, b in pairs(breakables:GetChildren()) do
        local pivot = b:GetPivot()
        local dist = (pivot.Position - hrp.Position).Magnitude
        
        -- Сканируем только те объекты, которые находятся рядом (в прогруженной зоне)
        if dist < 300 then 
            local volume = 0
            if b:IsA("Model") then
                local size = b:GetExtentsSize()
                volume = size.X * size.Y * size.Z
            elseif b:IsA("BasePart") then
                volume = b.Size.X * b.Size.Y * b.Size.Z
            end

            if volume > maxVolume then
                maxVolume = volume
                bestTarget = b
            end
        end
    end

    -- 3. Телепорт на сам сундук!
    if bestTarget then
        KLog("Success! Found Massive Drop! (Volume: " .. math.floor(maxVolume) .. ")")
        hrp.CFrame = CFrame.new(bestTarget:GetPivot().Position + Vector3.new(0, 8, 0))
    else
        KLog("Error: Objects loaded, but nothing was found in range. Is the zone empty?")
    end
end)

-- ===================================
-- MURDER MYSTERY 2
-- ===================================
CreateButton(MM2Page, "TP to Map (MM2)", function()
    local mapFolder = workspace:FindFirstChild("Normal")
    if mapFolder then
        local map = mapFolder:FindFirstChildWhichIsA("Model")
        if map and map:FindFirstChild("Spawns") then
            local spawns = map.Spawns:GetChildren()
            if #spawns > 0 then
                local randomSpawn = spawns[math.random(1, #spawns)]
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = randomSpawn.CFrame + Vector3.new(0, 5, 0)
                end
            end
        end
    end
end)

CreateButton(MM2Page, "TP to Lobby (MM2)", function()
    local char = LocalPlayer.Character
    local lobbySpawn = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Spawns")
    if char and char:FindFirstChild("HumanoidRootPart") and lobbySpawn then
        local spawns = lobbySpawn:GetChildren()
        if #spawns > 0 then char.HumanoidRootPart.CFrame = spawns[math.random(1, #spawns)].CFrame + Vector3.new(0, 3, 0) end
    end
end)

-- ===================================
-- SETTINGS
-- ===================================
CreateTextBox(SettingsPage, "Custom Size (ex. 75, 1.2, 150%)", function(text)
    local num = text:match("[%d%.]+")
    if num then
        local scale = tonumber(num)
        if scale then
            if scale >= 10 then scale = scale / 100 end
            scale = math.clamp(scale, 0.4, 2.5) 
            TweenService:Create(MainScale, TweenInfo.new(0.2), {Scale = scale}):Play()
            KLog("UI Size changed to: " .. scale)
        end
    end
end)

CreateButton(SettingsPage, "Reset Size (100%)", function()
    TweenService:Create(MainScale, TweenInfo.new(0.2), {Scale = 1.0}):Play()
end)

KLog("Hub Loaded Successfully! Version 6.7")
