--[[ 
    KIRIK LUXURY HUB v6.0 (REMASTERED)
    Optimized for Mobile Executors (Delta, Hydrogen, etc.)
    Zero Bugs, Touch-Friendly, Modern Gamer UI
]]

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Защита от дубликатов при повторном запуске
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
    Text = Color3.fromRGB(240, 240, 240),
    ElementBg = Color3.fromRGB(30, 30, 38),
    ElementHover = Color3.fromRGB(40, 40, 50)
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
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Theme.Accent
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- ВЕРХНЯЯ ПАНЕЛЬ (TOPBAR)
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
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KIRIK LUXURY <font color='#00ff80'>HUB</font>"
Title.RichText = true
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Theme.Text
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

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

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0)}):Play()
    task.wait(0.2)
    ScreenGui:Destroy()
end)

-- ПЛАВНОЕ ПЕРЕТАСКИВАНИЕ (MOBILE + PC)
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    TweenService:Create(MainFrame, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos}):Play()
end

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

-- БОКОВАЯ ПАНЕЛЬ (ВКЛАДКИ)
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 130, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.Parent = Sidebar

-- КОНТЕЙНЕР ДЛЯ СТРАНИЦ
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -130, 1, -40)
ContentContainer.Position = UDim2.new(0, 130, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- UI БИБЛИОТЕКА (ВНУТРЕННЯЯ)
local Tabs = {}
local Pages = {}
local CurrentTab = nil

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0.9, 0, 0, 40)
    TabBtn.BackgroundColor3 = Theme.ElementBg
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextColor3 = Theme.Text
    TabBtn.TextSize = 14
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)
    
    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = Theme.Accent
    TabStroke.Transparency = 1
    TabStroke.Parent = TabBtn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Theme.Accent
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
    Btn.Size = UDim2.new(0.95, 0, 0, 45) -- Крупные для пальцев
    Btn.BackgroundColor3 = Theme.ElementBg
    Btn.Text = text
    Btn.Font = Enum.Font.GothamBold
    Btn.TextColor3 = Theme.Text
    Btn.TextSize = 14
    Btn.Parent = page
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Btn).Color = Color3.fromRGB(60, 60, 70)

    Btn.MouseButton1Down:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.9, 0, 0, 42)}):Play()
    end)
    Btn.MouseButton1Up:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0, 45)}):Play()
    end)
    Btn.MouseButton1Click:Connect(function()
        task.spawn(callback)
    end)
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
    Label.Text = text
    Label.Font = Enum.Font.GothamBold
    Label.TextColor3 = Theme.Text
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
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

--=========================================--
--           ФУНКЦИОНАЛ ХАБА               --
--=========================================--

local UniversalPage = CreateTab("Universal")
local PS99Page = CreateTab("PS99")
local MM2Page = CreateTab("MM2")

-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
local FlySpeed = 50
local FlyLoop
local NoclipLoop
local ESP_Loop

-- СУПЕР-МОБИЛЬНЫЙ FLY (Использует джойстик!)
local function ToggleFly(state)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if FlyLoop then FlyLoop:Disconnect() FlyLoop = nil end
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v.Name == "KirikFly" then v:Destroy() end
        end
    end

    if state and char and hrp then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "KirikFly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp

        FlyLoop = RunService.Heartbeat:Connect(function()
            local cam = workspace.CurrentCamera
            local PlayerModule = require(LocalPlayer.PlayerScripts:WaitForChild("PlayerModule"))
            local moveVector = PlayerModule:GetControls():GetMoveVector()

            if moveVector.Magnitude > 0 then
                local fwd = cam.CFrame.LookVector
                local right = cam.CFrame.RightVector
                -- Движение ровно по камере + джойстику
                bv.Velocity = ((fwd * -moveVector.Z) + (right * moveVector.X)) * FlySpeed
            else
                bv.Velocity = Vector3.zero
            end
        end)
    end
end

-- УЛУЧШЕННЫЙ NOCLIP
local function ToggleNoclip(state)
    if NoclipLoop then NoclipLoop:Disconnect() NoclipLoop = nil end
    if state then
        NoclipLoop = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- UNIVERSAL ESP
local function ToggleESP(state)
    if ESP_Loop then ESP_Loop:Disconnect() ESP_Loop = nil end
    
    local function clearESP()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("KirikESP") then
                p.Character.KirikESP:Destroy()
            end
        end
    end

    if state then
        ESP_Loop = RunService.Heartbeat:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if not p.Character:FindFirstChild("KirikESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "KirikESP"
                        hl.FillColor = Theme.Accent
                        hl.OutlineColor = Color3.new(1, 1, 1)
                        hl.FillTransparency = 0.5
                        hl.Parent = p.Character
                    end
                end
            end
        end)
    else
        clearESP()
    end
end

-- НАПОЛНЕНИЕ: UNIVERSAL
CreateToggle(UniversalPage, "Mobile Fly", ToggleFly)
CreateButton(UniversalPage, "Fly Speed: 50 (Default)", function() FlySpeed = 50 end)
CreateButton(UniversalPage, "Fly Speed: 100 (Fast)", function() FlySpeed = 100 end)
CreateToggle(UniversalPage, "Noclip", ToggleNoclip)
CreateToggle(UniversalPage, "Player ESP", ToggleESP)

-- НАПОЛНЕНИЕ: PET SIMULATOR 99
CreateButton(PS99Page, "TP to Random Coin", function()
    local things = workspace:FindFirstChild("__THINGS")
    local breakables = things and things:FindFirstChild("Breakables")
    
    if breakables then
        for _, target in pairs(breakables:GetChildren()) do
            local pos
            if target:IsA("Model") and target.PrimaryPart then
                pos = target.PrimaryPart.CFrame
            elseif target:IsA("BasePart") then
                pos = target.CFrame
            end
            
            if pos then
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = pos + Vector3.new(0, 5, 0)
                    return -- Телепортируемся к первой и выходим
                end
            end
        end
    end
end)

-- НАПОЛНЕНИЕ: MURDER MYSTERY 2
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
        if #spawns > 0 then
            char.HumanoidRootPart.CFrame = spawns[math.random(1, #spawns)].CFrame + Vector3.new(0, 3, 0)
        end
    end
end)
