-- ============================================
-- MM2 ULTIMATE CHECKER (FULL INFO + DREAM PETS)
-- ИЕРАРХИЧЕСКАЯ СИСТЕМА: главная кнопка → меню → настройки
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

-- Состояние UI
local UI_STATE = {
    mainOpen = true,
    settingsOpen = false
}

-- Прозрачности
local transparency = {
    bg = 0.55,
    main = 0.1,
    icon = 0
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

-- ========== ПРЕОБРАЗОВАНИЕ ИМЁН ==========
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
    return prices[normalizeChromaName(name)] or 0
end

local function getDreamPrice(name)
    return dreampets[normalizeChromaName(name)] or 0
end

-- ========== GUI ==========
pcall(function() game.CoreGui.MM2VALUEGUI:Destroy() end)

local gui = Instance.new("ScreenGui")
gui.Name = "MM2VALUEGUI"
gui.Parent = game.CoreGui

-- ============================================
-- ГЛАВНАЯ КНОПКА-МЕНЮ (КРУГЛАЯ)
-- ============================================
local mainButton = Instance.new("ImageButton")
mainButton.Parent = gui
mainButton.Name = "MainButton"

mainButton.Size = UDim2.new(0, 60, 0, 60)
mainButton.Position = UDim2.new(0, 20, 0.5, -30)

mainButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainButton.BackgroundTransparency = transparency.icon
mainButton.BorderSizePixel = 0

mainButton.Image = "rbxassetid://7072719338"
mainButton.ScaleType = Enum.ScaleType.Crop
mainButton.ZIndex = 999999

Instance.new("UICorner", mainButton).CornerRadius = UDim.new(1, 0)

-- ============================================
-- ПЕРЕТАСКИВАНИЕ ГЛАВНОЙ КНОПКИ
-- ============================================
local buttonDragging = false
local buttonDragStart, buttonStartPos

mainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        buttonDragging = true
        buttonDragStart = input.Position
        buttonStartPos = mainButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                buttonDragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if buttonDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - buttonDragStart
        mainButton.Position = UDim2.new(
            buttonStartPos.X.Scale,
            buttonStartPos.X.Offset + delta.X,
            buttonStartPos.Y.Scale,
            buttonStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================
-- ОСНОВНОЙ ФРЕЙМ (ГЛАВНОЕ МЕНЮ)
-- ============================================
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 800, 0, 450)
frame.Position = UDim2.new(0.5, -400, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = transparency.main
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Visible = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

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
            if input.UserInputState == Enum.UserInputState.End then frameDragging = false end
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
-- ФОН ГЛАВНОГО МЕНЮ
-- ============================================
local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Parent = frame
backgroundImage.Size = UDim2.new(1, 0, 1, 0)
backgroundImage.BackgroundTransparency = 1
backgroundImage.Image = "rbxassetid://9066026056"
backgroundImage.ImageTransparency = transparency.bg
backgroundImage.ScaleType = Enum.ScaleType.Crop
backgroundImage.ZIndex = -999

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

local centerLine = Instance.new("Frame")
centerLine.Parent = frame
centerLine.Position = UDim2.new(0.5, 0, 0, 40)
centerLine.Size = UDim2.new(0, 2, 1, -40)
centerLine.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

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
yourTotalFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", yourTotalFrame).CornerRadius = UDim.new(0, 5)

local yourTotalLabel = Instance.new("TextLabel")
yourTotalLabel.Parent = yourTotalFrame
yourTotalLabel.Size = UDim2.new(1, 0, 0.5, 0)
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
theirTotalFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", theirTotalFrame).CornerRadius = UDim.new(0, 5)

local theirTotalLabel = Instance.new("TextLabel")
theirTotalLabel.Parent = theirTotalFrame
theirTotalLabel.Size = UDim2.new(1, 0, 0.5, 0)
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

-- ========== СОЗДАНИЕ СЛОТОВ ==========
local function createSlot(parent, xPos, yPos, slotNum)
    local slotFrame = Instance.new("Frame")
    slotFrame.Parent = parent
    slotFrame.Size = UDim2.new(0, 175, 0, 140)
    slotFrame.Position = UDim2.new(0, xPos, 0, yPos)
    slotFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    slotFrame.BackgroundTransparency = 0.2
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
    {15, 115}, {200, 115},
    {15, 265}, {200, 265}
}
local theirPos = {
    {410, 115}, {595, 115},
    {410, 265}, {595, 265}
}

for i = 1, 4 do
    local slot = createSlot(frame, yourPos[i][1], yourPos[i][2], i)
    yourSlots[i] = slot
    slot.chromaBtn.MouseButton1Click:Connect(function()
        yourChromaMode[i] = not yourChromaMode[i]
        slot.chromaBtn.BackgroundColor3 = yourChromaMode[i] and Color3.fromRGB(150,50,200) or Color3.fromRGB(40,40,40)
        slot.chromaBtn.TextColor3 = yourChromaMode[i] and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
    end)
    slot.selectBtn.MouseButton1Click:Connect(function()
        YOUR_MAX_SLOT = i
        for j = 1, 4 do
            yourSlots[j].frame.BackgroundColor3 = (j == i) and Color3.fromRGB(40,60,90) or Color3.fromRGB(25,25,25)
        end
    end)
end

for i = 1, 4 do
    local slot = createSlot(frame, theirPos[i][1], theirPos[i][2], i)
    theirSlots[i] = slot
    slot.chromaBtn.MouseButton1Click:Connect(function()
        theirChromaMode[i] = not theirChromaMode[i]
        slot.chromaBtn.BackgroundColor3 = theirChromaMode[i] and Color3.fromRGB(150,50,200) or Color3.fromRGB(40,40,40)
        slot.chromaBtn.TextColor3 = theirChromaMode[i] and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
    end)
    slot.selectBtn.MouseButton1Click:Connect(function()
        THEIR_MAX_SLOT = i
        for j = 1, 4 do
            theirSlots[j].frame.BackgroundColor3 = (j == i) and Color3.fromRGB(40,60,90) or Color3.fromRGB(25,25,25)
        end
    end)
end

yourSlots[1].frame.BackgroundColor3 = Color3.fromRGB(40,60,90)
theirSlots[1].frame.BackgroundColor3 = Color3.fromRGB(40,60,90)

-- ============================================
-- ШЕСТЕРЁНКА (ВНУТРИ ГЛАВНОГО ОКНА)
-- ============================================
local settingsButton = Instance.new("ImageButton")
settingsButton.Parent = frame
settingsButton.Size = UDim2.new(0, 32, 0, 32)
settingsButton.Position = UDim2.new(1, -40, 0, 5)
settingsButton.BackgroundTransparency = 1
settingsButton.Image = "rbxassetid://6031094678"

-- ============================================
-- ФРЕЙМ НАСТРОЕК (НЕ ПЕРЕТАСКИВАЕТСЯ)
-- ============================================
local settingsFrame = Instance.new("Frame")
settingsFrame.Parent = gui
settingsFrame.Size = UDim2.new(0, 260, 0, 220)
settingsFrame.Position = UDim2.new(1, -280, 0, 50)
settingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
settingsFrame.BackgroundTransparency = 0.1
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 8)

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Parent = settingsFrame
settingsTitle.Size = UDim2.new(1, 0, 0, 35)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "⚙️ НАСТРОЙКИ"
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextColor3 = Color3.new(1, 1, 1)
settingsTitle.TextScaled = true

