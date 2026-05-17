--[[ 
    KIRIK LUXURY HUB v3.0 (GAMER MOBILE EDITION)
]]

-- Удаляем старый хаб, если он открыт
if game.CoreGui:FindFirstChild("KirikHub") then
    game.CoreGui.KirikHub:Destroy()
end

_G.KirikHubActive = true -- Глобальная переменная для остановки циклов при закрытии

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikHub"
ScreenGui.Parent = game.CoreGui

-- ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Геймерский темный
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 8)

-- НЕОНОВАЯ ОБВОДКА
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 255, 128) -- Кислотно-зеленый
UIStroke.Thickness = 2

-- ВЕРХНЯЯ ПАНЕЛЬ (ДЛЯ ПЕРЕТАСКИВАНИЯ)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.Active = true

local TopCorner = Instance.new("UICorner", TopBar)
TopCorner.CornerRadius = UDim.new(0, 8)

-- Убираем скругление снизу у TopBar
local TopFix = Instance.new("Frame", TopBar)
TopFix.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopFix.Position = UDim2.new(0, 0, 0.8, 0)
TopFix.Size = UDim2.new(1, 0, 0.2, 0)
TopFix.BorderSizePixel = 0

-- НАЗВАНИЕ ХАБА
local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.02, 0, 0, 0)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Font = Enum.Font.Code -- Хакерский шрифт
Title.Text = "KIRIK LUXURY HUB"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- КНОПКА ЗАКРЫТЬ (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Position = UDim2.new(0.9, -5, 0.1, 0)
CloseBtn.Size = UDim2.new(0, 30, 0, 28)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- КНОПКА СВЕРНУТЬ (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TopBar
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinBtn.Position = UDim2.new(0.9, -40, 0.1, 0)
MinBtn.Size = UDim2.new(0, 30, 0, 28)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- ПАНЕЛЬ ВКЛАДОК (СЛЕВА)
local TabButtons = Instance.new("Frame")
TabButtons.Parent = MainFrame
TabButtons.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TabButtons.Position = UDim2.new(0, 0, 0, 35)
TabButtons.Size = UDim2.new(0, 100, 1, -35)
TabButtons.BorderSizePixel = 0

-- КОНТЕНТ (СПРАВА)
local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0.25, 0, 0, 35)
ContentFrame.Size = UDim2.new(0.75, 0, 1, -35)

--- ЛОГИКА ПЕРЕТАСКИВАНИЯ НА ТЕЛЕФОНЕ ---
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--- ЛОГИКА СВОРАЧИВАНИЯ И ЗАКРЫТИЯ ---
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinBtn.Text = "+"
        MainFrame.Size = UDim2.new(0, 400, 0, 35)
        TabButtons.Visible = false
        ContentFrame.Visible = false
    else
        MinBtn.Text = "-"
        MainFrame.Size = UDim2.new(0, 400, 0, 250)
        TabButtons.Visible = true
        ContentFrame.Visible = true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    _G.KirikHubActive = false -- Останавливает все фоновые скрипты
    ScreenGui:Destroy()
end)

--- СОЗДАНИЕ СТРАНИЦ И КНОПОК ---
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Parent = ContentFrame
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 128)
    return Page
end

local function CreateButton(text, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, 10 + (#parent:GetChildren() * 45))
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold -- Геймерский шрифт кнопок
    btn.TextSize = 14
    btn.Parent = parent
    
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(0, 255, 128)
    btnStroke.Thickness = 1
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(callback)
end

local MM2Page = CreatePage("MM2")
local PS99Page = CreatePage("PS99")
local AdoptPage = CreatePage("Adopt")

--- КНОПКИ MM2 ---
CreateButton("ESP Игроков", MM2Page, function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            local hl = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
            hl.FillColor = Color3.fromRGB(0, 255, 128)
        end
    end
end)

CreateButton("ТП к Монете", MM2Page, function()
    local coins = workspace:FindFirstChild("Normal") and workspace.Normal:FindFirstChild("CoinContainer")
    if coins then
        local coin = coins:FindFirstChildWhichIsA("BasePart") or coins:FindFirstChildWhichIsA("Model")
        if coin then
            local Root = game.Players.LocalPlayer.Character.HumanoidRootPart
            local oldPos = Root.CFrame
            Root.CFrame = coin.CFrame
            task.wait(0.2)
            Root.CFrame = oldPos
        end
    end
end)

--- КНОПКИ PS99 ---
CreateButton("Магнит Сфер", PS99Page, function()
    local orbs = workspace:FindFirstChild("Orbs")
    if orbs then
        for _, orb in pairs(orbs:GetChildren()) do
            orb.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end)

--- ПЕРЕКЛЮЧЕНИЕ ВКЛАДОК ---
local function CreateTabButton(text, page, yPos)
    local btn = Instance.new("TextButton")
    btn.Parent = TabButtons
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    
    btn.MouseButton1Click:Connect(function()
        MM2Page.Visible = false
        PS99Page.Visible = false
        AdoptPage.Visible = false
        page.Visible = true
    end)
end

CreateTabButton("MM2", MM2Page, 0)
CreateTabButton("PET SIM 99", PS99Page, 45)
CreateTabButton("ADOPT ME", AdoptPage, 90)

-- Открываем первую вкладку
MM2Page.Visible = true
