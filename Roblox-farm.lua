--[[ 
    KIRIK LUXURY HUB v5.0 (PS99 UPDATE)
]]

if game.CoreGui:FindFirstChild("KirikHub") then
    game.CoreGui.KirikHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "KirikHub"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 255, 128)

-- ВЕРХНЯЯ ПАНЕЛЬ
local TopBar = Instance.new("Frame", MainFrame)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TopBar.Size = UDim2.new(1, 0, 0, 35)
local Title = Instance.new("TextLabel", TopBar)
Title.Text = "KIRIK LUXURY HUB"
Title.Font = Enum.Font.Code
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.BackgroundTransparency = 1

-- КНОПКИ ЗАКРЫТЬ/СВЕРНУТЬ
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Text = "X"; CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50); CloseBtn.Position = UDim2.new(0.9, 0, 0.1, 0); CloseBtn.Size = UDim2.new(0, 30, 0, 28)
local MinBtn = Instance.new("TextButton", TopBar)
MinBtn.Text = "-"; MinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); MinBtn.Position = UDim2.new(0.8, 0, 0.1, 0); MinBtn.Size = UDim2.new(0, 30, 0, 28)

-- КОНТЕЙНЕРЫ
local TabButtons = Instance.new("Frame", MainFrame)
TabButtons.Size = UDim2.new(0, 100, 1, -35); TabButtons.Position = UDim2.new(0, 0, 0, 35); TabButtons.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -100, 1, -35); ContentFrame.Position = UDim2.new(0, 100, 0, 35); ContentFrame.BackgroundTransparency = 1

local Pages = {}
local function CreatePage(name)
    local p = Instance.new("ScrollingFrame", ContentFrame)
    p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false
    local layout = Instance.new("UIListLayout", p); layout.HorizontalAlignment = "Center"; layout.Padding = UDim.new(0, 10)
    Pages[name] = p
    return p
end

local function CreateButton(text, page, callback)
    local btn = Instance.new("TextButton", page)
    btn.Size = UDim2.new(0.9, 0, 0, 40); btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.Font = "GothamBold"
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(0, 255, 128)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

-- ЛОГИКА ТЕЛЕПОРТА (ПЕРЕТАСКИВАНИЕ)
local dragging, dragStart, startPos
TopBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = i.Position; startPos = MainFrame.Position end end)
game:GetService("UserInputService").InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.Touch then
    local delta = i.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end end)
game:GetService("UserInputService").InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

-- ПЕРЕМЕННЫЕ СОСТОЯНИЙ
local noclip = false
local fly = false
local flySpeed = 50

-- СТРАНИЦЫ
local MM2Page = CreatePage("MM2")
local PS99Page = CreatePage("PS99")

-- ФУНКЦИЯ NOCLIP
game:GetService("RunService").Stepped:Connect(function()
    if noclip and game.Players.LocalPlayer.Character then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

--- КНОПКИ PET SIMULATOR 99 ---
CreateButton("Fly: OFF", PS99Page, function(btn)
    fly = not fly
    btn.Text = "Fly: " .. (fly and "ON" or "OFF")
    local char = game.Players.LocalPlayer.Character
    if fly then
        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.Name = "KirikFly"
        bv.MaxForce = Vector3.new(1,1,1) * 10^6
        bv.Velocity = Vector3.new(0,0,0)
        spawn(function()
            while fly do
                bv.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

CreateButton("Noclip: OFF", PS99Page, function(btn)
    noclip = not noclip
    btn.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

CreateButton("TP to Coin", PS99Page, function()
    local things = workspace:FindFirstChild("__THINGS")
    local breakables = things and things:FindFirstChild("Breakables")
    if breakables then
        local target = breakables:FindFirstChildWhichIsA("BasePart") or breakables:FindFirstChildWhichIsA("Model")
        if target then
            local pos = target:IsA("Model") and target:GetModelCFrame() or target.CFrame
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = pos
        end
    end
end)

-- ПЕРЕКЛЮЧЕНИЕ ВКЛАДОК
local function Tab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
end

local b1 = Instance.new("TextButton", TabButtons); b1.Text = "MM2"; b1.Size = UDim2.new(1,0,0,40); b1.MouseButton1Click:Connect(function() Tab("MM2") end)
local b2 = Instance.new("TextButton", TabButtons); b2.Text = "PS99"; b2.Size = UDim2.new(1,0,0,40); b2.Position = UDim2.new(0,0,0,45); b2.MouseButton1Click:Connect(function() Tab("PS99") end)

Tab("PS99") -- Открываем PS99 сразу

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
