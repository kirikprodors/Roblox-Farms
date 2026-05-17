--[[ 
    KIRIK LUXURY HUB v3.1 (MOBILE FIX)
]]

-- Чистим старые версии
if game.CoreGui:FindFirstChild("KirikHub") then
    game.CoreGui.KirikHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 350, 0, 220)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true -- Нужно для перетаскивания

local MainCorner = Instance.new("UICorner", MainFrame)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 255, 128)
UIStroke.Thickness = 2

-- ВЕРХНЯЯ ПАНЕЛЬ
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.Size = UDim2.new(1, 0, 0, 35)

local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Font = Enum.Font.Code
Title.Text = "KIRIK HUB"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- КНОПКИ УПРАВЛЕНИЯ
local function CreateTitleBtn(text, pos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = TopBar
    btn.Size = UDim2.new(0, 30, 0, 25)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Закрыть
CreateTitleBtn("X", UDim2.new(1, -35, 0.15, 0), Color3.fromRGB(200, 50, 50), function()
    ScreenGui:Destroy()
end)

-- Свернуть
local isMin = false
local Content = Instance.new("Frame", MainFrame) -- Контейнер для всего что ниже шапки
Content.Size = UDim2.new(1, 0, 1, -35)
Content.Position = UDim2.new(0, 0, 0, 35)
Content.BackgroundTransparency = 1

CreateTitleBtn("-", UDim2.new(1, -70, 0.15, 0), Color3.fromRGB(60, 60, 60), function(btn)
    isMin = not isMin
    Content.Visible = not isMin
    MainFrame.Size = isMin and UDim2.new(0, 350, 0, 35) or UDim2.new(0, 350, 0, 220)
end)

-- СКРИПТ ПЕРЕТАСКИВАНИЯ (УПРОЩЕННЫЙ)
local UIS = game:GetService("UserInputService")
local dragStart, startPos, dragging

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ВКЛАДКИ
local TabButtons = Instance.new("Frame", Content)
TabButtons.Size = UDim2.new(0, 80, 1, 0)
TabButtons.BackgroundColor3 = Color3.fromRGB(20, 20, 25)

local Pages = Instance.new("Frame", Content)
Pages.Size = UDim2.new(1, -85, 1, -10)
Pages.Position = UDim2.new(0, 85, 0, 5)
Pages.BackgroundTransparency = 1

local function CreatePage(name)
    local f = Instance.new("ScrollingFrame", Pages)
    f.Name = name
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.ScrollBarThickness = 2
    local layout = Instance.new("UIListLayout", f)
    layout.Padding = UDim.new(0, 5)
    return f
end

local MM2Page = CreatePage("MM2")
local PS99Page = CreatePage("PS99")

-- КНОПКИ ДЛЯ ФУНКЦИЙ
local function AddButton(text, page, callback)
    local b = Instance.new("TextButton", page)
    b.Size = UDim2.new(1, -5, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 12
    Instance.new("UICorner", b)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(0, 255, 128)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    b.MouseButton1Click:Connect(callback)
end

-- Наполняем MM2
AddButton("ESP Игроков", MM2Page, function() print("ESP ON") end)
AddButton("ТП к Монете", MM2Page, function() print("TP Coin") end)

-- Наполняем PS99
AddButton("Магнит Сфер", PS99Page, function() print("Magnet ON") end)

-- ПЕРЕКЛЮЧАТЕЛЬ ВКЛАДОК
local function AddTab(name, page)
    local t = Instance.new("TextButton", TabButtons)
    t.Size = UDim2.new(1, 0, 0, 40)
    t.Position = UDim2.new(0, 0, 0, #TabButtons:GetChildren() * 40 - 40)
    t.BackgroundTransparency = 1
    t.Text = name
    t.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    t.Font = Enum.Font.GothamBold
    t.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages:GetChildren()) do p.Visible = false end
        page.Visible = true
    end)
end

AddTab("MM2", MM2Page)
AddTab("PS99", PS99Page)

MM2Page.Visible = true
