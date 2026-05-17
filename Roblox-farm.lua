--[[ 
    KIRIK LUXURY HUB v6.4 (PRO MOBILE EDITION)
    Added: Exclusive Admin Debug Console, 2-Step Streaming Bypass for PS99
    Fixed: Teleporting to unloaded zones in Pet Simulator 99
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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
    AdminAccent = Color3.fromRGB(255, 50, 100) -- Цвет админ-панели
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

-- КНОПКИ ЗАКРЫТИЯ И СВОРАЧИВАНИЯ
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
-- ADMIN DEBUG SYSTEM (Только для тебя)
-- ========================================= --
local DebugPage = nil
if IsAdmin then
    DebugPage = CreateTab("Debug [ADMIN]", true)
end

local function KLog(msg)
    print("[KIRIK HUB]: " .. tostring(msg))
    if IsAdmin and DebugPage then
        local logMsg = Instance.new("TextLabel")
        logMsg.Size = UDim2.new(0.95, 0, 0, 25)
        logMsg.BackgroundTransparency = 1
        logMsg.Text = "» " .. tostring(msg)
        logMsg.Font = Enum.Font.Code
        logMsg.TextColor3 = Color3.fromRGB(200, 200, 200)
        logMsg.TextSize = 12
        logMsg.TextWrapped = true
        logMsg.TextXAlignment = Enum.TextXAlignment.Left
        logMsg.Parent = DebugPage
        -- Автоскролл вниз
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

-- НАПОЛНЕНИЕ: PET SIMULATOR 99 (SMART TP v2 + STREAMING BYPASS)
CreateButton(PS99Page, "TP to Best Drop (Max Zone)", function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return KLog("Error: No character/HumanoidRootPart") end

    KLog("Starting Smart TP...")

    -- 1. Ищем максимальную открытую зону
    local maxZone = 0
    local success, err = pcall(function()
        local lib = require(game:GetService("ReplicatedStorage"):WaitForChild("Library"):WaitForChild("Client"))
        local save = lib.Save.Get()
        for z, unlocked in pairs(save.UnlockedZones or {}) do
            if unlocked then
                local num = tonumber(tostring(z):match("%d+"))
                if num and num > maxZone then maxZone = num end
            end
        end
    end)

    if success then
        KLog("Max Zone Unlocked: " .. tostring(maxZone))
    else
        KLog("Failed to read Library. Error: " .. tostring(err))
    end

    -- 2. Обходим StreamingEnabled - Телепортируемся сначала к карте зоны
    if maxZone > 0 then
        local mapFolder = workspace:FindFirstChild("Map")
        if mapFolder then
            KLog("Searching for Zone " .. maxZone .. " in Map...")
            for _, folder in pairs(mapFolder:GetChildren()) do
                local folderNum = tonumber(folder.Name:match("^%d+"))
                if folderNum == maxZone then
                    local targetPart = folder:FindFirstChildWhichIsA("BasePart", true)
                    if targetPart then
                        KLog("Found map segment. Pre-teleporting to load breakables...")
                        hrp.CFrame = targetPart.CFrame + Vector3.new(0, 15, 0)
                        
                        -- ЖДЕМ ЗАГРУЗКИ ОБЪЕКТОВ (0.6 секунд)
                        task.wait(0.6) 
                        break
                    end
                end
            end
        else
            KLog("Warning: workspace.Map not found.")
        end
    end

    -- 3. Теперь ищем самую ЖИРНУЮ цель (Среди всех загруженных зон)
    local things = workspace:FindFirstChild("__THINGS")
    local breakables = things and things:FindFirstChild("Breakables")
    if not breakables then return KLog("Error: Breakables folder not found!") end

    local bestTarget = nil
    local maxHp = -1

    for _, b in pairs(breakables:GetChildren()) do
        -- В PS99 ХП монеток записано в атрибутах. У сундуков/сейфов их больше всего.
        local hp = tonumber(b:GetAttribute("MaxHealth") or b:GetAttribute("Health") or 0)
        if hp > maxHp then
            maxHp = hp
            bestTarget = b
        end
    end

    -- 4. Телепорт на цель
    if bestTarget then
        KLog("Success! Found biggest drop. MaxHealth: " .. tostring(maxHp))
        local pivot = bestTarget:GetPivot()
        hrp.CFrame = CFrame.new(pivot.Position + Vector3.new(0, 8, 0))
    else
        KLog("Error: No breakables loaded. Are you in a completely empty area?")
    end
end)

-- НАПОЛНЕНИЕ: НАСТРОЙКИ (МАСШТАБ ХАБА)
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

KLog("Hub Loaded Successfully!")
