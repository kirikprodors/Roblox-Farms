--[[ 
    KIRIK LUXURY HUB v4.0 (MOBILE FIX)
]]

if game.CoreGui:FindFirstChild("KirikHub") then
    game.CoreGui.KirikHub:Destroy()
end

_G.KirikHubActive = true

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikHub"
ScreenGui.Parent = game.CoreGui

-- ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 255, 128)
UIStroke.Thickness = 2

-- ВЕРХНЯЯ ПАНЕЛЬ
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.Active = true
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.02, 0, 0, 0)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Font = Enum.Font.Code
Title.Text = "KIRIK LUXURY HUB"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Position = UDim2.new(0.9, -5, 0.1, 0)
CloseBtn.Size = UDim2.new(0, 30, 0, 28)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
MinBtn.Position = UDim2.new(0.9, -40, 0.1, 0)
MinBtn.Size = UDim2.new(0, 30, 0, 28)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- КОНТЕЙНЕРЫ
local TabButtons = Instance.new("ScrollingFrame", MainFrame)
TabButtons.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TabButtons.Position = UDim2.new(0, 0, 0, 35)
TabButtons.Size = UDim2.new(0, 100, 1, -35)
TabButtons.BorderSizePixel = 0
TabButtons.ScrollBarThickness = 0
local TabLayout = Instance.new("UIListLayout", TabButtons)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0.25, 0, 0, 35)
ContentFrame.Size = UDim2.new(0.75, 0, 1, -35)

--- ПЕРЕТАСКИВАНИЕ ДЛЯ ТЕЛЕФОНА ---
local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--- СВОРАЧИВАНИЕ ---
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
    _G.KirikHubActive = false
    ScreenGui:Destroy()
end)

--- ФУНКЦИИ ИНТЕРФЕЙСА ---
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", ContentFrame)
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 128)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local ListLayout = Instance.new("UIListLayout", Page)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 10)
    return Page
end

local function CreateButton(text, parent, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(0, 255, 128)
    btnStroke.Thickness = 1
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(callback)
end

local Pages = {}
local function CreateTabButton(text, page)
    table.insert(Pages, page)
    local btn = Instance.new("TextButton", TabButtons)
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBlack
    btn.TextSize = 14
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        page.Visible = true
    end)
end

-- СТРАНИЦЫ
local MM2Page = CreatePage("MM2")
local PS99Page = CreatePage("PS99")
local AdoptPage = CreatePage("Adopt")

CreateTabButton("MM2", MM2Page)
CreateTabButton("PET SIM 99", PS99Page)
CreateTabButton("ADOPT ME", AdoptPage)

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

-- ОТКРЫВАЕМ ПЕРВУЮ ВКЛАДКУ
MM2Page.Visible = true