-- ============================================
-- ФУНКЦИЯ СОЗДАНИЯ ПОЛЗУНКА
-- ============================================
local function createSlider(name, posY, minVal, maxVal, defaultVal, callback)
    local holder = Instance.new("Frame")
    holder.Parent = settingsFrame
    holder.Size = UDim2.new(1, -20, 0, 50)
    holder.Position = UDim2.new(0, 10, 0, posY)
    holder.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Parent = holder
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. tostring(defaultVal)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local bar = Instance.new("Frame")
    bar.Parent = holder
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Parent = bar
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    
    local function update(input)
        local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -6, 0.5, -6)
        local value = minVal + (maxVal - minVal) * percent
        label.Text = name .. ": " .. math.floor(value * 100) / 100
        callback(value)
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- ============================================
-- ПОЛЗУНКИ НАСТРОЕК
-- ============================================
createSlider("ФОН (КАРТИНКА)", 40, 0, 1, transparency.bg, function(v)
    transparency.bg = v
    backgroundImage.ImageTransparency = v
end)

createSlider("ГЛАВНОЕ ОКНО", 95, 0, 1, transparency.main, function(v)
    transparency.main = v
    frame.BackgroundTransparency = v
    settingsFrame.BackgroundTransparency = v
end)

createSlider("ИКОНКА", 150, 0, 1, transparency.icon, function(v)
    transparency.icon = v
    mainButton.BackgroundTransparency = v
end)

