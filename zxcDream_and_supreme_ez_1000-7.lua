-- ============================================
-- MM2 ULTIMATE CHECKER (FULL INFO + LOCAL ASSETS)
-- ============================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- ========== 1) ОБЩЕЕ СОСТОЯНИЕ (UI STATE) ==========
local UI_STATE = {
    open = true,
    settings = false
}

local Settings_Data = {
    BackgroundTransparency = 0.55,
    MainTransparency = 0.1,
    IconTransparency = 0,
}

-- ========== НАСТРОЙКИ ДАННЫХ ==========
local RAW_JSON_URL = "https://raw.githubusercontent.com/lolipop4ik01/zxcValues1000-7/refs/heads/main/prices.json"
local prices = {}
local dreampets = {}
local itemDetails = {}

local yourChromaMode = { false, false, false, false }
local theirChromaMode = { false, false, false, false }
local YOUR_MAX_SLOT = 4
local THEIR_MAX_SLOT = 4

-- ========== 2) РАБОТА С ФАЙЛАМИ ЭКЗЕКУТОРА (LOCAL ASSETS) ==========
local EXECUTOR_FOLDER = "1000-7_Assets"
local ICONS_FOLDER = EXECUTOR_FOLDER .. "/Icons"
local BG_FOLDER = EXECUTOR_FOLDER .. "/Backgrounds"

-- Создаем папки в workspace экзекутора
if makefolder and isfolder then
    pcall(function()
        if not isfolder(EXECUTOR_FOLDER) then makefolder(EXECUTOR_FOLDER) end
        if not isfolder(ICONS_FOLDER) then makefolder(ICONS_FOLDER) end
        if not isfolder(BG_FOLDER) then makefolder(BG_FOLDER) end
    end)
end

-- Функция для получения случайной картинки
local function getRandomLocalImage(folderPath)
    if not listfiles then return nil end
    local success, files = pcall(function() return listfiles(folderPath) end)
    if not success or type(files) ~= "table" then return nil end

    local validImages = {}
    for _, file in ipairs(files) do
        local lowerFile = string.lower(file)
        if lowerFile:match("%.png$") or lowerFile:match("%.jpg$") or lowerFile:match("%.jpeg$") then
            table.insert(validImages, file)
        end
    end

    if #validImages > 0 then
        return validImages[math.random(1, #validImages)]
    end
    return nil
end

-- Превращаем путь в ассет Роблокса
local function getAsset(path)
    if not path then return nil end
    if getcustomasset then return getcustomasset(path) end
    if getsynasset then return getsynasset(path) end
    return nil
end

local randomIconPath = getRandomLocalImage(ICONS_FOLDER)
local randomBGPath = getRandomLocalImage(BG_FOLDER)

local customIconAsset = getAsset(randomIconPath)
local customBGAsset = getAsset(randomBGPath)

-- ========== ЗАГРУЗКА ЦЕН ИЗ GITHUB ==========
local function loadDataFromGitHub()
    local success, result = pcall(function() return game:HttpGet(RAW_JSON_URL) end)
    if not success then return false end

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
    return true
end

-- ========== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ CHROMA ==========
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

-- ========== 3) GUI CORE ==========
pcall(function() game.CoreGui.MM2VALUEGUI:Destroy() end)

local gui = Instance.new("ScreenGui")
gui.Name = "MM2VALUEGUI"
gui.Parent = game.CoreGui

-- ОСНОВНОЙ ФРЕЙМ
local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.new(0, 800, 0, 450)
frame.Position = UDim2.new(0.5, -400, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = Settings_Data.MainTransparency
frame.BorderSizePixel = 0
frame.Visible = UI_STATE.open
frame.ClipsDescendants = true -- Чтобы фон не вылезал за скругления
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- ФОНОВАЯ КАРТИНКА ИЗ ЭКЗЕКУТОРА
local bgImageLabel = Instance.new("ImageLabel")
bgImageLabel.Parent = frame
bgImageLabel.Size = UDim2.new(1, 0, 1, 0)
bgImageLabel.BackgroundTransparency = 1
bgImageLabel.Image = customBGAsset or "rbxassetid://9066026056" -- Ставим локальную или стандартную
bgImageLabel.ImageTransparency = Settings_Data.BackgroundTransparency
bgImageLabel.ScaleType = Enum.ScaleType.Crop
bgImageLabel.ZIndex = -1

-- ОКНО НАСТРОЕК (ЗАКРЕПЛЕНО НАМЕРТВО)
local settingsFrame = Instance.new("Frame")
settingsFrame.Parent = gui
settingsFrame.Size = UDim2.new(0, 260, 0, 220)
settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
settingsFrame.BackgroundTransparency = 0.1
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = UI_STATE.settings
settingsFrame.Active = false
settingsFrame.Draggable = false
settingsFrame.AnchorPoint = Vector2.new(0, 0)
settingsFrame.Position = UDim2.new(0, 140, 0.5, -110)
settingsFrame.ZIndex = 10
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 10)

-- ========== 4) КНОПКИ УПРАВЛЕНИЯ (ТУМБЛЕР И НАСТРОЙКИ) ==========

