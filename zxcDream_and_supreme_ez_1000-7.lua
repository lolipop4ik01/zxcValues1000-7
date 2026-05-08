-- ============================================
-- MM2 ULTIMATE CHECKER (ZXC FULL VERSION)
-- ============================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- ========== СОСТОЯНИЕ UI ==========
local UI_STATE = {
    open = true,
    settings = false
}

local Settings_Data = {
    BackgroundTransparency = 0.55,
    MainTransparency = 0.1,
}

-- ========== ДАННЫЕ И ТРЕЙД ==========
local RAW_JSON_URL = "https://raw.githubusercontent.com/lolipop4ik01/zxcValues1000-7/refs/heads/main/prices.json"
local prices, dreampets, itemDetails = {}, {}, {}
local yourChromaMode = { false, false, false, false }
local theirChromaMode = { false, false, false, false }
local YOUR_MAX_SLOT = 4
local THEIR_MAX_SLOT = 4

-- ========== СИСТЕМА ПАПОК И КАРТИНОК ==========
local EXECUTOR_FOLDER = "1000-7_Assets"
local ICONS_FOLDER = EXECUTOR_FOLDER .. "/Icons_ZXC"
local BG_FOLDER = EXECUTOR_FOLDER .. "/Backgrounds_Ghoul"

if makefolder and isfolder then
    if not isfolder(EXECUTOR_FOLDER) then makefolder(EXECUTOR_FOLDER) end
    if not isfolder(ICONS_FOLDER) then makefolder(ICONS_FOLDER) end
    if not isfolder(BG_FOLDER) then makefolder(BG_FOLDER) end
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
    return #valid > 0 and valid[math.random(1, #valid)] or nil
end

local function fileToAsset(path)
    if not path then return nil end
    if getcustomasset then return getcustomasset(path) end
    if getsynasset then return getsynasset(path) end
    return nil
end

local iconAsset = fileToAsset(getRandomLocalImage(ICONS_FOLDER))
local bgAsset = fileToAsset(getRandomLocalImage(BG_FOLDER))

-- ========== ЗАГРУЗКА ДАННЫХ (ТВОЙ КОД) ==========
local function loadDataFromGitHub()
    local success, result = pcall(function() return game:HttpGet(RAW_JSON_URL) end)
    if not success then return false end
    local data = HttpService:JSONDecode(result)
    for category, items in pairs(data) do
        for itemName, info in pairs(items) do
            local v = tonumber(info.value) or 0
            if v > 0 then prices[itemName] = v end
            local dp = tonumber(info.dreampets_price) or 0
            if dp > 0 then dreampets[itemName] = dp end
            itemDetails[itemName] = {
                stability = info.stability or "?", trend = info.trend or "?",
                range = info.range or "", demand = tostring(info.demand or "?"),
                rarity = tostring(info.rarity or "?")
            }
        end
    end
    return true
end

-- ========== ВСПОМОГАТЕЛЬНАЯ ЛОГИКА (ТВОЙ КОД) ==========
local function normalizeChromaName(name)
    if name:match("^Chroma ") then
        local cName = "C. " .. name:sub(8)
        if prices[cName] or dreampets[cName] then return cName end
    end
    if name:match("^C%. ") then
        local chromaName = "Chroma " .. name:sub(4)
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

local function getChromaName(name)
    if chromaMap[name] then return chromaMap[name] end
    local c = "Chroma " .. name
    return prices[c] and c or nil
end

local function getPrice(name) return prices[normalizeChromaName(name)] or 0 end
local function getDreamPrice(name) return dreampets[normalizeChromaName(name)] or 0 end

