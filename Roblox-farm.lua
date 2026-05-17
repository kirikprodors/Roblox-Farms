--[[ 
    KIRIK LUXURY HUB v2.0 (Mobile UI)
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TabButtons = Instance.new("Frame")
local ContentFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")

-- Настройка главного контейнера
ScreenGui.Name = "KirikHub"
ScreenGui.Parent = game.CoreGui -- Чтобы Delta его видела

-- Главное окно
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Active = true
MainFrame.Draggable = true -- Можно двигать пальцем по экрану

local MainCorner = Instance.new("UICorner", MainFrame)

-- Панель вкладок (слева)
TabButtons.Name = "TabButtons"
TabButtons.Parent = MainFrame
TabButtons.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TabButtons.Size = UDim2.new(0, 100, 1, 0)

local TabCorner = Instance.new("UICorner", TabButtons)

-- Контентная часть (справа)
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0.25, 0, 0, 0)
ContentFrame.Size = UDim2.new(0.75, 0, 1, 0)
ContentFrame.BackgroundTransparency = 1

-- Функция создания страниц
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Parent = ContentFrame
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 2
    return Page
end

local MM2Page = CreatePage("MM2")
local PS99Page = CreatePage("PS99")

-- Функция создания кнопок функций
local function CreateButton(text, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, #parent:GetChildren() * 45)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
end

-- --- КНОПКИ ДЛЯ MM2 ---
CreateButton("Подсветка (ESP)", MM2Page, function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            local hl = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
            hl.FillColor = Color3.fromRGB(255, 255, 255)
        end
    end
end)

CreateButton("ТП к монете (Coin TP)", MM2Page, function()
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

-- --- КНОПКИ ДЛЯ PS99 ---
CreateButton("Притянуть сферы (Collect)", PS99Page, function()
    local orbs = workspace:FindFirstChild("Orbs")
    if orbs then
        for _, orb in pairs(orbs:GetChildren()) do
            orb.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end)

-- --- КНОПКИ ПЕРЕКЛЮЧЕНИЯ ВКЛАДОК ---
local function SwitchTab(page)
    MM2Page.Visible = false
    PS99Page.Visible = false
    page.Visible = true
end

local btnMM2 = Instance.new("TextButton", TabButtons)
btnMM2.Size = UDim2.new(1, 0, 0, 40)
btnMM2.Text = "MM2"
btnMM2.BackgroundTransparency = 1
btnMM2.TextColor3 = Color3.new(1,1,1)
btnMM2.MouseButton1Click:Connect(function() SwitchTab(MM2Page) end)

local btnPS99 = Instance.new("TextButton", TabButtons)
btnPS99.Size = UDim2.new(1, 0, 0, 40)
btnPS99.Position = UDim2.new(0, 0, 0, 45)
btnPS99.Text = "Pet Sim 99"
btnPS99.BackgroundTransparency = 1
btnPS99.TextColor3 = Color3.new(1,1,1)
btnPS99.MouseButton1Click:Connect(function() SwitchTab(PS99Page) end)

-- Открываем первую вкладку по умолчанию
SwitchTab(MM2Page)

print("GUI загружен!")