-- ГЛАВНАЯ КНОПКА (ИКНОКА)
local toggleButton = Instance.new("ImageButton")
toggleButton.Parent = gui
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 20, 0.5, -30)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.BorderSizePixel = 0
toggleButton.Image = customIconAsset or "rbxassetid://7072719338" -- Локальная или стандартная
toggleButton.ScaleType = Enum.ScaleType.Crop
toggleButton.ZIndex = 999
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", toggleButton)
stroke.Thickness = 2
stroke.Color = Color3.new(1, 1, 1)

-- ЛОГИКА ТУМБЛЕРА
toggleButton.MouseButton1Click:Connect(function()
    UI_STATE.open = not UI_STATE.open
    frame.Visible = UI_STATE.open
    
    -- Синхронизация: закрываем окно настроек, если закрыто главное меню
    if not UI_STATE.open then
        UI_STATE.settings = false
        settingsFrame.Visible = false
    end
end)

-- КНОПКА НАСТРОЕК (ШЕСТЕРЕНКА ВНУТРИ FRAME)
local settingsButton = Instance.new("ImageButton")
settingsButton.Parent = frame
settingsButton.Size = UDim2.new(0, 25, 0, 25)
settingsButton.Position = UDim2.new(1, -35, 0, 5)
settingsButton.BackgroundTransparency = 1
settingsButton.Image = "rbxassetid://6031280882"
settingsButton.ZIndex = 5

settingsButton.MouseButton1Click:Connect(function()
    UI_STATE.settings = not UI_STATE.settings
    settingsFrame.Visible = UI_STATE.settings
end)

-- ========== 5) DRAGGING (ГЛАВНОЕ ОКНО И ТУМБЛЕР) ==========
local function makeDraggable(obj)
    local dragging = false
    local dragStart, startPos

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = obj.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(frame)
makeDraggable(toggleButton)

-- ========== 6) ПОЛЗУНКИ НАСТРОЕК ==========
local function createSlider(name, posY, min, max, default, callback)
    local holder = Instance.new("Frame", settingsFrame)
    holder.Size = UDim2.new(1, -20, 0, 40)
    holder.Position = UDim2.new(0, 10, 0, posY)
    holder.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.new(1, 0, 0, 15)
    label.Text = name .. " : " .. default
    label.TextColor3 = Color3.new(1, 1, 1)
    label.BackgroundTransparency = 1

    local bar = Instance.new("Frame", holder)
    bar.Size = UDim2.new(1, 0, 0, 5)
    bar.Position = UDim2.new(0, 0, 0, 20)
    bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)

    local function update(input)
        local per = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(per, 0, 1, 0)
        local val = math.floor((min + (max-min)*per)*100)/100
        label.Text = name .. " : " .. val
        callback(val)
    end

    local drag = false
    bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = true update(input) end end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
    UIS.InputChanged:Connect(function(input) if drag and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
end

local sTitle = Instance.new("TextLabel", settingsFrame)
sTitle.Size = UDim2.new(1,0,0,30)
sTitle.BackgroundTransparency = 1
sTitle.Text = "Настройки"
sTitle.Font = Enum.Font.GothamBold
sTitle.TextColor3 = Color3.new(1,1,1)

createSlider("Фон (Прозрачность)", 40, 0, 1, Settings_Data.BackgroundTransparency, function(v) bgImageLabel.ImageTransparency = v end)
createSlider("Меню (Прозрачность)", 90, 0, 1, Settings_Data.MainTransparency, function(v) frame.BackgroundTransparency = v end)
createSlider("Иконка (Прозрачность)", 140, 0, 1, Settings_Data.IconTransparency, function(v) toggleButton.BackgroundTransparency = v end)

-- ========== 7) UI ЭЛЕМЕНТЫ ТРЕЙДА ==========
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "ZXC 1000-7 made by Ghouls SSS Rank"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local line1 = Instance.new("Frame", frame)
line1.Position = UDim2.new(0,0,0,35)
line1.Size = UDim2.new(1,0,0,2)
line1.BackgroundColor3 = Color3.fromRGB(80,80,80)
line1.BorderSizePixel = 0

