-- ============================================
-- MM2 ULTIMATE CHECKER (ПОЛНАЯ ВЕРСИЯ С НАСТРОЙКАМИ)
-- ============================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- ========== 1. ОБЩЕЕ СОСТОЯНИЕ ==========
local UI_STATE = {
    mainOpen = true,
    settingsOpen = false
}

-- ========== 2. НАСТРОЙКИ ПРОЗРАЧНОСТИ ==========
local Settings = {
    bgTrans = 0.55,
    mainTrans = 0.1
}

-- ========== 3. ТВОИ ПЕРЕМЕННЫЕ (ОРИГИНАЛ) ==========
local RAW_JSON_URL = "https://raw.githubusercontent.com/lolipop4ik01/zxcValues1000-7/refs/heads/main/prices.json"
local prices = {}
local dreampets = {}
local itemDetails = {}

local yourChromaMode = { false, false, false, false }
local theirChromaMode = { false, false, false, false }
local YOUR_MAX_SLOT = 4
local THEIR_MAX_SLOT = 4

-- ========== 4. ТВОЯ ЗАГРУЗКА ДАННЫХ ==========
local function loadDataFromGitHub()
    local success, result = pcall(function()
        return game:HttpGet(RAW_JSON_URL)
    end)
    if not success then
        warn("[MM2Checker] Ошибка загрузки: " .. tostring(result))
        return false
    end

    local data = HttpService:JSONDecode(result)
    
    for category, items in pairs(data) do
        for itemName, info in pairs(items) do
            local valueNum = tonumber(info.value) or 0
            if valueNum > 0 then prices[itemName] = valueNum end
            
            local dpNum = tonumber(info.dreampets_price) or 0
            if dpNum > 0 then dreampets[itemName] = dpNum end
            
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

-- ========== 5. ТВОЯ ЛОГИКА CHROMA ==========
local function normalizeChromaName(name)
    if name:match("^Chroma ") then
        local rest = name:sub(8)
        local cName = "C. " .. rest
        if prices[cName] or dreampets[cName] then return cName end
    end
    if name:match("^C%. ") then
        local rest = name:sub(4)
        local chromaName = "Chroma " .. rest
        if prices[chromaName] or dreampets[chromaName] then return chromaName end
    end
    return name
end

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

local function getPrice(name) return prices[normalizeChromaName(name)] or 0 end
local function getDreamPrice(name) return dreampets[normalizeChromaName(name)] or 0 end

-- ========== 6. СИСТЕМА ПАПОК (ТВОИ Icons_ZXC / Backgrounds_Ghoul) ==========
local EXECUTOR_FOLDER = "1000-7_Assets"
local ICONS_FOLDER = EXECUTOR_FOLDER .. "/Icons_ZXC"
local BG_FOLDER = EXECUTOR_FOLDER .. "/Backgrounds_Ghoul"

if makefolder and isfolder then
    pcall(function()
        if not isfolder(EXECUTOR_FOLDER) then makefolder(EXECUTOR_FOLDER) end
        if not isfolder(ICONS_FOLDER) then makefolder(ICONS_FOLDER) end
        if not isfolder(BG_FOLDER) then makefolder(BG_FOLDER) end
    end)
end

local function getRandomLocalImage(folder)
    if not listfiles then return nil end
    local success, files = pcall(function() return listfiles(folder) end)
    if not success or type(files) ~= "table" then return nil end
    local valid = {}
    for _, file in ipairs(files) do
        local lower = string.lower(file)
        if lower:find(".png") or lower:find(".jpg") or lower:find(".jpeg") then
            table.insert(valid, file)
        end
    end
    return (#valid > 0) and valid[math.random(1, #valid)] or nil
end

local function fileToAsset(path)
    if not path then return nil end
    if getcustomasset then return getcustomasset(path) end
    if getsynasset then return getsynasset(path) end
    return nil
end

local iconAsset = fileToAsset(getRandomLocalImage(ICONS_FOLDER))
local bgAsset = fileToAsset(getRandomLocalImage(BG_FOLDER))

-- ========== 7. ОСНОВНОЙ GUI ==========
pcall(function() game.CoreGui.MM2VALUEGUI:Destroy() end)
local gui = Instance.new("ScreenGui")
gui.Name = "MM2VALUEGUI"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 800, 0, 450)
frame.Position = UDim2.new(0.5, -400, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = Settings.mainTrans
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- ФОН ИЗ ПАПКИ Backgrounds_Ghoul
local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Parent = frame
backgroundImage.Size = UDim2.new(1, 0, 1, 0)
backgroundImage.BackgroundTransparency = 1
backgroundImage.Image = bgAsset or "rbxassetid://9066026056"
backgroundImage.ImageTransparency = Settings.bgTrans
backgroundImage.ScaleType = Enum.ScaleType.Crop
backgroundImage.ZIndex = -999

-- ЗАГОЛОВОК И РАЗДЕЛИТЕЛИ (ТВОЙ СТИЛЬ)
local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ZXC 1000-7 made by Ghouls SSS Rank"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

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

local yourHeader = Instance.new("TextLabel")
yourHeader.Parent = frame
yourHeader.Position = UDim2.new(0, 0, 0, 42)
yourHeader.Size = UDim2.new(0.5, 0, 0, 22)
yourHeader.BackgroundTransparency = 1
yourHeader.Text = "YOUR SHIT"
yourHeader.Font = Enum.Font.GothamBold
yourHeader.TextColor3 = Color3.fromRGB(255, 200, 100)
yourHeader.TextScaled = true

local theirHeader = Instance.new("TextLabel")
theirHeader.Parent = frame
theirHeader.Position = UDim2.new(0.5, 0, 0, 42)
theirHeader.Size = UDim2.new(0.5, 0, 0, 22)
theirHeader.BackgroundTransparency = 1
theirHeader.Text = "THEIR SHIT"
theirHeader.Font = Enum.Font.GothamBold
theirHeader.TextColor3 = Color3.fromRGB(100, 200, 255)
theirHeader.TextScaled = true

-- ОБЩИЕ СУММЫ
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

-- ========== 8. ТВОИ СЛОТЫ (2x2) ==========
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

-- ========== 9. ГЛАВНАЯ КНОПКА (КРУГЛАЯ) ==========
local toggleButton = Instance.new("ImageButton")
toggleButton.Parent = gui
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 20, 0.5, -30)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.BackgroundTransparency = 0
toggleButton.BorderSizePixel = 0
toggleButton.Image = iconAsset or "rbxassetid://7072719338"
toggleButton.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

