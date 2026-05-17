--[[ 
    KIRIK LUXURY HUB v8.0 (ULTIMATE MOBILE EDITION)
    Added: Anti-AFK, Stats/Currency Tracker HUD (DPS Meter), Time Window Selector
    Maintains: Smart TP, Base64 Configs, Mobile-Friendly UI
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local IsAdmin = (LocalPlayer.UserId == 5463685844) -- Твой ID

-- Защита от дубликатов
local HubName = "KirikLuxuryHub_V8"
local targetGui = (gethui and gethui()) or CoreGui
if targetGui:FindFirstChild(HubName) then
    targetGui[HubName]:Destroy()
end

-- ========================================= --
-- ГЛОБАЛЬНЫЙ КОНФИГ
-- ========================================= --
local Config = {
    TargetPS99Zone = 1,
    FlySpeed = 50,
    UIScale = 1.0,
    SavedZones = {},
    TrackedStat = "Diamonds",
    TrackTime = 60
}

-- БИБЛИОТЕКА BASE64
local Base64 = {}
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function Base64.Encode(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
function Base64.Decode(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
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

-- ========================================= --
-- СОЗДАНИЕ ГЛАВНОГО GUI
-- ========================================= --
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
MainScale.Scale = Config.UIScale
MainScale.Parent = MainFrame

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.Accent; MainStroke.Thickness = 1.5

-- ВЕРХНЯЯ ПАНЕЛЬ
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40); TopBar.BackgroundColor3 = Theme.TopBar; TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)
local TopBarFix = Instance.new("Frame", TopBar)
TopBarFix.Size = UDim2.new(1, 0, 0, 10); TopBarFix.Position = UDim2.new(0, 0, 1, -10); TopBarFix.BackgroundColor3 = Theme.TopBar; TopBarFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0, 300, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0); Title.BackgroundTransparency = 1
Title.Text = "KIRIK LUXURY <font color='#00ff80'>HUB</font>"
Title.RichText = true; Title.Font = Enum.Font.GothamBold; Title.TextColor3 = Theme.Text; Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left

-- КНОПКИ ЗАКРЫТИЯ/СВОРАЧИВАНИЯ
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -40, 0.5, -15); CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.Text = "X"; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -75, 0.5, -15); MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
MinBtn.Text = "-"; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255); MinBtn.TextSize = 18
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local isMinimized = false
local normalSize = UDim2.new(0, 500, 0, 320)
local minSize = UDim2.new(0, 500, 0, 40)

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinBtn.Text = "+"; TopBarFix.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = minSize}):Play()
    else
        MinBtn.Text = "-"; TopBarFix.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = normalSize}):Play()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0}):Play()
    task.wait(0.2); ScreenGui:Destroy()
end)

-- ЛОГИКА ПЕРЕТАСКИВАНИЯ ХАБА (ДВОЙНОЙ ТАП)
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
                MainStroke.Color = Theme.DragMode; Title.Text = "KIRIK LUXURY <font color='#00ff80'>HUB</font> <font color='#ffaa00' size='12'>[DRAG MODE]</font>"
            else
                MainStroke.Color = Theme.Accent; Title.Text = "KIRIK LUXURY <font color='#00ff80'>HUB</font>"
            end
            lastTap = 0
        else
            lastTap = now
        end
        if dragMode then
            dragInput = input; dragStart = input.Position; startPos = MainFrame.Position
        end
    end
end)
MainFrame.InputEnded:Connect(function(input) if input == dragInput then dragInput = nil end end)
UserInputService.InputChanged:Connect(function(input)
    if dragMode and input == dragInput then
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    end
end)

-- БОКОВАЯ ПАНЕЛЬ И КОНТЕЙНЕР
local Sidebar = Instance.new("ScrollingFrame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, -40); Sidebar.Position = UDim2.new(0, 0, 0, 40); Sidebar.BackgroundColor3 = Theme.Sidebar; Sidebar.BorderSizePixel = 0; Sidebar.ScrollBarThickness = 0; Sidebar.Active = true
Instance.new("UIListLayout", Sidebar).SortOrder = Enum.SortOrder.LayoutOrder
Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -130, 1, -40); ContentContainer.Position = UDim2.new(0, 130, 0, 40); ContentContainer.BackgroundTransparency = 1

