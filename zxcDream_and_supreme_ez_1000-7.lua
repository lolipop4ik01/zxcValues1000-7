-- ============================================
-- MM2 ULTIMATE CHECKER (FULL INFO + DREAM PETS)
-- Автообновление через loadstring
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
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- ============================================
-- ПЕРЕТАСКИВАНИЕ ГЛАВНОГО ОКНА
-- ============================================
local frameDragging = false
local frameDragStart
local frameStartPos

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
-- EXECUTOR IMAGE SYSTEM
-- ============================================

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

local function fileToAsset(path)
    if getsynasset then return getsynasset(path) end
    if getcustomasset then return getcustomasset(path) end
    return nil
end

local randomIconPath = getRandomImage(ICONS_FOLDER)
local randomBGPath = getRandomImage(BG_FOLDER)

local iconAsset = randomIconPath and fileToAsset(randomIconPath)
local bgAsset = randomBGPath and fileToAsset(randomBGPath)

-- ============================================
-- ФОН GUI (ПОЛУПРОЗРАЧНЫЙ)
-- ============================================
frame.ClipsDescendants = true

local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Parent = frame
backgroundImage.Size = UDim2.new(1, 0, 1, 0)
backgroundImage.Position = UDim2.new(0, 0, 0, 0)
backgroundImage.BackgroundTransparency = 0
backgroundImage.Image = bgAsset or "rbxassetid://9066026056"
backgroundImage.ImageTransparency = 0.3
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

-- ========== СОЗДАНИЕ СЛОТА ==========
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
-- ТОГГЛ КНОПКА (КРУГЛАЯ, БЕЗ БЕЛОЙ ПОЛОСКИ, НЕ ПРОЗРАЧНАЯ)
-- ============================================

local toggleButton = Instance.new("ImageButton")
toggleButton.Parent = gui
toggleButton.Name = "ToggleButton"

toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 20, 0.5, -30)

toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.BackgroundTransparency = 0  -- Убрана прозрачность
toggleButton.BorderSizePixel = 0

toggleButton.Image = iconAsset or "rbxassetid://7072719338"
toggleButton.ScaleType = Enum.ScaleType.Crop
toggleButton.ZIndex = 999999

Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

-- БЕЛАЯ ПОЛОСКА УБРАНА (UIStroke НЕ ДОБАВЛЯЕМ)

-- ========== ОТКРЫТИЕ / ЗАКРЫТИЕ ==========
local opened = true

toggleButton.MouseButton1Click:Connect(function()
    opened = not opened
    frame.Visible = opened
end)

-- ========== ПЕРЕТАСКИВАНИЕ КНОПКИ ==========
local toggleDragging = false
local toggleDragStart
local toggleStartPos

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