-- ========== СОЗДАНИЕ GUI ==========
pcall(function() game.CoreGui.MM2VALUEGUI:Destroy() end)
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MM2VALUEGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 800, 0, 450)
frame.Position = UDim2.new(0.5, -400, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = Settings_Data.MainTransparency
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local backgroundImage = Instance.new("ImageLabel", frame)
backgroundImage.Size = UDim2.new(1, 0, 1, 0)
backgroundImage.BackgroundTransparency = 1
backgroundImage.Image = bgAsset or "rbxassetid://9066026056"
backgroundImage.ImageTransparency = Settings_Data.BackgroundTransparency
backgroundImage.ScaleType = Enum.ScaleType.Crop
backgroundImage.ZIndex = -1

-- Заголовки и линии (Твой визуальный стиль)
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ZXC 1000-7 made by Ghouls SSS Rank"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true

local line1 = Instance.new("Frame", frame)
line1.Position = UDim2.new(0, 0, 0, 35)
line1.Size = UDim2.new(1, 0, 0, 2)
line1.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
line1.BorderSizePixel = 0

local centerLine = Instance.new("Frame", frame)
centerLine.Position = UDim2.new(0.5, 0, 0, 40)
centerLine.Size = UDim2.new(0, 2, 1, -40)
centerLine.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
centerLine.BorderSizePixel = 0

-- Хедеры сторон
local function createSideHeader(text, xPos, color)
    local h = Instance.new("TextLabel", frame)
    h.Position = UDim2.new(xPos, 0, 0, 42)
    h.Size = UDim2.new(0.5, 0, 0, 22)
    h.BackgroundTransparency = 1
    h.Text = text
    h.Font = Enum.Font.GothamBold
    h.TextColor3 = color
    h.TextScaled = true
    return h
end
createSideHeader("YOUR SHIT", 0, Color3.fromRGB(255, 200, 100))
createSideHeader("THEIR SHIT", 0.5, Color3.fromRGB(100, 200, 255))

-- Тоталы
local function createTotalFrame(xPos)
    local f = Instance.new("Frame", frame)
    f.Position = UDim2.new(xPos, 0, 0, 65)
    f.Size = UDim2.new(0.5, 0, 0, 40)
    f.BackgroundTransparency = 0.3
    f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 5)
    
    local tl = Instance.new("TextLabel", f)
    tl.Size = UDim2.new(1, 0, 0.5, 0)
    tl.BackgroundTransparency = 1
    tl.Text = "TOTAL: 0 V"
    tl.Font = Enum.Font.GothamBold
    tl.TextScaled = true
    tl.TextColor3 = Color3.fromRGB(180, 180, 180)
    
    local tdl = Instance.new("TextLabel", f)
    tdl.Size = UDim2.new(1, 0, 0.5, 0)
    tdl.Position = UDim2.new(0, 0, 0.5, 0)
    tdl.BackgroundTransparency = 1
    tdl.Font = Enum.Font.Gotham
    tdl.TextSize = 12
    tdl.TextColor3 = Color3.fromRGB(150, 150, 150)
    
    return tl, tdl
end

local yourTotalLabel, yourTotalDreamLabel = createTotalFrame(0)
local theirTotalLabel, theirTotalDreamLabel = createTotalFrame(0.5)

-- ========== СЛОТЫ (ТВОЯ ЛОГИКА СОЗДАНИЯ) ==========
local function createSlot(parent, xPos, yPos, slotNum)
    local slotFrame = Instance.new("Frame", parent)
    slotFrame.Size = UDim2.new(0, 175, 0, 140)
    slotFrame.Position = UDim2.new(0, xPos, 0, yPos)
    slotFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    slotFrame.BackgroundTransparency = 0.2
    Instance.new("UICorner", slotFrame).CornerRadius = UDim.new(0, 6)
    
    local num = Instance.new("TextLabel", slotFrame)
    num.Size = UDim2.new(0, 22, 0, 18)
    num.Position = UDim2.new(0, 3, 0, 2)
    num.BackgroundTransparency = 1
    num.Text = tostring(slotNum)
    num.Font = Enum.Font.GothamBold
    num.TextColor3 = Color3.fromRGB(180, 180, 180)
    
    local nameLabel = Instance.new("TextLabel", slotFrame)
    nameLabel.Size = UDim2.new(1, 0, 0, 18)
    nameLabel.Position = UDim2.new(0, 0, 0, 22)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "..."
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    local priceLabel = Instance.new("TextLabel", slotFrame)
    priceLabel.Size = UDim2.new(1, 0, 0, 28)
    priceLabel.Position = UDim2.new(0, 0, 0, 44)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Text = "0 V"
    priceLabel.Font = Enum.Font.GothamBold
    priceLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    local detailsLabel = Instance.new("TextLabel", slotFrame)
    detailsLabel.Size = UDim2.new(1, 0, 0, 58)
    detailsLabel.Position = UDim2.new(0, 0, 0, 76)
    detailsLabel.BackgroundTransparency = 1
    detailsLabel.Font = Enum.Font.Gotham
    detailsLabel.TextSize = 9
    detailsLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    detailsLabel.TextWrapped = true
    
    local selectBtn = Instance.new("TextButton", slotFrame)
    selectBtn.Size = UDim2.new(1, 0, 1, 0)
    selectBtn.BackgroundTransparency = 1
    selectBtn.Text = ""
    
    local chromaBtn = Instance.new("TextButton", slotFrame)
    chromaBtn.Size = UDim2.new(0, 22, 0, 22)
    chromaBtn.Position = UDim2.new(1, -26, 1, -24)
    chromaBtn.Text = "C"
    chromaBtn.Font = Enum.Font.GothamBold
    chromaBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Instance.new("UICorner", chromaBtn).CornerRadius = UDim.new(1, 0)
    
    return { frame = slotFrame, nameLabel = nameLabel, priceLabel = priceLabel, detailsLabel = detailsLabel, selectBtn = selectBtn, chromaBtn = chromaBtn }