-- UI БИБЛИОТЕКА
local Tabs, Pages, CurrentTab = {}, {}, nil

local function CreateTab(name, isSpecial)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 40); TabBtn.BackgroundColor3 = Theme.ElementBg; TabBtn.Text = name; TabBtn.Font = Enum.Font.GothamBold; TabBtn.TextSize = 14; TabBtn.TextColor3 = isSpecial and Theme.AdminAccent or Theme.Text
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    local TabStroke = Instance.new("UIStroke", TabBtn); TabStroke.Color = isSpecial and Theme.AdminAccent or Theme.Accent; TabStroke.Transparency = 1

    local Page = Instance.new("ScrollingFrame", ContentContainer)
    Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 3; Page.Visible = false; Page.ScrollBarImageColor3 = isSpecial and Theme.AdminAccent or Theme.Accent
    local PageLayout = Instance.new("UIListLayout", Page); PageLayout.SortOrder = Enum.SortOrder.LayoutOrder; PageLayout.Padding = UDim.new(0, 8); PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local PagePadding = Instance.new("UIPadding", Page); PagePadding.PaddingTop = UDim.new(0, 10); PagePadding.PaddingBottom = UDim.new(0, 10)

    Tabs[name] = TabBtn; Pages[name] = Page

    TabBtn.MouseButton1Click:Connect(function()
        for tName, tBtn in pairs(Tabs) do TweenService:Create(tBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBg}):Play(); tBtn.UIStroke.Transparency = 1; Pages[tName].Visible = false end
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play(); TabStroke.Transparency = 0; Page.Visible = true
    end)
    if not CurrentTab then TabBtn.BackgroundColor3 = Theme.ElementHover; TabStroke.Transparency = 0; Page.Visible = true; CurrentTab = name end
    return Page
end

local function CreateButton(page, text, callback)
    local Btn = Instance.new("TextButton", page)
    Btn.Size = UDim2.new(0.95, 0, 0, 45); Btn.BackgroundColor3 = Theme.ElementBg; Btn.Text = text; Btn.Font = Enum.Font.GothamBold; Btn.TextColor3 = Theme.Text; Btn.TextSize = 14
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", Btn).Color = Color3.fromRGB(60, 60, 70)
    Btn.MouseButton1Down:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.9, 0, 0, 42)}):Play() end)
    Btn.MouseButton1Up:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0, 45)}):Play() end)
    Btn.MouseButton1Click:Connect(function() task.spawn(callback) end)
end

local function CreateToggle(page, text, callback)
    local ToggleFrame = Instance.new("Frame", page)
    ToggleFrame.Size = UDim2.new(0.95, 0, 0, 45); ToggleFrame.BackgroundColor3 = Theme.ElementBg
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", ToggleFrame).Color = Color3.fromRGB(60, 60, 70)

    local Label = Instance.new("TextLabel", ToggleFrame)
    Label.Size = UDim2.new(0.7, 0, 1, 0); Label.Position = UDim2.new(0, 15, 0, 0); Label.BackgroundTransparency = 1; Label.Text = text; Label.Font = Enum.Font.GothamBold; Label.TextColor3 = Theme.Text; Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left

    local SwitchBg = Instance.new("Frame", ToggleFrame)
    SwitchBg.Size = UDim2.new(0, 40, 0, 20); SwitchBg.Position = UDim2.new(1, -55, 0.5, -10); SwitchBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
    local SwitchKnob = Instance.new("Frame", SwitchBg)
    SwitchKnob.Size = UDim2.new(0, 16, 0, 16); SwitchKnob.Position = UDim2.new(0, 2, 0.5, -8); SwitchKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200); Instance.new("UICorner", SwitchKnob).CornerRadius = UDim.new(1, 0)

    local ToggleBtn = Instance.new("TextButton", ToggleFrame)
    ToggleBtn.Size = UDim2.new(1, 0, 1, 0); ToggleBtn.BackgroundTransparency = 1; ToggleBtn.Text = ""

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

