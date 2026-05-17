--[[ 
    KIRIK LUXURY HUB v3.0 (ULTRA GAMER EDITION)
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikHub_V3"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 420, 0, 280)
MainFrame.ClipsDescendants = true

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 255, 255) -- Неоновый бирюзовый
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = ToolUnits.new(0, 8)

-- ВЕРХНЯЯ ПАНЕЛЬ (Header)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Text = "KIRIK LUXURY HUB | V3.0"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- КНОПКА ЗАКРЫТИЯ (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TopBar
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18

local CloseCorner = Instance.new("UICorner", CloseBtn)

-- КНОПКА СВЕРНУТЬ (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = TopBar
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 2)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18

local MinCorner = Instance.new("UICorner", MinBtn)

-- КОНТЕНТ И ВКЛАДКИ
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = MainFrame
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1

local TabList = Instance.new("Frame")
TabList.Parent = Content
TabList.Size = UDim2.new(0, 110, 1, 0)
TabList.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local Pages = Instance.new("Frame")
Pages.Parent = Content
Pages.Position = UDim2.new(0, 110, 0, 0)
Pages.Size = UDim2.new(1, -110, 1, 0)
Pages.BackgroundTransparency = 1

-- ЛОГИКА ПЕРЕТАСКИВАНИЯ (MOBILE FRIENDLY)
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ЛОГИКА СВЕРТЫВАНИЯ
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    if not isMinimized then
        MainFrame:TweenSize(UDim2.new(0, 420, 0, 35), "Out", "Quint", 0.3, true)
        Content.Visible = false
        MinBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 420, 0, 280), "Out", "Quint", 0.3, true)
        Content.Visible = true
        MinBtn.Text = "-"
    end
    isMinimized = not isMinimized
end)

-- ЛОГИКА ЗАКРЫТИЯ
CloseBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = false -- Останавливаем все циклы
    ScreenGui:Destroy()
end)

-- ФУНКЦИЯ СОЗДАНИЯ КНОПОК ФУНКЦИЙ
local function AddButton(name, page, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Parent = page
    
    local bc = Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
    
    local bs = Instance.new("UIListLayout", page)
    bs.Padding = ToolUnits.new(0, 5)
    bs.HorizontalAlignment = Enum.HorizontalAlignment.Center
end

-- СОЗДАЕМ СТРАНИЦЫ
local MM2Page = Instance.new("ScrollingFrame", Pages)
MM2Page.Size = UDim2.new(1,0,1,0)
MM2Page.BackgroundTransparency = 1
MM2Page.Visible = true

-- ДОБАВЛЯЕМ КНОПКИ (Пример для MM2)
AddButton("MM2 ESP (Wallhack)", MM2Page, function()
    print("ESP Активирован")
    -- Тут код ESP
end)

AddButton("Fast Coin TP", MM2Page, function()
    print("ТП к монете...")
end)

print("KIRIK HUB V3 Загружен успешно!")
