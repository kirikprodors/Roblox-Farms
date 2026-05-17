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
MainFrame.Size = UDim2.new(0, 400, 0, 250)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
MainFrame.Active = true
Instance.new("UICorner", MainFrame)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0, 255, 128)
Stroke.Thickness = 2

-- ВЕРХНЯЯ ПАНЕЛЬ И КНОПКИ (X, -)
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Instance.new("UICorner", TopBar)

local Title = Instance.new("TextLabel", TopBar)
Title.Text = "KIRIK LUXURY HUB"
Title.TextColor3 = Color3.fromRGB(0, 255, 128)
Title.Font = Enum.Font.Code
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.BackgroundTransparency = 1

-- ЛОГИКА ПЕРЕТАСКИВАНИЯ (MOBILE)
local UIS = game:GetService("UserInputService")
local dragStart, startPos, dragging
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- ПЕРЕМЕННЫЕ ФУНКЦИЙ
local noclip = false
local flying = false
local speed = 50

-- СТРАНИЦЫ
local Content = Instance.new("Frame", MainFrame)
Content.Size = UDim2.new(0.75, 0, 1, -35)
Content.Position = UDim2.new(0.25, 0, 0, 35)
Content.BackgroundTransparency = 1

local PS99Page = Instance.new("ScrollingFrame", Content)
PS99Page.Size = UDim2.new(1,0,1,0)
PS99Page.BackgroundTransparency = 1
local List = Instance.new("UIListLayout", PS99Page)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center
List.Padding = UDim.new(0, 10)

-- КНОПКИ ГЕНЕРАТОР
local function CreateButton(txt, parent, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.9, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(0, 255, 128)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(cb)
end

-- ФУНКЦИИ PS99
CreateButton("ТП к ближайшей монете", PS99Page, function()
    local breakables = workspace:FindFirstChild("__THINGS") and workspace.__THINGS:FindFirstChild("Breakables")
    if breakables then
        local target = nil
        local dist = math.huge
        for _, v in pairs(breakables:GetChildren()) do
            if v:IsA("BasePart") then
                local d = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude
                if d < dist then dist = d target = v end
            end
        end
        if target then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.CFrame end
    end
end)

CreateButton("Noclip (Вкл/Выкл)", PS99Page, function()
    noclip = not noclip
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Noclip", Text = noclip and "Включен" or "Выключен"})
end)

CreateButton("Fly (Вкл/Выкл)", PS99Page, function()
    flying = not flying
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    local hrp = char.HumanoidRootPart
    if flying then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "KirikFly"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0,0,0)
    else
        if hrp:FindFirstChild("KirikFly") then hrp.KirikFly:Destroy() end
    end
end)

-- ЦИКЛЫ
game:GetService("RunService").Stepped:Connect(function()
    if noclip then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    if flying then
        local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
        if hrp:FindFirstChild("KirikFly") then
            hrp.KirikFly.Velocity = game.Workspace.CurrentCamera.CFrame.LookVector * speed
        end
    end
end)