local function CreateTextBox(page, text, placeholder, callback)
    local TextBoxFrame = Instance.new("Frame", page)
    TextBoxFrame.Size = UDim2.new(0.95, 0, 0, 45); TextBoxFrame.BackgroundColor3 = Theme.ElementBg
    Instance.new("UICorner", TextBoxFrame).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", TextBoxFrame).Color = Color3.fromRGB(60, 60, 70)

    local Label = Instance.new("TextLabel", TextBoxFrame)
    Label.Size = UDim2.new(0.5, 0, 1, 0); Label.Position = UDim2.new(0, 15, 0, 0); Label.BackgroundTransparency = 1; Label.Text = text; Label.Font = Enum.Font.GothamBold; Label.TextColor3 = Theme.Text; Label.TextSize = 14; Label.TextXAlignment = Enum.TextXAlignment.Left

    local TextBoxBg = Instance.new("Frame", TextBoxFrame)
    TextBoxBg.Size = UDim2.new(0.4, 0, 0.7, 0); TextBoxBg.Position = UDim2.new(0.98, 0, 0.15, 0); TextBoxBg.AnchorPoint = Vector2.new(1, 0); TextBoxBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Instance.new("UICorner", TextBoxBg).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", TextBoxBg).Color = Color3.fromRGB(60, 60, 70)

    local TextBox = Instance.new("TextBox", TextBoxBg)
    TextBox.Size = UDim2.new(1, 0, 1, 0); TextBox.BackgroundTransparency = 1; TextBox.Text = ""; TextBox.PlaceholderText = placeholder or "..."
    TextBox.Font = Enum.Font.GothamBold; TextBox.TextColor3 = Theme.Text; TextBox.TextSize = 14; TextBox.ClearTextOnFocus = false

    TextBox.FocusLost:Connect(function() callback(TextBox.Text) end)
    return TextBox 
end

-- ========================================= --
-- ADMIN DEBUG SYSTEM
-- ========================================= --
local DebugPage = nil
if IsAdmin then DebugPage = CreateTab("Debug [ADMIN]", true) end
local function KLog(msg)
    print("[KIRIK HUB]: " .. tostring(msg))
    if IsAdmin and DebugPage then
        local logMsg = Instance.new("TextLabel", DebugPage)
        logMsg.Size = UDim2.new(0.95, 0, 0, 25); logMsg.BackgroundTransparency = 1; logMsg.Text = "» " .. tostring(msg); logMsg.Font = Enum.Font.Code; logMsg.TextColor3 = Color3.fromRGB(200, 200, 200); logMsg.TextSize = 12; logMsg.TextWrapped = true; logMsg.TextXAlignment = Enum.TextXAlignment.Left
        DebugPage.CanvasPosition = Vector2.new(0, 999999)
    end
end
if IsAdmin then KLog("Welcome to Admin Mode, Creator!") end

--=========================================--
--           СТРАНИЦЫ И ФУНКЦИОНАЛ         --
--=========================================--
local UniversalPage = CreateTab("Universal", false)
local TrackerPage = CreateTab("Stats Tracker", false)
local PS99Page = CreateTab("PS99", false)
local MM2Page = CreateTab("MM2", false)
local SettingsPage = CreateTab("Settings", false)

-- ===================================
-- UNIVERSAL FUNCTIONS (ANTI-AFK)
-- ===================================
local FlyLoop, NoclipLoop, ESP_Loop, AntiAfkConnection

CreateToggle(UniversalPage, "Anti-AFK", function(state)
    if state then
        AntiAfkConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            KLog("Anti-AFK active: prevented kick.")
        end)
        KLog("Anti-AFK Enabled")
    else
        if AntiAfkConnection then AntiAfkConnection:Disconnect(); AntiAfkConnection = nil end
        KLog("Anti-AFK Disabled")
    end
end)