local centerLine = Instance.new("Frame", frame)
centerLine.Position = UDim2.new(0.5,0,0,40)
centerLine.Size = UDim2.new(0,2,1,-40)
centerLine.BackgroundColor3 = Color3.fromRGB(80,80,80)
centerLine.BorderSizePixel = 0

local yourHeader = Instance.new("TextLabel", frame)
yourHeader.Position = UDim2.new(0,0,0,42)
yourHeader.Size = UDim2.new(0.5,0,0,22)
yourHeader.BackgroundTransparency = 1
yourHeader.Text = "YOUR SHIT"
yourHeader.Font = Enum.Font.GothamBold
yourHeader.TextColor3 = Color3.fromRGB(255,200,100)
yourHeader.TextScaled = true

local theirHeader = Instance.new("TextLabel", frame)
theirHeader.Position = UDim2.new(0.5,0,0,42)
theirHeader.Size = UDim2.new(0.5,0,0,22)
theirHeader.BackgroundTransparency = 1
theirHeader.Text = "THEIR SHIT"
theirHeader.Font = Enum.Font.GothamBold
theirHeader.TextColor3 = Color3.fromRGB(100,200,255)
theirHeader.TextScaled = true

local yourTotalFrame = Instance.new("Frame", frame)
yourTotalFrame.Position = UDim2.new(0,0,0,65)
yourTotalFrame.Size = UDim2.new(0.5,0,0,40)
yourTotalFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
yourTotalFrame.BackgroundTransparency = 0.3
yourTotalFrame.BorderSizePixel = 0
Instance.new("UICorner", yourTotalFrame).CornerRadius = UDim.new(0, 5)

local yourTotalLabel = Instance.new("TextLabel", yourTotalFrame)
yourTotalLabel.Size = UDim2.new(1,0,0.5,0)
yourTotalLabel.BackgroundTransparency = 1
yourTotalLabel.Text = "TOTAL: 0 V"
yourTotalLabel.Font = Enum.Font.GothamBold
yourTotalLabel.TextScaled = true
yourTotalLabel.TextColor3 = Color3.fromRGB(180,180,180)

local yourTotalDreamLabel = Instance.new("TextLabel", yourTotalFrame)
yourTotalDreamLabel.Size = UDim2.new(1,0,0.5,0)
yourTotalDreamLabel.Position = UDim2.new(0,0,0.5,0)
yourTotalDreamLabel.BackgroundTransparency = 1
yourTotalDreamLabel.Text = ""
yourTotalDreamLabel.Font = Enum.Font.Gotham
yourTotalDreamLabel.TextSize = 12
yourTotalDreamLabel.TextColor3 = Color3.fromRGB(150,150,150)

local theirTotalFrame = Instance.new("Frame", frame)
theirTotalFrame.Position = UDim2.new(0.5,0,0,65)
theirTotalFrame.Size = UDim2.new(0.5,0,0,40)
theirTotalFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
theirTotalFrame.BackgroundTransparency = 0.3
theirTotalFrame.BorderSizePixel = 0
Instance.new("UICorner", theirTotalFrame).CornerRadius = UDim.new(0, 5)

local theirTotalLabel = Instance.new("TextLabel", theirTotalFrame)
theirTotalLabel.Size = UDim2.new(1,0,0.5,0)
theirTotalLabel.BackgroundTransparency = 1
theirTotalLabel.Text = "TOTAL: 0 V"
theirTotalLabel.Font = Enum.Font.GothamBold
theirTotalLabel.TextScaled = true
theirTotalLabel.TextColor3 = Color3.fromRGB(180,180,180)

local theirTotalDreamLabel = Instance.new("TextLabel", theirTotalFrame)
theirTotalDreamLabel.Size = UDim2.new(1,0,0.5,0)
theirTotalDreamLabel.Position = UDim2.new(0,0,0.5,0)
theirTotalDreamLabel.BackgroundTransparency = 1
theirTotalDreamLabel.Text = ""
theirTotalDreamLabel.Font = Enum.Font.Gotham
theirTotalDreamLabel.TextSize = 12
theirTotalDreamLabel.TextColor3 = Color3.fromRGB(150,150,150)

