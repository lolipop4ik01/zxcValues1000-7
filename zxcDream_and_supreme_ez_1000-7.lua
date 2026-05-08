-- ============================================
-- MM2 ULTIMATE CHECKER (FULL INFO + DREAM PETS)
-- С настройками: прозрачность фона + выбор картинки
-- ============================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
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

-- Настройки GUI (сохраняются)
local settings = {
    bgTransparency = 0.3,
    currentBG = nil,
    availableBGs = {}
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

-- ========== EXECUTOR IMAGE SYSTEM ==========
local EXECUTOR_FOLDER = "1000-7_Assets"
local ICONS_FOLDER = EXECUTOR_FOLDER .. "/Icons_ZXC"
local BG_FOLDER = EXECUTOR_FOLDER .. "/Backgrounds_Ghoul"

if makefolder then
    if not isfolder(EXECUTOR_FOLDER) then
        makefolder(EXECUTOR_FOLDER)
    end
    if not isfolder(ICONS_FOLDER) then
        makefolder(ICONS_FOLDER)
    end
    if not isfolder(BG_FOLDER) then
        makefolder(BG_FOLDER)
    end
end

local function getAllImages(folder)
    if not listfiles then return {} end
    local files = listfiles(folder)
    local valid = {}
    for _,file in ipairs(files) do
        local lower = string.lower(file)
        if lower:find(".png") or lower:find(".jpg") or lower:find(".jpeg") then
            table.insert(valid, file)
        end
    end
    return valid
end

local function fileToAsset(path)
    if getsynasset then return getsynasset(path) end
    if getcustomasset then return getcustomasset(path) end
    return nil
end

-- Загружаем все фоны
local bgFiles = getAllImages(BG_FOLDER)
for _, path in ipairs(bgFiles) do
    table.insert(settings.availableBGs, fileToAsset(path))
end

local randomIconPath = getRandomImage(ICONS_FOLDER)
local iconAsset = randomIconPath and fileToAsset(randomIconPath)

-- ========== GUI ==========
pcall(function() game.CoreGui.MM2VALUEGUI:Destroy() end)

local gui = Instance.new("ScreenGui")
gui.Name = "MM2VALUEGUI"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

-- ============================================
-- ОСНОВНОЙ ФРЕЙМ
-- ============================================
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 800, 0, 450)
frame.Position = UDim2.new(0.5, -400, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- ============================================
-- ФОН (КАРТИНКА)
-- ============================================
local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Parent = frame
backgroundImage.Size = UDim2.new(1, 0, 1, 0)
backgroundImage.Position = UDim2.new(0, 0, 0, 0)
backgroundImage.BackgroundTransparency = 1
backgroundImage.ImageTransparency = settings.bgTransparency
backgroundImage.ScaleType = Enum.ScaleType.Crop
backgroundImage.ZIndex = -999

-- Выбираем случайный фон
if #settings.availableBGs > 0 then
    settings.currentBG = settings.availableBGs[math.random(1, #settings.availableBGs)]
    backgroundImage.Image = settings.currentBG
end

-- ============================================
-- ПАНЕЛЬ НАСТРОЕК (ШЕСТЕРЁНКА)
-- ============================================

local settingsOpen = false
local settingsPanel = nil

local function createSettingsPanel()
    if settingsPanel then settingsPanel:Destroy() end
    
    settingsPanel = Instance.new("Frame")
    settingsPanel.Parent = gui
    settingsPanel.Size = UDim2.new(0, 250, 0, 120)
    settingsPanel.Position = UDim2.new(1, -270, 0, 50)
    settingsPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    settingsPanel.BackgroundTransparency = 0.1
    settingsPanel.BorderSizePixel = 0
    settingsPanel.Visible = false
    Instance.new("UICorner", settingsPanel).CornerRadius = UDim.new(0, 8)
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Parent = settingsPanel
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "⚙️ НАСТРОЙКИ"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    
    -- Прозрачность фона
    local transLabel = Instance.new("TextLabel")
    transLabel.Parent = settingsPanel
    transLabel.Position = UDim2.new(0, 10, 0, 30)
    transLabel.Size = UDim2.new(0, 100, 0, 20)
    transLabel.BackgroundTransparency = 1
    transLabel.Text = "Прозрачность:"
    transLabel.Font = Enum.Font.Gotham
    transLabel.TextSize = 12
    transLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    local transValue = Instance.new("TextLabel")
    transValue.Parent = settingsPanel
    transValue.Position = UDim2.new(0, 120, 0, 30)
    transValue.Size = UDim2.new(0, 40, 0, 20)
    transValue.BackgroundTransparency = 1
    transValue.Text = tostring(math.floor(settings.bgTransparency * 100)) .. "%"
    transValue.Font = Enum.Font.Gotham
    transValue.TextSize = 12
    transValue.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    local slider = Instance.new("Frame")
    slider.Parent = settingsPanel
    slider.Position = UDim2.new(0, 10, 0, 55)
    slider.Size = UDim2.new(0, 200, 0, 4)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slider.BorderSizePixel = 0
    Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Parent = slider
    sliderKnob.Size = UDim2.new(0, 12, 0, 12)
    sliderKnob.Position = UDim2.new(settings.bgTransparency, -6, 0.5, -6)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    sliderKnob.BorderSizePixel = 0
    Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)
    
    local draggingKnob = false
    
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingKnob = true
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if draggingKnob and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = input.Position.X
            local sliderPos = slider.AbsolutePosition.X
            local newPos = math.clamp((mousePos - sliderPos) / slider.AbsoluteSize.X, 0, 1)
            settings.bgTransparency = newPos
            backgroundImage.ImageTransparency = settings.bgTransparency
            sliderKnob.Position = UDim2.new(settings.bgTransparency, -6, 0.5, -6)
            transValue.Text = tostring(math.floor(settings.bgTransparency * 100)) .. "%"
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingKnob = false
        end
    end)
    
    -- Кнопка смены фона
    local changeBgBtn = Instance.new("TextButton")
    changeBgBtn.Parent = settingsPanel
    changeBgBtn.Position = UDim2.new(0, 10, 0, 75)
    changeBgBtn.Size = UDim2.new(0, 200, 0, 30)
    changeBgBtn.Text = "🖼️ СЛУЧАЙНЫЙ ФОН"
    changeBgBtn.Font = Enum.Font.GothamBold
    changeBgBtn.TextSize = 12
    changeBgBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    changeBgBtn.BorderSizePixel = 0
    changeBgBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", changeBgBtn).CornerRadius = UDim.new(0, 5)
    
    changeBgBtn.MouseButton1Click:Connect(function()
        if #settings.availableBGs > 0 then
            local newBG = settings.availableBGs[math.random(1, #settings.availableBGs)]
            if newBG then
                settings.currentBG = newBG
                backgroundImage.Image = settings.currentBG
            end
        end
    end)
end

-- Шестерёнка
local gearButton = Instance.new("ImageButton")
gearButton.Parent = frame
gearButton.Size = UDim2.new(0, 30, 0, 30)
gearButton.Position = UDim2.new(1, -40, 0, 5)
gearButton.BackgroundTransparency = 1
gearButton.Image = "rbxassetid://6031094678"
gearButton.ZIndex = 10

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
local frameDragStart
local frameStartPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if gearButton and gearButton.AbsolutePosition.X <= input.Position.X and gearButton.AbsolutePosition.Y <= input.Position.Y then
            return
        end
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
-- ОСТАЛЬНОЙ GUI (ЗАГОЛОВКИ, СЛОТЫ, КНОПКИ)
-- ============================================

-- ЗАГОЛОВОК
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ZXC 1000-7 made by Ghouls SSS Rank"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

-- Разделитель
local line1 = Instance.new("Frame")
line1.Parent = frame
line1.Position = UDim2.new(0, 0, 0, 35)
line1.Size = UDim2.new(1, 0, 0, 2)
line1.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
line1.BorderSizePixel = 0

-- Центральная линия
local centerLine = Instance.new("Frame")
centerLine.Parent = frame
centerLine.Position = UDim2.new(0.5, 0, 0, 40)
centerLine.Size = UDim2.new(0, 2, 1, -40)
centerLine.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
centerLine.BorderSizePixel = 0

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

-- ОБЩАЯ СУММА YOUR
local yourTotalFrame = Instance.new("Frame")
yourTotalFrame.Parent = frame
yourTotalFrame.Position = UDim2.new(0, 0, 0, 65)
yourTotalFrame.Size = UDim2.new(0.5, 0, 0, 40)
yourTotalFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
yourTotalFrame.BackgroundTransparency = 0.5
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

-- ОБЩАЯ СУММА THEIR
local theirTotalFrame = Instance.new("Frame")
theirTotalFrame.Parent = frame
theirTotalFrame.Position = UDim2.new(0.5, 0, 0, 65)
theirTotalFrame.Size = UDim2.new(0.5, 0, 0, 40)
theirTotalFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
theirTotalFrame.BackgroundTransparency = 0.4
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

-- ========== СОЗДАНИЕ СЛОТОВ ==========
-- (функция createSlot и расположение слотов остаются без изменений)
local function createSlot(parent, xPos, yPos, slotNum)
    local slotFrame = Instance.new("Frame")
    slotFrame.Parent = parent
    slotFrame.Size = UDim2.new(0, 175, 0, 140)
    slotFrame.Position = UDim2.new(0, xPos, 0, yPos)
    slotFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    slotFrame.BackgroundTransparency = 0.2
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

-- РАСПОЛОЖЕНИЕ СЛОТОВ
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
    local slot = createSlot(frame, yourPos[i].x, yourPos[i].y, i)
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
    local slot = createSlot(frame, theirPos[i].x, theirPos[i].y, i)
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
-- ТОГГЛ КНОПКА
-- ============================================
local function getRandomImage(folder)
    if not listfiles then return nil end
    local files = listfiles(folder)
    local valid = {}
    for _,file in ipairs(files) do
        local lower = string.lower(file)
        if lower:find(".png") or lower:find(".jpg") or lower:find(".jpeg") then
            table.insert(valid, file)
        end
    end
    if #valid <= 0 then return nil end
    return valid[math.random(1, #valid)]
end

local randomIconPath = getRandomImage(ICONS_FOLDER)
local iconAsset = randomIconPath and fileToAsset(randomIconPath)

local toggleButton = Instance.new("ImageButton")
toggleButton.Parent = gui
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 20, 0.5, -30)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.BackgroundTransparency = 0
toggleButton.BorderSizePixel = 0
toggleButton.Image = iconAsset or "rbxassetid://7072719338"
toggleButton.ScaleType = Enum.ScaleType.Crop
toggleButton.ZIndex = 999999
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
    local useChromaDetails = false
    
    if isChromaActive then
        local chromaName = getChromaName(name)
        if chromaName then
            realName = chromaName
            useChromaDetails = true
        end
    end
    
    local details = itemDetails[realName]
    if not details and useChromaDetails then
        details = itemDetails[name]
    end
    
    if not details then
        return "📊 Нет данных"
    end
    
    local trend = details.trend or "?"
    local stability = details.stability or "?"
    local trendIcon = (trend == "Rising" and "📈") or (trend == "Falling" and "📉") or (trend == "Stable" and "➡️") or "❓"
    local rangeStr = (details.range and details.range ~= "") and ("📊 " .. details.range) or ""
    
    local lines = {}
    table.insert(lines, string.format("%s %s | %s", trendIcon, trend, stability))
    if rangeStr ~= "" then table.insert(lines, rangeStr) end
    table.insert(lines, string.format("🔥 %s | ✨ %s", details.demand, details.rarity))
    
    return table.concat(lines, "\n")
end

-- ========== ПОДСЧЁТ ОБЩИХ СУММ ==========
local
