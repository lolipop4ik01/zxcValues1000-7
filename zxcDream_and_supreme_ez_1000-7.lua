-- ============================================
-- MM2 ULTIMATE CHECKER (РАБОЧАЯ ВЕРСИЯ + ШЕСТЕРЁНКА)
-- ============================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- ========== НАСТРОЙКИ ==========
local RAW_JSON_URL = "https://raw.githubusercontent.com/lolipop4ik01/zxcValues1000-7/refs/heads/main/prices.json"

-- Хранилища данных
local prices = {}
local dreampets = {}
local itemDetails = {}

-- Chroma-режимы
local yourChromaMode = { false, false, false, false }
local theirChromaMode = { false, false, false, false }
local YOUR_MAX_SLOT = 4
local THEIR_MAX_SLOT = 4

-- Прозрачности (0 = непрозрачный, 1 = полностью прозрачный)
local transparency = {
    bg = 0.55,      -- фоновая картинка
    frames = 0.85   -- все фреймы (окна, панели, слоты)
}

-- ========== ЗАГРУЗКА ДАННЫХ ==========
local function loadDataFromGitHub()
    local success, result = pcall(function()
        return game:HttpGet(RAW_JSON_URL)
    end)
    if not success then
        warn("[MM2Checker] Ошибка загрузки: " .. tostring(result))
        return false
    end

    local data = HttpService:JSONDecode(result)
    
    prices = {}
    dreampets = {}
    itemDetails = {}
    
    for category, items in pairs(data) do
        for itemName, info in pairs(items) do
            local valueNum = tonumber(info.value) or 0
            if valueNum > 0 then
                prices[itemName] = valueNum
            end
            
            local dpNum = tonumber(info.dreampets_price) or 0
            if dpNum > 0 then
                dreampets[itemName] = dpNum
            end
            
            itemDetails[itemName] = {
                stability = info.stability or "?",
                trend = info.trend or "?",
                range = info.range or "",
                demand = tostring(info.demand or "?"),
                rarity = tostring(info.rarity or "?")
            }
        end
    end
    
    print("[MM2Checker] Загружено Supreme: " .. tostring(#prices))
    print("[MM2Checker] Загружено DreamPets: " .. tostring(#dreampets))
    return true
end

-- ========== ПРЕОБРАЗОВАНИЕ ИМЁН (Chroma ↔ C.) ==========
local function normalizeChromaName(name)
    if name:match("^Chroma ") then
        local rest = name:sub(8)
        local cName = "C. " .. rest
        if prices[cName] or dreampets[cName] then
            return cName
        end
    end
    if name:match("^C%. ") then
        local rest = name:sub(4)
        local chromaName = "Chroma " .. rest
        if prices[chromaName] or dreampets[chromaName] then
            return chromaName
        end
    end
    return name
end

-- ========== CHROMA MAP ==========
local chromaMap = {
    ["Luger"] = "Chroma Luger", ["Laser"] = "Chroma Laser", ["Shark"] = "Chroma Shark",
    ["Heat"] = "Chroma Heat", ["Darkbringer"] = "Chroma Darkbringer", ["Lightbringer"] = "Chroma Lightbringer",
    ["Gemstone"] = "Chroma Gemstone", ["Deathshard"] = "Chroma Deathshard", ["Fang"] = "Chroma Fang",
    ["Slasher"] = "Chroma Slasher", ["Tides"] = "Chroma Tides", ["Gingerblade"] = "Chroma Gingerblade",
    ["Boneblade"] = "Chroma Boneblade", ["Seer"] = "Chroma Seer", ["Saw"] = "Chroma Saw",
    ["Elderwood Blade"] = "Chroma Elderwood Blade", ["Candleflame"] = "Chroma Candleflame",
    ["Sweet"] = "Chroma Sweet", ["Treat"] = "Chroma Treat", ["Snow Dagger"] = "Chroma Snow Dagger",
    ["Watergun"] = "Chroma Watergun", ["Snowcannon"] = "Chroma Snowcannon", ["Ornament"] = "Chroma Ornament",
    ["Blizzard"] = "Chroma Blizzard", ["Sunrise"] = "Chroma Sunrise", ["Bauble"] = "Chroma Bauble",
    ["Heart Wand"] = "Chroma Heart Wand", ["Swirly Gun"] = "Chroma Swirly Gun", ["Cookiecane"] = "Chroma Cookiecane",
}

local function getChromaName(regularName)
    if chromaMap[regularName] then return chromaMap[regularName] end
    local chromaName = "Chroma " .. regularName
    return prices[chromaName] and chromaName or nil
end

local function getPrice(name)
    local normalized = normalizeChromaName(name)
    return prices[normalized] or 0
end

local function getDreamPrice(name)
    local normalized = normalizeChromaName(name)
    return dreampets[normalized] or 0
end

-- ========== GUI ==========
pcall(function() game.CoreGui.MM2VALUEGUI:Destroy() end)

local gui = Instance.new("ScreenGui")
gui.Name = "MM2VALUEGUI"
gui.Parent = game.CoreGui

-- ============================================
-- ОСНОВНОЙ ФРЕЙМ
-- ============================================
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 800, 0, 450)
frame.Position = UDim2.new(0.5, -400, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = transparency.frames
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- ============================================
-- ФОН ГЛАВНОГО МЕНЮ
-- ============================================
local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Parent = frame
backgroundImage.Size = UDim2.new(1, 0, 1, 0)
backgroundImage.Position = UDim2.new(0, 0, 0, 0)
backgroundImage.BackgroundTransparency = 1
backgroundImage.Image = "rbxassetid://9066026056"
backgroundImage.ImageTransparency = transparency.bg
backgroundImage.ScaleType = Enum.ScaleType.Crop
backgroundImage.ZIndex = -999

-- ============================================
-- ШЕСТЕРЁНКА (ПАНЕЛЬ НАСТРОЕК)
-- ============================================

local settingsOpen = false
local settingsPanel = nil

-- Функция обновления прозрачности фреймов
local function updateFrameTransparency(value)
    transparency.frames = value
    frame.BackgroundTransparency = value
    if line1 then line1.BackgroundTransparency = value end
    if centerLine then centerLine.BackgroundTransparency = value end
    if yourTotalFrame then yourTotalFrame.BackgroundTransparency = value end
    if theirTotalFrame then theirTotalFrame.BackgroundTransparency = value end
    for i = 1, 4 do
        if yourSlots and yourSlots[i] then
            yourSlots[i].frame.BackgroundTransparency = math.min(value + 0.1, 0.95)
        end
        if theirSlots and theirSlots[i] then
            theirSlots[i].frame.BackgroundTransparency = math.min(value + 0.1, 0.95)
        end
    end
end

-- Функция обновления прозрачности фона
local function updateBGTransparency(value)
    transparency.bg = value
    backgroundImage.ImageTransparency = value
end

-- Создание панели настроек
local function createSettingsPanel()
    if settingsPanel then settingsPanel:Destroy() end
    
    settingsPanel = Instance.new("Frame")
    settingsPanel.Parent = gui
    settingsPanel.Size = UDim2.new(0, 260, 0, 130)
    settingsPanel.Position = UDim2.new(1, -280, 0, 50)
    settingsPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    settingsPanel.BackgroundTransparency = transparency.frames
    settingsPanel.BorderSizePixel = 0
    settingsPanel.Visible = false
    Instance.new("UICorner", settingsPanel).CornerRadius = UDim.new(0, 8)
    
    local stitle = Instance.new("TextLabel")
    stitle.Parent = settingsPanel
    stitle.Size = UDim2.new(1, 0, 0, 30)
    stitle.BackgroundTransparency = 1
    stitle.Text = "⚙️ НАСТРОЙКИ"
    stitle.Font = Enum.Font.GothamBold
    stitle.TextColor3 = Color3.new(1, 1, 1)
    stitle.TextScaled = true
    
    -- Фон (картинка)
    local bgLabel = Instance.new("TextLabel")
    bgLabel.Parent = settingsPanel
    bgLabel.Position = UDim2.new(0, 10, 0, 35)
    bgLabel.Size = UDim2.new(0, 150, 0, 20)
    bgLabel.BackgroundTransparency = 1
    bgLabel.Text = "Прозрачность фона:"
    bgLabel.Font = Enum.Font.Gotham
    bgLabel.TextSize = 12
    bgLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    local bgValue = Instance.new("TextLabel")
    bgValue.Parent = settingsPanel
    bgValue.Position = UDim2.new(0, 170, 0, 35)
    bgValue.Size = UDim2.new(0, 50, 0, 20)
    bgValue.BackgroundTransparency = 1
    bgValue.Text = math.floor(transparency.bg * 100) .. "%"
    bgValue.Font = Enum.Font.Gotham
    bgValue.TextSize = 12
    bgValue.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    local bgSlider = Instance.new("Frame")
    bgSlider.Parent = settingsPanel
    bgSlider.Position = UDim2.new(0, 10, 0, 58)
    bgSlider.Size = UDim2.new(0, 210, 0, 4)
    bgSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bgSlider.BorderSizePixel = 0
    Instance.new("UICorner", bgSlider).CornerRadius = UDim.new(1, 0)
    
    local bgKnob = Instance.new("Frame")
    bgKnob.Parent = bgSlider
    bgKnob.Size = UDim2.new(0, 12, 0, 12)
    bgKnob.Position = UDim2.new(transparency.bg, -6, 0.5, -6)
    bgKnob.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    bgKnob.BorderSizePixel = 0
    Instance.new("UICorner", bgKnob).CornerRadius = UDim.new(1, 0)
    
    -- Окна (фреймы)
    local frameLabel = Instance.new("TextLabel")
    frameLabel.Parent = settingsPanel
    frameLabel.Position = UDim2.new(0, 10, 0, 80)
    frameLabel.Size = UDim2.new(0, 150, 0, 20)
    frameLabel.BackgroundTransparency = 1
    frameLabel.Text = "Прозрачность окон:"
    frameLabel.Font = Enum.Font.Gotham
    frameLabel.TextSize = 12
    frameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    local frameValue = Instance.new("TextLabel")
    frameValue.Parent = settingsPanel
    frameValue.Position = UDim2.new(0, 170, 0, 80)
    frameValue.Size = UDim2.new(0, 50, 0, 20)
    frameValue.BackgroundTransparency = 1
    frameValue.Text = math.floor(transparency.frames * 100) .. "%"
    frameValue.Font = Enum.Font.Gotham
    frameValue.TextSize = 12
    frameValue.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    local frameSlider = Instance.new("Frame")
    frameSlider.Parent = settingsPanel
    frameSlider.Position = UDim2.new(0, 10, 0, 103)
    frameSlider.Size = UDim2.new(0, 210, 0, 4)
    frameSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    frameSlider.BorderSizePixel = 0
    Instance.new("UICorner", frameSlider).CornerRadius = UDim.new(1, 0)
    
    local frameKnob = Instance.new("Frame")
    frameKnob.Parent = frameSlider
    frameKnob.Size = UDim2.new(0, 12, 0, 12)
    frameKnob.Position = UDim2.new(transparency.frames, -6, 0.5, -6)
    frameKnob.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    frameKnob.BorderSizePixel = 0
    Instance.new("UICorner", frameKnob).CornerRadius = UDim.new(1, 0)
    
    -- Драг для фона
    local draggingBg = false
    bgKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingBg = true
        end
    end)
    
    -- Драг для окон
    local draggingFrame = false
    frameKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingFrame = true
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if draggingBg and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = bgSlider.AbsolutePosition.X
            local newPos = math.clamp((mousePos - sliderPos) / bgSlider.AbsoluteSize.X, 0, 1)
            updateBGTransparency(newPos)
            bgKnob.Position = UDim2.new(transparency.bg, -6, 0.5, -6)
            bgValue.Text = math.floor(transparency.bg * 100) .. "%"
        elseif draggingFrame and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = frameSlider.AbsolutePosition.X
            local newPos = math.clamp((mousePos - sliderPos) / frameSlider.AbsoluteSize.X, 0, 1)
            updateFrameTransparency(newPos)
            frameKnob.Position = UDim2.new(transparency.frames, -6, 0.5, -6)
            frameValue.Text = math.floor(transparency.frames * 100) .. "%"
            if settingsPanel then
                settingsPanel.BackgroundTransparency = transparency.frames
            end
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingBg = false
            draggingFrame = false
        end
    end)
end

-- Шестерёнка
local gearButton = Instance.new("ImageButton")
gearButton.Parent = frame
gearButton.Size = UDim2.new(0, 32, 0, 32)
gearButton.Position = UDim2.new(1, -40, 0, 5)
gearButton.BackgroundTransparency = 1
gearButton.Image = "rbxassetid://6031094678"

gearButton.MouseButton1Click:Connect(function()
    if not settingsPanel then
        createSettingsPanel()
    end
    settingsOpen = not settingsOpen
    settingsPanel.Visible = settingsOpen
end)

-- ============================================
-- ПЕРЕТАСКИВАНИЕ ГЛАВНОГО ОКНА
-- ============================================
local frameDragging = false
local frameDragStart, frameStartPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        frameDragging = true
        frameDragStart = input.Position
        frameStartPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                frameDragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if frameDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - frameDragStart
        frame.Position = UDim2.new(
            frameStartPos.X.Scale,
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale,
            frameStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================
-- ЗАГОЛОВОК
-- ============================================
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ZXC 1000-7 made by Ghouls SSS Rank"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

-- Разделители
local line1 = Instance.new("Frame")
line1.Parent = frame
line1.Position = UDim2.new(0, 0, 0, 35)
line1.Size = UDim2.new(1, 0, 0, 2)
line1.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
line1.BorderSizePixel = 0
line1.BackgroundTransparency = transparency.frames

local centerLine = Instance.new("Frame")
centerLine.Parent = frame
centerLine.Position = UDim2.new(0.5, 0, 0, 40)
centerLine.Size = UDim2.new(0, 2, 1, -40)
centerLine.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
centerLine.BorderSizePixel = 0
centerLine.BackgroundTransparency = transparency.frames

-- YOUR HEADER
local yourHeader = Instance.new("TextLabel")
yourHeader.Parent = frame
yourHeader.Position = UDim2.new(0, 0, 0, 42)
yourHeader.Size = UDim2.new(0.5, 0, 0, 22)
yourHeader.BackgroundTransparency = 1
yourHeader.Text = "YOUR SHIT"
yourHeader.Font = Enum.Font.GothamBold
yourHeader.TextColor3 = Color3.fromRGB(255, 200, 100)
yourHeader.TextScaled = true

-- THEIR HEADER
local theirHeader = Instance.new("TextLabel")
theirHeader.Parent = frame
theirHeader.Position = UDim2.new(0.5, 0, 0, 42)
theirHeader.Size = UDim2.new(0.5, 0, 0, 22)
theirHeader.BackgroundTransparency = 1
theirHeader.Text = "THEIR SHIT"
theirHeader.Font = Enum.Font.GothamBold
theirHeader.TextColor3 = Color3.fromRGB(100, 200, 255)
theirHeader.TextScaled = true

-- ========== ОБЩИЕ СУММЫ ==========
local yourTotalFrame = Instance.new("Frame")
yourTotalFrame.Parent = frame
yourTotalFrame.Position = UDim2.new(0, 0, 0, 65)
yourTotalFrame.Size = UDim2.new(0.5, 0, 0, 40)
yourTotalFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
yourTotalFrame.BackgroundTransparency = transparency.frames
yourTotalFrame.BorderSizePixel = 0
Instance.new("UICorner", yourTotalFrame).CornerRadius = UDim.new(0, 5)

local yourTotalLabel = Instance.new("TextLabel")
yourTotalLabel.Parent = yourTotalFrame
yourTotalLabel.Size = UDim2.new(1, 0, 0.5, 0)
yourTotalLabel.Position = UDim2.new(0, 0, 0, 0)
yourTotalLabel.BackgroundTransparency = 1
yourTotalLabel.Text = "TOTAL: 0 V"
yourTotalLabel.Font = Enum.Font.GothamBold
yourTotalLabel.TextScaled = true
yourTotalLabel.TextColor3 = Color3.fromRGB(180, 180, 180)

local yourTotalDreamLabel = Instance.new("TextLabel")
yourTotalDreamLabel.Parent = yourTotalFrame
yourTotalDreamLabel.Size = UDim2.new(1, 0, 0.5, 0)
yourTotalDreamLabel.Position = UDim2.new(0, 0, 0.5, 0)
yourTotalDreamLabel.BackgroundTransparency = 1
yourTotalDreamLabel.Text = ""
yourTotalDreamLabel.Font = Enum.Font.Gotham
yourTotalDreamLabel.TextSize = 12
yourTotalDreamLabel.TextColor3 = Color3.fromRGB(150, 150, 150)

local theirTotalFrame = Instance.new("Frame")
theirTotalFrame.Parent = frame
theirTotalFrame.Position = UDim2.new(0.5, 0, 0, 65)
theirTotalFrame.Size = UDim2.new(0.5, 0, 0, 40)
theirTotalFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
theirTotalFrame.BackgroundTransparency = transparency.frames
theirTotalFrame.BorderSizePixel = 0
Instance.new("UICorner", theirTotalFrame).CornerRadius = UDim.new(0, 5)

local theirTotalLabel = Instance.new("TextLabel")
theirTotalLabel.Parent = theirTotalFrame
theirTotalLabel.Size = UDim2.new(1, 0, 0.5, 0)
theirTotalLabel.Position = UDim2.new(0, 0, 0, 0)
theirTotalLabel.BackgroundTransparency = 1
theirTotalLabel.Text = "TOTAL: 0 V"
theirTotalLabel.Font = Enum.Font.GothamBold
theirTotalLabel.TextScaled = true
theirTotalLabel.TextColor3 = Color3.fromRGB(180, 180, 180)

local theirTotalDreamLabel = Instance.new("TextLabel")
theirTotalDreamLabel.Parent = theirTotalFrame
theirTotalDreamLabel.Size = UDim2.new(1, 0, 0.5, 0)
theirTotalDreamLabel.Position = UDim2.new(0, 0, 0.5, 0)
theirTotalDreamLabel.BackgroundTransparency = 1
theirTotalDreamLabel.Text = ""
theirTotalDreamLabel.Font = Enum.Font.Gotham
theirTotalDreamLabel.TextSize = 12
theirTotalDreamLabel.TextColor3 = Color3.fromRGB(150, 150, 150)

-- ========== СОЗДАНИЕ СЛОТА ==========
local function createSlot(parent, xPos, yPos, slotNum)
    local slotFrame = Instance.new("Frame")
    slotFrame.Parent = parent
    slotFrame.Size = UDim2.new(0, 175, 0, 140)
    slotFrame.Position = UDim2.new(0, xPos, 0, yPos)
    slotFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    slotFrame.BackgroundTransparency = transparency.frames + 0.1
    slotFrame.BorderSizePixel = 0
    Instance.new("UICorner", slotFrame).CornerRadius = UDim.new(0, 6)
    
    local num = Instance.new("TextLabel")
    num.Parent = slotFrame
    num.Size = UDim2.new(0, 22, 0, 18)
    num.Position = UDim2.new(0, 3, 0, 2)
    num.BackgroundTransparency = 1
    num.Text = tostring(slotNum)
    num.Font = Enum.Font.GothamBold
    num.TextSize = 12
    num.TextColor3 = Color3.fromRGB(180, 180, 180)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = slotFrame
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 0, 0, 22)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "..."
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local priceLabel = Instance.new("TextLabel")
    priceLabel.Parent = slotFrame
    priceLabel.Size = UDim2.new(1, 0, 0, 28)
    priceLabel.Position = UDim2.new(0, 0, 0, 44)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Text = "0 V"
    priceLabel.Font = Enum.Font.GothamBold
    priceLabel.TextSize = 11
    priceLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    priceLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local detailsLabel = Instance.new("TextLabel")
    detailsLabel.Parent = slotFrame
    detailsLabel.Size = UDim2.new(1, 0, 0, 58)
    detailsLabel.Position = UDim2.new(0, 0, 0, 76)
    detailsLabel.BackgroundTransparency = 1
    detailsLabel.Text = ""
    detailsLabel.Font = Enum.Font.Gotham
    detailsLabel.TextSize = 9
    detailsLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    detailsLabel.TextWrapped = true
    detailsLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local selectBtn = Instance.new("TextButton")
    selectBtn.Parent = slotFrame
    selectBtn.Size = UDim2.new(1, 0, 1, 0)
    selectBtn.BackgroundTransparency = 1
    selectBtn.Text = ""
    
    local chromaBtn = Instance.new("TextButton")
    chromaBtn.Parent = slotFrame
    chromaBtn.Size = UDim2.new(0, 22, 0, 22)
    chromaBtn.Position = UDim2.new(1, -26, 1, -24)
    chromaBtn.Text = "C"
    chromaBtn.Font = Enum.Font.GothamBold
    chromaBtn.TextSize = 12
    chromaBtn.BorderSizePixel = 0
    chromaBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    chromaBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Instance.new("UICorner", chromaBtn).CornerRadius = UDim.new(1, 0)
    
    return {
        frame = slotFrame,
        nameLabel = nameLabel,
        priceLabel = priceLabel,
        detailsLabel = detailsLabel,
        selectBtn = selectBtn,
        chromaBtn = chromaBtn
    }
end

-- ========== РАСПОЛОЖЕНИЕ СЛОТОВ ==========
local yourSlots = {}
local theirSlots = {}

local yourPos = {
    { x = 15, y = 115 }, { x = 200, y = 115 },
    { x = 15, y = 265 }, { x = 200, y = 265 }
}

local theirPos = {
    { x = 410, y = 115 }, { x = 595, y = 115 },
    { x = 410, y = 265 }, { x = 595, y = 265 }
}

for i = 1, 4 do
    local slot = createSlot(frame, yourPos[i][1], yourPos[i][2], i)
    yourSlots[i] = slot
    
    slot.chromaBtn.MouseButton1Click:Connect(function()
        yourChromaMode[i] = not yourChromaMode[i]
        slot.chromaBtn.BackgroundColor3 = yourChromaMode[i] and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(40, 40, 40)
        slot.chromaBtn.TextColor3 = yourChromaMode[i] and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150)
    end)
    
    slot.selectBtn.MouseButton1Click:Connect(function()
        YOUR_MAX_SLOT = i
        for j = 1, 4 do
            yourSlots[j].frame.BackgroundColor3 = (j == i) and Color3.fromRGB(40, 60, 90) or Color3.fromRGB(25, 25, 25)
        end
    end)
end

for i = 1, 4 do
    local slot = createSlot(frame, theirPos[i][1], theirPos[i][2], i)
    theirSlots[i] = slot
    
    slot.chromaBtn.MouseButton1Click:Connect(function()
        theirChromaMode[i] = not theirChromaMode[i]
        slot.chromaBtn.BackgroundColor3 = theirChromaMode[i] and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(40, 40, 40)
        slot.chromaBtn.TextColor3 = theirChromaMode[i] and Color3.new(1, 1, 1) or Color3.fromRGB(150, 150, 150)
    end)
    
    slot.selectBtn.MouseButton1Click:Connect(function()
        THEIR_MAX_SLOT = i
        for j = 1, 4 do
            theirSlots[j].frame.BackgroundColor3 = (j == i) and Color3.fromRGB(40, 60, 90) or Color3.fromRGB(25, 25, 25)
        end
    end)
end

yourSlots[1].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
theirSlots[1].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 90)