local function createSlot(parent, xPos, yPos, slotNum)
    local slotFrame = Instance.new("Frame", parent)
    slotFrame.Size = UDim2.new(0, 175, 0, 140)
    slotFrame.Position = UDim2.new(0, xPos, 0, yPos)
    slotFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    slotFrame.BackgroundTransparency = 0.2
    slotFrame.BorderSizePixel = 0
    Instance.new("UICorner", slotFrame).CornerRadius = UDim.new(0, 6)
    
    local num = Instance.new("TextLabel", slotFrame)
    num.Size = UDim2.new(0, 22, 0, 18)
    num.Position = UDim2.new(0, 3, 0, 2)
    num.BackgroundTransparency = 1
    num.Text = tostring(slotNum)
    num.Font = Enum.Font.GothamBold
    num.TextSize = 12
    num.TextColor3 = Color3.fromRGB(180,180,180)
    
    local nameLabel = Instance.new("TextLabel", slotFrame)
    nameLabel.Size = UDim2.new(1,0,0,18)
    nameLabel.Position = UDim2.new(0,0,0,22)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "..."
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextColor3 = Color3.fromRGB(255,200,100)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local priceLabel = Instance.new("TextLabel", slotFrame)
    priceLabel.Size = UDim2.new(1,0,0,28)
    priceLabel.Position = UDim2.new(0,0,0,44)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Text = "0 V"
    priceLabel.Font = Enum.Font.GothamBold
    priceLabel.TextSize = 11
    priceLabel.TextColor3 = Color3.fromRGB(100,200,255)
    priceLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local detailsLabel = Instance.new("TextLabel", slotFrame)
    detailsLabel.Size = UDim2.new(1,0,0,58)
    detailsLabel.Position = UDim2.new(0,0,0,76)
    detailsLabel.BackgroundTransparency = 1
    detailsLabel.Text = ""
    detailsLabel.Font = Enum.Font.Gotham
    detailsLabel.TextSize = 9
    detailsLabel.TextColor3 = Color3.fromRGB(160,160,160)
    detailsLabel.TextWrapped = true
    detailsLabel.TextXAlignment = Enum.TextXAlignment.Center
    
    local selectBtn = Instance.new("TextButton", slotFrame)
    selectBtn.Size = UDim2.new(1,0,1,0)
    selectBtn.BackgroundTransparency = 1
    selectBtn.Text = ""
    
    local chromaBtn = Instance.new("TextButton", slotFrame)
    chromaBtn.Size = UDim2.new(0, 22, 0, 22)
    chromaBtn.Position = UDim2.new(1, -26, 1, -24)
    chromaBtn.Text = "C"
    chromaBtn.Font = Enum.Font.GothamBold
    chromaBtn.TextSize = 12
    chromaBtn.BorderSizePixel = 0
    chromaBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    chromaBtn.TextColor3 = Color3.fromRGB(150,150,150)
    Instance.new("UICorner", chromaBtn).CornerRadius = UDim.new(1,0)
    
    return { frame = slotFrame, nameLabel = nameLabel, priceLabel = priceLabel, detailsLabel = detailsLabel, selectBtn = selectBtn, chromaBtn = chromaBtn }
end

local yourSlots, theirSlots = {}, {}
local yourPos = { {x=15, y=115}, {x=200, y=115}, {x=15, y=265}, {x=200, y=265} }
local theirPos = { {x=410, y=115}, {x=595, y=115}, {x=410, y=265}, {x=595, y=265} }