end

local yourSlots, theirSlots = {}, {}
local yourPos = {{15,115}, {200,115}, {15,265}, {200,265}}
local theirPos = {{410,115}, {595,115}, {410,265}, {595,265}}

for i = 1, 4 do
    yourSlots[i] = createSlot(frame, yourPos[i][1], yourPos[i][2], i)
    yourSlots[i].chromaBtn.MouseButton1Click:Connect(function()
        yourChromaMode[i] = not yourChromaMode[i]
        yourSlots[i].chromaBtn.BackgroundColor3 = yourChromaMode[i] and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(40, 40, 40)
    end)
    yourSlots[i].selectBtn.MouseButton1Click:Connect(function()
        YOUR_MAX_SLOT = i
        for j=1,4 do yourSlots[j].frame.BackgroundColor3 = (j==i) and Color3.fromRGB(40, 60, 90) or Color3.fromRGB(25, 25, 25) end
    end)
    
    theirSlots[i] = createSlot(frame, theirPos[i][1], theirPos[i][2], i)
    theirSlots[i].chromaBtn.MouseButton1Click:Connect(function()
        theirChromaMode[i] = not theirChromaMode[i]
        theirSlots[i].chromaBtn.BackgroundColor3 = theirChromaMode[i] and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(40, 40, 40)
    end)
    theirSlots[i].selectBtn.MouseButton1Click:Connect(function()
        THEIR_MAX_SLOT = i
        for j=1,4 do theirSlots[j].frame.BackgroundColor3 = (j==i) and Color3.fromRGB(40, 60, 90) or Color3.fromRGB(25, 25, 25) end
    end)
end

-- ========== ОКНО НАСТРОЕК (ЗАКРЕПЛЕНО) ==========
local settingsFrame = Instance.new("Frame", gui)
settingsFrame.Size = UDim2.new(0, 260, 0, 150)
settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
settingsFrame.Visible = UI_STATE.settings
settingsFrame.Position = UDim2.new(0, 140, 0.5, -75)
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 10)

local setLabel = Instance.new("TextLabel", settingsFrame)
setLabel.Size = UDim2.new(1, 0, 0, 40)
setLabel.Text = "GUI SETTINGS"
setLabel.Font = Enum.Font.GothamBold
setLabel.TextColor3 = Color3.new(1, 1, 1)
setLabel.BackgroundTransparency = 1

-- ========== УПРАВЛЕНИЕ ВИДИМОСТЬЮ ==========
local toggleButton = Instance.new("ImageButton", gui)
toggleButton.Size = UDim2.new(0, 60, 0, 60)
toggleButton.Position = UDim2.new(0, 20, 0.5, -30)
toggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
toggleButton.Image = iconAsset or "rbxassetid://7072719338"
toggleButton.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1, 0)

toggleButton.MouseButton1Click:Connect(function()
    UI_STATE.open = not UI_STATE.open
    frame.Visible = UI_STATE.open
    if not UI_STATE.open then settingsFrame.Visible = false end
end)

local settingsButton = Instance.new("ImageButton", frame)
settingsButton.Size = UDim2.new(0, 25, 0, 25)
settingsButton.Position = UDim2.new(1, -35, 0, 5)
settingsButton.BackgroundTransparency = 1
settingsButton.Image = "rbxassetid://6031280882"
settingsButton.MouseButton1Click:Connect(function()
    UI_STATE.settings = not UI_STATE.settings
    settingsFrame.Visible = UI_STATE.settings
end)

-- ========== ПЕРЕТАСКИВАНИЕ ==========
local function makeDraggable(obj)
    local dragging, dragStart, startPos
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true dragStart = input.Position startPos = obj.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(frame)
makeDraggable(toggleButton)

-- ========== ФУНКЦИИ ОБНОВЛЕНИЯ (ТВОЙ ПОЛНЫЙ КОД) ==========
local function getSlotItemName(slot)
    local iname = slot:FindFirstChild("ItemName")
    if not iname then return nil end
    local label = iname:FindFirstChild("Label")
    return label and tostring(label.Text) ~= "" and tostring(label.Text) or nil