-- ============================================
-- УПРАВЛЕНИЕ ОТКРЫТИЕМ/ЗАКРЫТИЕМ
-- ============================================

-- Главная кнопка: открывает/закрывает ВСЁ
mainButton.MouseButton1Click:Connect(function()
    UI_STATE.mainOpen = not UI_STATE.mainOpen
    frame.Visible = UI_STATE.mainOpen
    if not UI_STATE.mainOpen then
        UI_STATE.settingsOpen = false
        settingsFrame.Visible = false
    end
end)

-- Шестерёнка: открывает/закрывает настройки (только если главное окно открыто)
settingsButton.MouseButton1Click:Connect(function()
    if not UI_STATE.mainOpen then return end
    UI_STATE.settingsOpen = not UI_STATE.settingsOpen
    settingsFrame.Visible = UI_STATE.settingsOpen
end)

-- Закрытие настроек при закрытии главного окна (уже сделано выше)

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

local function calculateTotal(sideName, maxSlot, chromaTable)
    local tradeGui = LP.PlayerGui:FindFirstChild("TradeGUI")
    if not tradeGui then return 0, 0 end
    local container = tradeGui.Container.Trade[sideName].Container
    if not container then return 0, 0 end
    local totalV = 0
    local totalRub = 0
    for i = 1, maxSlot do
        local slot = container:FindFirstChild("NewItem"..i)
        if slot then
            local name = getSlotItemName(slot)
            if name then
                local amount = getSlotAmount(slot)
                local priceV, priceRub
                if chromaTable and chromaTable[i] then
                    local cn = getChromaName(name)
                    if cn then
                        priceV = getPrice(cn)
                        priceRub = getDreamPrice(cn)
                    else
                        priceV = getPrice(name)
                        priceRub = getDreamPrice(name)
                    end
                else
                    priceV = getPrice(name)
                    priceRub = getDreamPrice(name)
                end
                totalV = totalV + (priceV * amount)
                totalRub = totalRub + (priceRub * amount)
            end
        end
    end
    return totalV, totalRub
end

local function updateAll()
    local tradeGui = LP.PlayerGui:FindFirstChild("TradeGUI")
    if not tradeGui then return end
    
    local yourContainer = tradeGui.Container.Trade.YourOffer.Container
    local theirContainer = tradeGui.Container.Trade.TheirOffer.Container
    
    for i = 1, 4 do
        local slot = yourContainer:FindFirstChild("NewItem"..i)
        local s = yourSlots[i]
        if slot then
            local name = getSlotItemName(slot)
            if name then
                local amount = getSlotAmount(slot)
                local sp, dp
                if yourChromaMode[i] then
                    local cn = getChromaName(name)
                    if cn then
                        sp = getPrice(cn)
                        dp = getDreamPrice(cn)
                    else
                        sp = getPrice(name)
                        dp = getDreamPrice(name)
                    end
                else
                    sp = getPrice(name)
                    dp = getDreamPrice(name)
                end
                local ts = math.floor(sp * amount)
                local td = math.floor(dp * amount)
                local short = #name > 14 and name:sub(1,12)..".." or name
                s.nameLabel.Text = short
                if td > 0 then
                    s.priceLabel.Text = ts .. " V\n" .. td .. " ₽"
                else
                    s.priceLabel.Text = ts .. " V"
                end
                s.detailsLabel.Text = formatDetails(name, yourChromaMode[i])
            else
                s.nameLabel.Text = "Пусто"
                s.priceLabel.Text = "0 V"
                s.detailsLabel.Text = "❌"
            end
        else
            s.nameLabel.Text = "Пусто"
            s.priceLabel.Text = "0 V"
            s.detailsLabel.Text = "❌"
        end
    end
    
    for i = 1, 4 do
        local slot = theirContainer:FindFirstChild("NewItem"..i)
        local s = theirSlots[i]
        if slot then
            local name = getSlotItemName(slot)
            if name then
                local amount = getSlotAmount(slot)
                local sp, dp
                if theirChromaMode[i] then
                    local cn = getChromaName(name)
                    if cn then
                        sp = getPrice(cn)
                        dp = getDreamPrice(cn)
                    else
                        sp = getPrice(name)
                        dp = getDreamPrice(name)
                    end
                else
                    sp = getPrice(name)
                    dp = get