local function ToggleFly(state)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if FlyLoop then FlyLoop:Disconnect() FlyLoop = nil end
    if hrp then for _, v in pairs(hrp:GetChildren()) do if v.Name == "KirikFly" then v:Destroy() end end end
    if state and char and hrp then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "KirikFly"; bv.MaxForce = Vector3.new(10^6, 10^6, 10^6); bv.Velocity = Vector3.zero
        FlyLoop = RunService.Heartbeat:Connect(function()
            local cam = workspace.CurrentCamera
            local PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
            local moveVector = PlayerModule:GetControls():GetMoveVector()
            if moveVector.Magnitude > 0 then
                bv.Velocity = ((cam.CFrame.LookVector * -moveVector.Z) + (cam.CFrame.RightVector * moveVector.X)) * Config.FlySpeed
            else
                bv.Velocity = Vector3.zero
            end
        end)
    end
end

CreateToggle(UniversalPage, "Mobile Fly", ToggleFly)
local FlySpeedInput = CreateTextBox(UniversalPage, "Fly Speed", tostring(Config.FlySpeed), function(text)
    local num = tonumber(text:match("%d+"))
    if num then Config.FlySpeed = num end
end)

-- ===================================
-- STATS TRACKER (HUD + CALCULATOR)
-- ===================================
-- Создаем UI Трекера
local TrackerHUD = Instance.new("Frame", ScreenGui)
TrackerHUD.Size = UDim2.new(0, 180, 0, 110); TrackerHUD.Position = UDim2.new(0.8, -180, 0.2, 0)
TrackerHUD.BackgroundColor3 = Theme.ElementBg; TrackerHUD.Visible = false
Instance.new("UICorner", TrackerHUD).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", TrackerHUD).Color = Theme.Accent

local HUDTitle = Instance.new("TextLabel", TrackerHUD)
HUDTitle.Size = UDim2.new(1, 0, 0, 25); HUDTitle.BackgroundTransparency = 1
HUDTitle.Text = "📈 STATS TRACKER"; HUDTitle.Font = Enum.Font.GothamBold; HUDTitle.TextColor3 = Theme.Accent; HUDTitle.TextSize = 12

local LblCurrent = Instance.new("TextLabel", TrackerHUD)
LblCurrent.Size = UDim2.new(1, -10, 0, 20); LblCurrent.Position = UDim2.new(0, 10, 0, 25); LblCurrent.BackgroundTransparency = 1; LblCurrent.TextXAlignment = Enum.TextXAlignment.Left; LblCurrent.TextColor3 = Theme.Text; LblCurrent.Font = Enum.Font.GothamBold; LblCurrent.TextSize = 12

local LblEarned = Instance.new("TextLabel", TrackerHUD)
LblEarned.Size = UDim2.new(1, -10, 0, 20); LblEarned.Position = UDim2.new(0, 10, 0, 45); LblEarned.BackgroundTransparency = 1; LblEarned.TextXAlignment = Enum.TextXAlignment.Left; LblEarned.TextColor3 = Theme.Text; LblEarned.Font = Enum.Font.GothamBold; LblEarned.TextSize = 12

local LblPerMin = Instance.new("TextLabel", TrackerHUD)
LblPerMin.Size = UDim2.new(1, -10, 0, 20); LblPerMin.Position = UDim2.new(0, 10, 0, 65); LblPerMin.BackgroundTransparency = 1; LblPerMin.TextXAlignment = Enum.TextXAlignment.Left; LblPerMin.TextColor3 = Color3.fromRGB(100, 255, 150); LblPerMin.Font = Enum.Font.GothamBold; LblPerMin.TextSize = 12

local LblPerHour = Instance.new("TextLabel", TrackerHUD)
LblPerHour.Size = UDim2.new(1, -10, 0, 20); LblPerHour.Position = UDim2.new(0, 10, 0, 85); LblPerHour.BackgroundTransparency = 1; LblPerHour.TextXAlignment = Enum.TextXAlignment.Left; LblPerHour.TextColor3 = Color3.fromRGB(255, 200, 50); LblPerHour.Font = Enum.Font.GothamBold; LblPerHour.TextSize = 12