-- ============================================
-- ТОГГЛ КНОПКА (КРУГЛАЯ)
-- ============================================
local toggleButton = Instance.new("ImageButton")
toggleButton.Parent = gui
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 20, 0.5, -30)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.BackgroundTransparency = 0
toggleButton.BorderSizePixel = 0
toggleButton.Image = "rbxassetid://7072719338"
toggleButton.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

local opened = true
toggleButton.MouseButton1Click:Connect(function()
    opened = not opened
    frame.Visible = opened
    if settingsPanel then
        settingsPanel.Visible = false
        settingsOpen = false
    end
end)

-- Перетаскивание кнопки
local toggleDragging = false
local toggleDragStart, toggleStartPos

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleDragging = true
        toggleDragStart = input.Position
        toggleStartPos = toggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                toggleDragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if toggleDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - toggleDragStart
        toggleButton.Position = UDim2.new(
            toggleStartPos.X.Scale,
            toggleStartPos.X.Offset + delta.X,
            toggleStartPos.Y.Scale,
            toggleStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ========== ФУНКЦИИ ЧТЕНИЯ ТРЕЙДА ==========
local function getSlotItemName(slot)
    local itemName = slot:FindFirstChild("ItemName")
    if not itemName then return nil end
    local label = itemName:FindFirstChild("Label")
    if not label then return nil end
    local name = tostring(label.Text)
    if name == "" or name == " " then return nil end
    return name
end

local function getSlotAmount(slot)
    local container = slot:FindFirstChild("Container")
    if not container then return 1 end
    local amountObj = container:FindFirstChild("Amount")
    if amountObj and amountObj:IsA("TextLabel") then
        local txt = tostring(amountObj.Text)
        local num = txt:match("%d+")
        if num then return tonumber(num) end
    end
    return 1
end

-- ========== ФОРМАТИРОВАНИЕ ДЕТАЛЕЙ ==========
local function formatDetails(name, isChromaActive)
    local realName = name
    if isChromaActive then
        local chromaName = getChromaName(name)
        if chromaName then realName = chromaName end
    end
    
    local det = itemDetails[realName]
    if not det and isChromaActive then det = itemDetails[name] end
    if not det then return "📊 Нет данных" end
    
    local trendIcon = (det.trend == "Rising" and "📈") or (det.trend == "Falling" and "📉") or (det.trend == "Stable" and "➡️") or "❓"
    local rangeStr = (det.range and det.range ~= "") and ("📊 " .. det.range) or ""
    
    local lines = {string.format("%s %s | %s", trendIcon, det.trend, det.stability)}
    if rangeStr ~= "" then table.insert(lines, rangeStr) end
    table.insert(lines, string.format("🔥 %s | ✨ %s", det.demand, det.rarity))
    
    return table.concat(lines, "\n")
end

-- ========== ПОДСЧЁТ ОБЩИХ СУММ
