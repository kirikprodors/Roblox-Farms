--[[ 
    KIRIK MULTI-GAME HUB v1.0
]]

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- ПЕРЕМЕННЫЕ ДЛЯ ВКЛАДОК
local MM2_Active = true
local PS99_Active = true

print("Hub успешно запущен!")

--- --- --- --- --- --- --- --- --- ---
--- СЕКЦИЯ: MURDER MYSTERY 2 ---
--- --- --- --- --- --- --- --- --- ---

-- 1. Подсветка игроков (ESP)
function MM2_PlayerESP()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= Player and p.Character and not p.Character:FindFirstChild("Highlight") then
            local hl = Instance.new("Highlight", p.Character)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            -- Цвет зависит от роли (если есть нож - красный)
            if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                hl.FillColor = Color3.fromRGB(255, 0, 0)
            else
                hl.FillColor = Color3.fromRGB(255, 255, 255)
            end
        end
    end
end

-- 2. Телепорт к монете (Быстрый прыжок)
function MM2_CoinTP()
    -- Ищем контейнер с монетами в MM2
    local coins = workspace:FindFirstChild("Normal") and workspace.Normal:FindFirstChild("CoinContainer")
    if coins then
        local coin = coins:FindFirstChildWhichIsA("BasePart") or coins:FindFirstChildWhichIsA("Model")
        if coin then
            local oldPos = Root.CFrame
            Root.CFrame = coin.CFrame -- ТП к монете
            task.wait(0.1)
            Root.CFrame = oldPos -- Возврат
        else
            print("Монеты не найдены")
        end
    end
end

--- --- --- --- --- --- --- --- --- ---
--- СЕКЦИЯ: PET SIMULATOR 99 ---
--- --- --- --- --- --- --- --- --- ---
-- В этой игре всё крутится вокруг сбора алмазов и коробок.

-- 1. Авто-сбор сфер (Orbs)
-- Скрипт будет притягивать к тебе вылетающие монетки и алмазы.
function PS99_AutoCollect()
    local orbs = workspace:FindFirstChild("Orbs")
    if orbs then
        for _, orb in pairs(orbs:GetChildren()) do
            orb.CFrame = Root.CFrame -- Притягиваем все сферы к себе
        end
    end
end

-- 2. Авто-клик по монетам
function PS99_AutoTap()
    local activeRaids = workspace:FindFirstChild("ActiveRaids") -- Пример поиска активных объектов
    -- В PS99 часто используют RemoteEvents для кликов, чтобы не нагружать телефон
    game:GetService("ReplicatedStorage").Network.Click:FireServer()
end

--- --- --- --- --- --- --- --- --- ---
--- ОСНОВНОЙ ЦИКЛ СКРИПТА ---
--- --- --- --- --- --- --- --- --- ---

spawn(function()
    while task.wait(1) do
        -- Тут можно добавить вызов функций по кнопкам из твоего UI
        -- Например, если кнопка нажата, то вызываем:
        -- MM2_PlayerESP()
    end
end)

print("Все вкладки (MM2, PS99) готовы к работе.")