-- ========== ОБНОВЛЕНИЕ GUI ==========
local function updateAll()
    local tradeGui = LP.PlayerGui:FindFirstChild("TradeGUI")
    if not tradeGui then return end
    
    local yourContainer = tradeGui.Container.Trade.YourOffer.Container
    local theirContainer = tradeGui.Container.Trade.TheirOffer.Container
    
    for i = 1, 4 do
        local slot = yourContainer:FindFirstChild("NewItem"..i)
        local slotUI = yourSlots[i]
        
        if slot then
            local name = getSlotItemName(slot)
            if name then
                local amount = getSlotAmount(slot)
                local supremePrice, dreamPrice
                
                if yourChromaMode[i] then
                    local chromaName = getChromaName(name)
                    if chromaName then
                        supremePrice = getPrice(chromaName)
                        dreamPrice = getDreamPrice(chromaName)
                    else
                        supremePrice = getPrice(name)
                        dreamPrice = getDreamPrice(name)
                    end
                else
                    supremePrice = getPrice(name)
                    dreamPrice = getDreamPrice(name)
                end
                
                local totalSupreme = math.floor(supremePrice * amount)
                local totalDream = math.floor(dreamPrice * amount)
                
                local shortName = name
                if #shortName > 14 then shortName = shortName:sub(1, 12) .. ".." end
                
                slotUI.nameLabel.Text = shortName
                if totalDream > 0 then
                    slotUI.priceLabel.Text = totalSupreme .. " V\n" .. totalDream .. " ₽"
                else
                    slotUI.priceLabel.Text = totalSupreme .. " V"
                end
                slotUI.detailsLabel.Text = formatDetails(name, yourChromaMode[i])
            else
                slotUI.nameLabel.Text = "Пусто"
                slotUI.priceLabel.Text = "0 V"
                slotUI.detailsLabel.Text = "❌ Нет предмета"
            end
        else
            slotUI.nameLabel.Text = "Пусто"
            slotUI.priceLabel.Text = "0 V"
            slotUI.detailsLabel.Text = "❌ Нет предмета"
        end
    end
    
    for i = 1, 4 do
        local slot = theirContainer:FindFirstChild("NewItem"..i)
        local slotUI = theirSlots[i]
        
        if slot then
            local name = getSlotItemName(slot)
            if name then
                local amount = getSlotAmount(slot)
                local supremePrice, dreamPrice
                
                if theirChromaMode[i] then
                    local chromaName = getChromaName(name)
                    if chromaName then
                        supremePrice = getPrice(chromaName)
                        dreamPrice = getDreamPrice(chromaName)
                    else
                        supremePrice = getPrice(name)
                        dreamPrice = getDreamPrice(name)
                    end
                else
                    supremePrice = getPrice(name)
                    dreamPrice = getDreamPrice(name)
                end
                
                local totalSupreme = math.floor(supremePrice * amount)
                local totalDream = math.floor(dreamPrice * amount)
                
                local shortName = name
                if #shortName > 14 then shortName = shortName:sub(1, 12) .. ".." end
                
                slotUI.nameLabel.Text = shortName
                if totalDream > 0 then
                    slotUI.priceLabel.Text = totalSupreme .. " V\n" .. totalDream .. " ₽"
                else
                    slotUI.priceLabel.Text = totalSupreme .. " V"
                end
                slotUI.detailsLabel.Text = formatDetails(name, theirChromaMode[i])
            else
                slotUI.nameLabel.Text = "Пусто"
                slotUI.priceLabel.Text = "0 V"
                slotUI.detailsLabel.Text = "❌ Нет предмета"
            end
        else
            slotUI.nameLabel.Text = "Пусто"
            slotUI.priceLabel.Text = "0 V"
            slotUI.detailsLabel.Text = "❌ Нет предмета"
        end
    end
    
    local yourTotalV, yourTotalRub = calculateTotal("YourOffer", YOUR_MAX_SLOT, yourChromaMode)
    local theirTotalV, theirTotalRub = calculateTotal("TheirOffer", THEIR_MAX_SLOT, theirChromaMode)
    
    yourTotalLabel.Text = "TOTAL: " .. math.floor(yourTotalV) .. " V"
    theirTotalLabel.Text = "TOTAL: " .. math.floor(theirTotalV) .. " V"
    
    if yourTotalRub > 0 then
        yourTotalDreamLabel.Text = "💸 " .. math.floor(yourTotalRub) .. " ₽"
    else
        yourTotalDreamLabel.Text = ""
    end
    
    if theirTotalRub > 0 then
        theirTotalDreamLabel.Text = "💸 " .. math.floor(theirTotalRub) .. " ₽"
    else
        theirTotalDreamLabel.Text = ""
    end
    
    if yourTotalV > theirTotalV then
        yourTotalLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        theirTotalLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    elseif theirTotalV > yourTotalV then
        yourTotalLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        theirTotalLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        yourTotalLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        theirTotalLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end

-- ========== ЗАПУСК ==========
loadDataFromGitHub()

while task.wait(0.3) do
    pcall(updateAll)
end