for i = 1, 4 do
    yourSlots[i] = createSlot(frame, yourPos[i].x, yourPos[i].y, i)
    yourSlots[i].chromaBtn.MouseButton1Click:Connect(function()
        yourChromaMode[i] = not yourChromaMode[i]
        yourSlots[i].chromaBtn.BackgroundColor3 = yourChromaMode[i] and Color3.fromRGB(150,50,200) or Color3.fromRGB(40,40,40)
        yourSlots[i].chromaBtn.TextColor3 = yourChromaMode[i] and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
    end)
    yourSlots[i].selectBtn.MouseButton1Click:Connect(function()
        YOUR_MAX_SLOT = i
        for j = 1, 4 do yourSlots[j].frame.BackgroundColor3 = (j == i) and Color3.fromRGB(40,60,90) or Color3.fromRGB(25,25,25) end
    end)
    
    theirSlots[i] = createSlot(frame, theirPos[i].x, theirPos[i].y, i)
    theirSlots[i].chromaBtn.MouseButton1Click:Connect(function()
        theirChromaMode[i] = not theirChromaMode[i]
        theirSlots[i].chromaBtn.BackgroundColor3 = theirChromaMode[i] and Color3.fromRGB(150,50,200) or Color3.fromRGB(40,40,40)
        theirSlots[i].chromaBtn.TextColor3 = theirChromaMode[i] and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
    end)
    theirSlots[i].selectBtn.MouseButton1Click:Connect(function()
        THEIR_MAX_SLOT = i
        for j = 1, 4 do theirSlots[j].frame.BackgroundColor3 = (j == i) and Color3.fromRGB(40,60,90) or Color3.fromRGB(25,25,25) end
    end)
end
yourSlots[1].frame.BackgroundColor3 = Color3.fromRGB(40,60,90)
theirSlots[1].frame.BackgroundColor3 = Color3.fromRGB(40,60,90)

-- ========== 8) ФУНКЦИИ ТРЕЙДА И ОБНОВЛЕНИЯ ==========
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
        local num = tostring(amountObj.Text):match("%d+")
        if num then return tonumber(num) end
    end
    return 1
end

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
    if not details and useChromaDetails then details = itemDetails[name] end
    if not details then return "📊 Нет данных" end
    
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

local function calculateTotal(sideName, maxSlot, chromaTable)
    local tradeGui = LP.PlayerGui:FindFirstChild("TradeGUI")
    if not tradeGui then return 0, 0 end
    local container = tradeGui.Container.Trade[sideName].Container
    if not container then return 0, 0 end
    
    local totalV, totalRub = 0, 0
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
                        priceV = getPrice(chromaName); priceRub = getDreamPrice(chromaName)
                    else
                        priceV = getPrice(name); priceRub = getDreamPrice(name)
                    end
                else
                    priceV = getPrice(name); priceRub = getDreamPrice(name)
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
    
    local function updateSlots(container, slotsUI, maxSlot, chromaTable)
        for i = 1, 4 do
            local slot = container:FindFirstChild("NewItem"..i)
            local slotUI = slotsUI[i]
            if slot then
                local name = getSlotItemName(slot)
                if name then
                    local amount = getSlotAmount(slot)
                    local supremePrice, dreamPrice
                    if chromaTable[i] then
                        local chromaName = getChromaName(name)
                        if chromaName then
                            supremePrice = getPrice(chromaName); dreamPrice = getDreamPrice(chromaName)
                        else
                            supremePrice = getPrice(name); dreamPrice = getDreamPrice(name)
                        end
                    else
                        supremePrice = getPrice(name); dreamPrice = getDreamPrice(name)
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
                    slotUI.detailsLabel.Text = formatDetails(name, chromaTable[i])
                else
                    slotUI.nameLabel.Text = "Пусто"; slotUI.priceLabel.Text = "0 V"; slotUI.detailsLabel.Text = "❌ Нет предмета"
                end
            else
                slotUI.nameLabel.Text = "Пусто"; slotUI.priceLabel.Text = "0 V"; slotUI.detailsLabel.Text = "❌ Нет предмета"
            end
        end
    end
    
    updateSlots(yourContainer, yourSlots, YOUR_MAX_SLOT, yourChromaMode)
    updateSlots(theirContainer, theirSlots, THEIR_MAX_SLOT, theirChromaMode)
    
    local yourTotalV, yourTotalRub = calculateTotal("YourOffer", YOUR_MAX_SLOT, yourChromaMode)
    local theirTotalV, theirTotalRub = calculateTotal("TheirOffer", THEIR_MAX_SLOT, theirChromaMode)
    
    yourTotalLabel.Text = "TOTAL: " .. math.floor(yourTotalV) .. " V"
    theirTotalLabel.Text = "TOTAL: " .. math.floor(theirTotalV) .. " V"
    
    yourTotalDreamLabel.Text = yourTotalRub > 0 and ("💸 " .. math.floor(yourTotalRub) .. " ₽") or ""
    theirTotalDreamLabel.Text = theirTotalRub > 0 and ("💸 " .. math.floor(theirTotalRub) .. " ₽") or ""
    
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
    if UI_STATE.open then
        pcall(updateAll)
    end
end