-- Драг для HUD
local hudDragging, hudStart, hudPos = false, nil, nil
HUDTitle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        hudDragging = true; hudStart = i.Position; hudPos = TrackerHUD.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then hudDragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if hudDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - hudStart
        TrackerHUD.Position = UDim2.new(hudPos.X.Scale, hudPos.X.Offset + delta.X, hudPos.Y.Scale, hudPos.Y.Offset + delta.Y)
    end
end)

-- Парсер PS99 Строк (переводит 1.5m в 1500000)
local suffixes = {k = 1e3, m = 1e6, b = 1e9, t = 1e12, q = 1e15, qi = 1e18}
local function ParseStat(str)
    str = string.lower(string.gsub(tostring(str), ",", ""))
    local num, suffix = string.match(str, "([%d%.]+)([a-z]*)")
    if num then
        local val = tonumber(num)
        if suffix and suffixes[suffix] then val = val * suffixes[suffix] end
        return val or 0
    end
    return 0
end

-- Красивый форматтер для HUD (возвращает 1500000 в 1.5m)
local function FormatStat(val)
    if val >= 1e18 then return string.format("%.2fqi", val / 1e18)
    elseif val >= 1e15 then return string.format("%.2fq", val / 1e15)
    elseif val >= 1e12 then return string.format("%.2ft", val / 1e12)
    elseif val >= 1e9 then return string.format("%.2fb", val / 1e9)
    elseif val >= 1e6 then return string.format("%.2fm", val / 1e6)
    elseif val >= 1e3 then return string.format("%.1fk", val / 1e3)
    else return tostring(math.floor(val)) end
end

local TrackerLoop
local StatHistory = {}

CreateToggle(TrackerPage, "Show Tracker HUD", function(state)
    TrackerHUD.Visible = state
    if state then
        StatHistory = {} -- Сброс истории при включении
        TrackerLoop = RunService.Heartbeat:Connect(function()
            -- Ищем валюту
            local currentStatString = "0"
            if LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild(Config.TrackedStat) then
                currentStatString = LocalPlayer.leaderstats[Config.TrackedStat].Value
            end
            local currentVal = ParseStat(currentStatString)

            -- Пишем историю раз в секунду
            local now = tick()
            if #StatHistory == 0 or now - StatHistory[#StatHistory].Time >= 1 then
                table.insert(StatHistory, {Time = now, Value = currentVal})
            end

            -- Удаляем старые записи за пределами времени
            while #StatHistory > 0 and (now - StatHistory[1].Time) > Config.TrackTime do
                table.remove(StatHistory, 1)
            end

            -- Математика
            if #StatHistory > 0 then
                local gained = currentVal - StatHistory[1].Value
                if gained < 0 then gained = 0; StatHistory = {} end -- Если потратил, сброс
                
                local timePassed = now - StatHistory[1].Time
                if timePassed < 1 then timePassed = 1 end

                local perSecond = gained / timePassed
                
                LblCurrent.Text = Config.TrackedStat..": " .. FormatStat(currentVal)
                LblEarned.Text = "Earned (".. math.floor(timePassed) .."s): " .. FormatStat(gained)
                LblPerMin.Text = "Per Min: " .. FormatStat(perSecond * 60)
                LblPerHour.Text = "Per Hour: " .. FormatStat(perSecond * 3600)
            end
        end)
    else
        if TrackerLoop then TrackerLoop:Disconnect() TrackerLoop = nil end
    end
end)

local TrackNameInput = CreateTextBox(TrackerPage, "Stat to Track (ex: Diamonds)", Config.TrackedStat, function(text)
    if text ~= "" then Config.TrackedStat = text; StatHistory = {} end
end)
local TrackTimeInput = CreateTextBox(TrackerPage, "Time Window in Seconds (ex: 60)", tostring(Config.TrackTime), function(text)
    local num = tonumber(text:match("%d+"))
    if num and num >= 5 then Config.TrackTime = num; StatHistory = {} end
end)

-- ===================================
-- PET SIMULATOR 99 (CUSTOM ZONES)
-- ===================================
local ZoneInputBox = CreateTextBox(PS99Page, "Target Zone (ex: 33)", tostring(Config.TargetPS99Zone), function(text)
    local num = tonumber(text:match("%d+"))
    if num then Config.TargetPS99Zone = num end
end)