toggleButton.MouseButton1Click:Connect(function()
    UI_STATE.mainOpen = not UI_STATE.mainOpen
    frame.Visible = UI_STATE.mainOpen
    if not UI_STATE.mainOpen then
        UI_STATE.settingsOpen = false
        settingsFrame.Visible = false
    end
end)

-- ========== 10. ОКНО НАСТРОЕК (ПЕРЕТАСКИВАЕТСЯ) ==========
local settingsFrame = Instance.new("Frame")
settingsFrame.Parent = gui
settingsFrame.Size = UDim2.new(0, 260, 0, 200)
settingsFrame.Position = UDim2.new(0, 140, 0.5, -100)
settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
settingsFrame.BackgroundTransparency = 0.1
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false
settingsFrame.ZIndex = 100
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 10)

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Parent = settingsFrame
settingsTitle.Size = UDim2.new(1, 0, 0, 30)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "⚙️ НАСТРОЙКИ"
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextColor3 = Color3.new(1, 1, 1)
settingsTitle.TextScaled = true

-- Функция создания ползунка (Slider)
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
    label.Text = name .. ": " .. defaultVal
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local bar = Instance.new("Frame")
    bar.Parent = holder
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 0, 25)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local knob = Instance.new("Frame")
    knob.Parent = bar
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -6, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
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

createSlider("Прозрачность фона", 40, 0, 1, Settings.bgTrans, function(v)
    Settings.bgTrans = v
    backgroundImage.ImageTransparency = v
end)

createSlider("Прозрачность меню", 95, 0, 1, Settings.mainTrans, function(v)
    Settings.mainTrans = v
    frame.BackgroundTransparency = v
end)

-- КНОПКА ОТКРЫТИЯ НАСТРОЕК (ШЕСТЕРЁНКА)
local gearButton = Instance.new("ImageButton")
gearButton.Parent = frame
gearButton.Size = UDim2.new(0, 32, 0, 32)
gearButton.Position = UDim2.new(1, -40, 0, 5)
gearButton.BackgroundTransparency = 1
gearButton.Image = "rbxassetid://6031094678"

gearButton.MouseButton1Click:Connect(function()
    UI_STATE.settingsOpen = not UI_STATE.settingsOpen
    settingsFrame.Visible = UI_STATE.settingsOpen
end)

-- ПЕРЕТАСКИВАНИЕ ОКНА НАСТРОЕК (ЗА ЗАГОЛОВОК)
local dragSettings = false
local settingsDragStart, settingsStartPos

settingsTitle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragSettings = true
        settingsDragStart = input.Position
        settingsStartPos = settingsFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragSettings = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragSettings and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - settingsDragStart
        settingsFrame.Position = UDim2.new(
            settingsStartPos.X.Scale,
            settingsStartPos.X.Offset + delta.X,
            settingsStartPos.Y.Scale,
            settingsStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ========== 11. ПЕРЕТАСКИВАНИЕ ГЛАВНОГО ОКНА И КНОПКИ ==========
local frameDrag = false
local frameDragStart, frameStartPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        frameDrag = true
        frameDragStart = input.Position
        frameStartPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                frameDrag = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if frameDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - frameDragStart
        frame.Position = UDim2.new(
            frameStartPos.X.Scale,
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale,
            frameStartPos.Y.Offset + delta.Y
        )
    end
end)

local buttonDrag = false
local buttonDragStart, buttonStartPos

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        buttonDrag = true
        buttonDragStart = input.Position
        buttonStartPos = toggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                buttonDrag = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if buttonDrag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - buttonDragStart
        toggleButton.Position = UDim2.new(
            buttonStartPos.X.Scale,
            buttonStartPos.X.Offset + delta.X,
            buttonStartPos.Y.Scale,
            buttonStartPos.Y.Offset + delta.Y
        )
    end
end)

-- ========== 12. ТВОИ ФУНКЦИИ ТРЕЙДА ==========
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
    
    local details = itemDetails[realName]
    if not details and isChromaActive then details = itemDetails[name] end
    if not details then return "📊 Нет данных" end
    
    local trendIcon = (details.trend == "Rising" and "📈") or (details.trend == "Falling" and "📉") or (details.trend == "Stable" and "➡️") or "❓"
    local rangeStr = (details.range and details.range ~= "") and ("📊 " .. details.range) or ""
    
    local lines = {string.format("%s %s | %s", trendIcon, details.trend, details.stability)}
    if rangeStr ~= "" then table.insert(lines, rangeStr) end
    table.insert(lines, string.format("🔥 %s | ✨ %s", details.demand, details.rarity))
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
                    local chromaName = getChromaName(name)
                    if chromaName then
                        priceV = getPrice(chromaName)
                        priceRub = getDreamPrice(chromaName)
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
        local slot = yourContainer:FindFirstChild("New