end

local function getSlotAmount(slot)
    local container = slot:FindFirstChild("Container")
    local amountObj = container and container:FindFirstChild("Amount")
    if amountObj and amountObj:IsA("TextLabel") then
        return tonumber(amountObj.Text:match("%d+")) or 1
    end
    return 1
end

local function formatDetails(name, isChroma)
    local realName = isChroma and (getChromaName(name) or name) or name
    local details = itemDetails[realName] or itemDetails[name]
    if not details then return "📊 Нет данных" end
    local trendIcon = (details.trend == "Rising" and "📈") or (details.trend == "Falling" and "📉") or "➡️"
    return string.format("%s %s | %s\n%s\n🔥 %s | ✨ %s", trendIcon, details.trend, details.stability, details.range ~= "" and "📊 "..details.range or "", details.demand, details.rarity)
end

local function calculateTotal(sideName, maxSlot, chromaTable)
    local tradeGui = LP.PlayerGui:FindFirstChild("TradeGUI")
    local container = tradeGui and tradeGui.Container.Trade[sideName].Container
    if not container then return 0, 0 end
    local tv, tr = 0, 0
    for i = 1, maxSlot do
        local slot = container:FindFirstChild("NewItem"..i)
        local name = slot and getSlotItemName(slot)
        if name then
            local amt = getSlotAmount(slot)
            local pName = (chromaTable and chromaTable[i]) and (getChromaName(name) or name) or name
            tv = tv + (getPrice(pName) * amt)
            tr = tr + (getDreamPrice(pName) * amt)
        end
    end
    return tv, tr
end

local function updateAll()
    local tradeGui = LP.PlayerGui:FindFirstChild("TradeGUI")
    if not tradeGui then return end
    
    local function updateSide(sideName, slotsUI, chromaMode)
        local container = tradeGui.Container.Trade[sideName].Container
        for i=1,4 do
            local slot = container:FindFirstChild("NewItem"..i)
            local name = slot and getSlotItemName(slot)
            local ui = slotsUI[i]
            if name then
                local amt = getSlotAmount(slot)
                local pName = chromaMode[i] and (getChromaName(name) or name) or name
                local sup, drm = math.floor(getPrice(pName)*amt), math.floor(getDreamPrice(pName)*amt)
                ui.nameLabel.Text = #name > 14 and name:sub(1,12)..".." or name
                ui.priceLabel.Text = drm > 0 and sup.." V\n"..drm.." ₽" or sup.." V"
                ui.detailsLabel.Text = formatDetails(name, chromaMode[i])
            else
                ui.nameLabel.Text = "Пусто" ui.priceLabel.Text = "0 V" ui.detailsLabel.Text = "❌ Нет предмета"
            end
        end
    end

    updateSide("YourOffer", yourSlots, yourChromaMode)
    updateSide("TheirOffer", theirSlots, theirChromaMode)

    local yv, yr = calculateTotal("YourOffer", YOUR_MAX_SLOT, yourChromaMode)
    local tv, tr = calculateTotal("TheirOffer", THEIR_MAX_SLOT, theirChromaMode)
    
    yourTotalLabel.Text = "TOTAL: "..math.floor(yv).." V"
    theirTotalLabel.Text = "TOTAL: "..math.floor(tv).." V"
    yourTotalDreamLabel.Text = yr > 0 and "💸 "..math.floor(yr).." ₽" or ""
    theirTotalDreamLabel.Text = tr > 0 and "💸 "..math.floor(tr).." ₽" or ""
    
    if yv > tv then yourTotalLabel.TextColor3 = Color3.new(0,1,0) theirTotalLabel.TextColor3 = Color3.new(1,0,0)
    elseif tv > yv then yourTotalLabel.TextColor3 = Color3.new(1,0,0) theirTotalLabel.TextColor3 = Color3.new(0,1,0)
    else yourTotalLabel.TextColor3 = Color3.new(0.7,0.7,0.7) theirTotalLabel.TextColor3 = Color3.new(0.7,0.7,0.7) end
end

-- ========== ЗАПУСК ==========
loadDataFromGitHub()
yourSlots[1].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
theirSlots[1].frame.BackgroundColor3 = Color3.fromRGB(40, 60, 90)

spawn(function()
    while task.wait(0.3) do
        pcall(updateAll)
    end
end)

print("[ZXC] Скрипт полностью загружен с логикой трейда и кастомными папками.")