CreateButton(PS99Page, "Save Current Pos as Zone Center", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then 
        local pos = hrp.Position
        Config.SavedZones[tostring(Config.TargetPS99Zone)] = {X = pos.X, Y = pos.Y, Z = pos.Z}
        KLog("SAVED! Export config in settings.")
    end
end)

CreateButton(PS99Page, "TP to Best Drop in Zone", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local preTpPos = nil
    local savedData = Config.SavedZones[tostring(Config.TargetPS99Zone)]
    if savedData then
        preTpPos = Vector3.new(savedData.X, savedData.Y, savedData.Z)
    else
        local mapFolder = workspace:FindFirstChild("Map")
        if mapFolder then
            for _, f in pairs(mapFolder:GetChildren()) do
                if tonumber(f.Name:match("^%d+")) == Config.TargetPS99Zone then
                    local part = f:FindFirstChildWhichIsA("BasePart", true)
                    if part then preTpPos = part.Position end
                    break
                end
            end
        end
    end
    if not preTpPos then return end

    hrp.Anchored = true
    hrp.CFrame = CFrame.new(preTpPos + Vector3.new(0, 25, 0))
    pcall(function() LocalPlayer:RequestStreamAroundAsync(preTpPos, 5) end)

    local bestTarget, maxVolume = nil, -1
    for i = 1, 10 do 
        local breakables = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Breakables")
        if breakables then
            for _, b in pairs(breakables:GetChildren()) do
                if (b:GetPivot().Position - preTpPos).Magnitude < 600 then 
                    local volume = b:IsA("Model") and (b:GetExtentsSize().X * b:GetExtentsSize().Y * b:GetExtentsSize().Z) or (b.Size.X * b.Size.Y * b.Size.Z)
                    if volume > maxVolume then maxVolume = volume; bestTarget = b end
                end
            end
        end
        if bestTarget then break end
        task.wait(0.5)
    end

    hrp.Anchored = false 
    if bestTarget then hrp.CFrame = bestTarget:GetPivot() * CFrame.new(0, 10, 0) end
end)

-- ===================================
-- CONFIG BASE64 IMPORT/EXPORT
-- ===================================
local SizeInputBox = CreateTextBox(SettingsPage, "Custom Hub Size (ex. 75, 1.2)", tostring(Config.UIScale), function(text)
    local scale = tonumber(text:match("[%d%.]+"))
    if scale then
        if scale >= 10 then scale = scale / 100 end
        scale = math.clamp(scale, 0.4, 2.5); Config.UIScale = scale
        TweenService:Create(MainScale, TweenInfo.new(0.2), {Scale = scale}):Play()
    end
end)

local ConfigBox = CreateTextBox(SettingsPage, "Base64 Code", "...", function() end)
CreateButton(SettingsPage, "EXPORT CONFIG (Copy All)", function()
    local b64 = Base64.Encode(HttpService:JSONEncode(Config)); ConfigBox.Text = b64
    if setclipboard then pcall(setclipboard, b64) end
end)
CreateButton(SettingsPage, "IMPORT CONFIG (Load All)", function()
    pcall(function()
        local data = HttpService:JSONDecode(Base64.Decode(ConfigBox.Text))
        if type(data) == "table" then
            Config = data
            ZoneInputBox.Text = tostring(Config.TargetPS99Zone or 1)
            FlySpeedInput.Text = tostring(Config.FlySpeed or 50)
            TrackNameInput.Text = tostring(Config.TrackedStat or "Diamonds")
            TrackTimeInput.Text = tostring(Config.TrackTime or 60)
            local scale = Config.UIScale or 1.0; SizeInputBox.Text = tostring(scale)
            TweenService:Create(MainScale, TweenInfo.new(0.2), {Scale = scale}):Play()
            KLog("Config Loaded!")
        end
    end)
end)

KLog("Hub Loaded! V8 Ultimate (Anti-AFK & Tracker)")
