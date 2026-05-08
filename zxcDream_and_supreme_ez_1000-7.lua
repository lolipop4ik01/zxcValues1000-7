-- ============================================
-- MM2 ULTIMATE CHECKER (FINAL)
-- Полная логика трейда + локальные папки Icons_ZXC / Backgrounds_Ghoul
-- ============================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- ==================== 1. UI СОСТОЯНИЕ ====================
local UI_STATE = {
    mainOpen = true,
    settingsOpen = false
}

local Settings = {
    bgTransparency = 0.55,
    mainTransparency = 0.1
}

-- ==================== 2. ЛОКАЛЬНЫЕ ПАПКИ (ИКОНКА / ФОН) ====================
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

-- ==================== 3. ДАННЫЕ И ЛОГИКА (ВАШ КОД) ====================
local RAW_JSON_URL = "https://raw.githubusercontent.com/lolipop4ik01/zxcValues1000-7/refs/heads/main/prices.json"
local prices, dreampets, itemDetails = {}, {}, {}
local yourChromaMode, theirChromaMode = {false, false, false, false}, {false, false, false, false}
local YOUR_MAX_SLOT, THEIR_MAX_SLOT = 4, 4

local function loadDataFromGitHub()
    local success, result = pcall(function() return game:HttpGet(RAW_JSON_URL) end)
    if not success then return false end
    local data = HttpService:JSONDecode(result)
    for _, items in pairs(data) do
        for name, info in pairs(items) do
            local v = tonumber(info.value) or 0
            if v > 0 then prices[name] = v end
            local dp = tonumber(info.dreampets_price) or 0
            if dp > 0 then dreampets[name] = dp end
            itemDetails[name] = {
                stability = info.stability or "?", trend = info.trend or "?",
                range = info.range or "", demand = tostring(info.demand or "?"),
                rarity = tostring(info.rarity or "?")
            }
        end
    end
    return true
end

local function normalizeChromaName(name)
    if name:match("^Chroma ") then
        local cName = "C. " .. name:sub(8)
        if prices[cName] or dreampets[cName] then return cName end
    elseif name:match("^C%. ") then
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
local function getChromaName(name) return chromaMap[name] or (prices["Chroma " .. name] and "Chroma " .. name) or nil end

local function getPrice(name) return prices[normalizeChromaName(name)] or 0 end
local function getDreamPrice(name) return dreampets[normalizeChromaName(name)] or 0 end

-- ==================== 4. GUI ИНТЕРФЕЙС ====================
pcall(function() game.CoreGui.MM2VALUEGUI:Destroy() end)
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MM2VALUEGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 800, 0, 450)
frame.Position = UDim2.new(0.5, -400, 0, 30)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = Settings.mainTransparency
frame.BorderSizePixel = 0
frame.Visible = UI_STATE.mainOpen
frame.ClipsDescendants = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local bgImage = Instance.new("ImageLabel", frame)
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = bgAsset or "rbxassetid://9066026056"
bgImage.ImageTransparency = Settings.bgTransparency
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.ZIndex = 0

-- Заголовки и линии
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ZXC 1000-7 by Ghouls"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local line = Instance.new("Frame", frame)
line.Position = UDim2.new(0,0,0,35)
line.Size = UDim2.new(1,0,0,2)
line.BackgroundColor3 = Color3.fromRGB(80,80,80)

local center = Instance.new("Frame", frame)
center.Position = UDim2.new(0.5,0,0,40)
center.Size = UDim2.new(0,2,1,-40)
center.BackgroundColor3 = Color3.fromRGB(80,80,80)

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

-- Тоталы
local function createTotalFrame(xPos)
    local f = Instance.new("Frame", frame)
    f.Position = UDim2.new(xPos,0,0,65)
    f.Size = UDim2.new(0.5,0,0,40)
    f.BackgroundColor3 = Color3.fromRGB(30,30,30)
    f.BackgroundTransparency = 0.3
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,5)
    local tl = Instance.new("TextLabel", f)
    tl.Size = UDim2.new(1,0,0.5,0)
    tl.BackgroundTransparency = 1
    tl.Text = "TOTAL: 0 V"
    tl.Font = Enum.Font.GothamBold
    tl.TextScaled = true
    tl.TextColor3 = Color3.fromRGB(180,180,180)
    local tdl = Instance.new("TextLabel", f)
    tdl.Size = UDim2.new(1,0,0.5,0)
    tdl.Position = UDim2.new(0,0,0.5,0)
    tdl.BackgroundTransparency = 1
    tdl.Font = Enum.Font.Gotham
    tdl.TextSize = 12
    tdl.TextColor3 = Color3.fromRGB(150,150,150)
    return tl, tdl
end
local yourTotalLabel, yourDreamLabel = createTotalFrame(0)
local theirTotalLabel, theirDreamLabel = createTotalFrame(0.5)

-- Слоты
local function createSlot(parent, x, y, num)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(0,175,0,140)
    f.Position = UDim2.new(0,x,0,y)
    f.BackgroundColor3 = Color3.fromRGB(25,25,25)
    f.BackgroundTransparency = 0.2
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,6)
    
    local n = Instance.new("TextLabel", f)
    n.Size = UDim2.new(0,22,0,18)
    n.Position = UDim2.new(0,3,0,2)
    n.BackgroundTransparency = 1
    n.Text = tostring(num)
    n.Font = Enum.Font.GothamBold
    n.TextColor3 = Color3.fromRGB(180,180,180)
    
    local nl = Instance.new("TextLabel", f)
    nl.Size = UDim2.new(1,0,0,18)
    nl.Position = UDim2.new(0,0,0,22)
    nl.BackgroundTransparency = 1
    nl.Text = "..."
    nl.Font = Enum.Font.GothamBold
    nl.TextColor3 = Color3.fromRGB(255,200,100)
    
    local pl = Instance.new("TextLabel", f)
    pl.Size = UDim2.new(1,0,0,28)
    pl.Position = UDim2.new(0,0,0,44)
    pl.BackgroundTransparency = 1
    pl.Text = "0 V"
    pl.Font = Enum.Font.GothamBold
    pl.TextColor3 = Color3.fromRGB(100,200,255)
    
    local dl = Instance.new("TextLabel", f)
    dl.Size = UDim2.new(1,0,0,58)
    dl.Position = UDim2.new(0,0,0,76)
    dl.BackgroundTransparency = 1
    dl.Font = Enum.Font.Gotham
    dl.TextSize = 9
    dl.TextColor3 = Color3.fromRGB(160,160,160)
    dl.TextWrapped = true
    
    local sel = Instance.new("TextButton", f)
    sel.Size = UDim2.new(1,0,1,0)
    sel.BackgroundTransparency = 1
    sel.Text = ""
    
    local cBtn = Instance.new("TextButton", f)
    cBtn.Size = UDim2.new(0,22,0,22)
    cBtn.Position = UDim2.new(1,-26,1,-24)
    cBtn.Text = "C"
    cBtn.Font = Enum.Font.GothamBold
    cBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    Instance.new("UICorner", cBtn).CornerRadius = UDim.new(1,0)
    return {frame=f, name=nl, price=pl, details=dl, selectBtn=sel, chromaBtn=cBtn}
end

local yourSlots, theirSlots = {}, {}
local yPos = {{15,115},{200,115},{15,265},{200,265}}
local tPos = {{410,115},{595,115},{410,265},{595,265}}

for i=1,4 do
    yourSlots[i] = createSlot(frame, yPos[i][1], yPos[i][2], i)
    yourSlots[i].chromaBtn.MouseButton1Click:Connect(function()
        yourChromaMode[i] = not yourChromaMode[i]
        yourSlots[i].chromaBtn.BackgroundColor3 = yourChromaMode[i] and Color3.fromRGB(150,50,200) or Color3.fromRGB(40,40,40)
    end)
    yourSlots[i].selectBtn.MouseButton1Click:Connect(function()
        YOUR_MAX_SLOT = i
        for j=1,4 do yourSlots[j].frame.BackgroundColor3 = (j==i) and Color3.fromRGB(40,60,90) or Color3.fromRGB(25,25,25) end
    end)
    
    theirSlots[i] = createSlot(frame, tPos[i][1], tPos[i][2], i)
    theirSlots[i].chromaBtn.MouseButton1Click:Connect(function()
        theirChromaMode[i] = not theirChromaMode[i]
        theirSlots[i].chromaBtn.BackgroundColor3 = theirChromaMode[i] and Color3.fromRGB(150,50,200) or Color3.fromRGB(40,40,40)
    end)
    theirSlots[i].selectBtn.MouseButton1Click:Connect(function()
        THEIR_MAX_SLOT = i
        for j=1,4 do theirSlots[j].frame.BackgroundColor3 = (j==i) and Color3.fromRGB(40,60,90) or Color3.fromRGB(25,25,25) end
    end)
end
yourSlots[1].frame.BackgroundColor3 = Color3.fromRGB(40,60,90)
theirSlots[1].frame.BackgroundColor3 = Color3.fromRGB(40,60,90)

-- Окно настроек (ЗАКРЕПЛЕНО)
local settingsFrame = Instance.new("Frame", gui)
settingsFrame.Size = UDim2.new(0,260,0,150)
settingsFrame.Position = UDim2.new(0,140,0.5,-75)
settingsFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
settingsFrame.Visible = UI_STATE.settingsOpen
settingsFrame.Active = false
settingsFrame.Draggable = false
Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0,10)

local setTitle = Instance.new("TextLabel", settingsFrame)
setTitle.Size = UDim2.new(1,0,0,40)
setTitle.BackgroundTransparency = 1
setTitle.Text = "SETTINGS"
setTitle.Font = Enum.Font.GothamBold
setTitle.TextColor3 = Color3.new(1,1,1)

-- Кнопки управления
local toggleButton = Instance.new("ImageButton", gui)
toggleButton.Size = UDim2.new(0,60,0,60)
toggleButton.Position = UDim2.new(0,20,0.5,-30)
toggleButton.BackgroundColor3 = Color3.fromRGB(20,20,20)
toggleButton.Image = iconAsset or "rbxassetid://7072719338"
toggleButton.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", toggleButton).Thickness = 2

toggleButton.MouseButton1Click:Connect(function()
    UI_STATE.mainOpen = not UI_STATE.mainOpen
    frame.Visible = UI_STATE.mainOpen
    if not UI_STATE.mainOpen then
        UI_STATE.settingsOpen = false
        settingsFrame.Visible = false
    end
end)

local gearButton = Instance.new("ImageButton", frame)
gearButton.Size = UDim2.new(0,28,0,28)
gearButton.Position = UDim2.new(1,-38,0,5)
gearButton.BackgroundTransparency = 1
gearButton.Image = "rbxassetid://6031094678"
gearButton.MouseButton1Click:Connect(function()
    UI_STATE.settingsOpen = not UI_STATE.settingsOpen
    settingsFrame.Visible = UI_STATE.settingsOpen
end)

-- Перетаскивание
local function makeDraggable(obj)
    local drag, dragStart, startPos
    obj.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; dragStart = i.Position; startPos = obj.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(frame)
makeDraggable(toggleButton)

-- ==================== 5. ЛОГИКА ТРЕЙДА (ВАШ КОД) ====================
local function getSlotItemName(slot)
    local itemName = slot:FindFirstChild("ItemName")
    if not itemName then return nil end
    local label = itemName:FindFirstChild("Label")
    return label and tostring(label.Text) ~= "" and tostring(label.Text) or nil
end

local function getSlotAmount(slot)
    local container = slot:FindFirstChild("Container")
    local amountObj = container and container:FindFirstChild("Amount")
    if amountObj and amountObj:IsA("TextLabel") then
        local num = amountObj.Text:match("%d+")
        if num then return tonumber(num) end
    end
    return 1
end

local function formatDetails(name, isChroma)
    local realName = isChroma and (getChromaName(name) or name) or name
    local d = itemDetails[realName] or itemDetails[name]
    if not d then return "📊 Нет данных" end
    local icon = (d.trend == "Rising" and "📈") or (d.trend == "Falling" and "📉") or "➡️"
    local rangeStr = (d.range and d.range ~= "") and ("📊 " .. d.range) or ""
    return string.format("%s %s | %s\n%s\n🔥 %s | ✨ %s", icon, d.trend, d.stability, rangeStr, d.demand, d.rarity)
end

local function calculateTotal(side, maxSlot, chromaMode)
    local tradeGui = LP.PlayerGui:FindFirstChild("TradeGUI")
    local container = tradeGui and tradeGui.Container.Trade[side].Container
    if not container then return 0, 0 end
    local totalV, totalR = 0, 0
    for i=1, maxSlot do
        local slot = container:FindFirstChild("NewItem"..i)
        if slot then
            local name = getSlotItemName(slot)
            if name then
                local amount = getSlotAmount(slot)
                local lookupName = (chromaMode and chromaMode[i]) and (getChromaName(name) or name) or name
                totalV = totalV + (getPrice(lookupName) * amount)
                totalR = totalR + (getDreamPrice(lookupName) * amount)
            end
        end
    end
    return totalV, totalR
end

local function updateAll()
    local tradeGui = LP.PlayerGui:FindFirstChild("TradeGUI")
    if not tradeGui then return end
    
    local function updateSide(container, slots, chromaMode)
        for i=1,4 do
            local slot = container:FindFirstChild("NewItem"..i)
            local ui = slots[i]
            if slot then
                local name = getSlotItemName(slot)
                if name then
                    local amount = getSlotAmount(slot)
                    local priceName = chromaMode[i] and (getChromaName(name) or name) or name
                    local sup = math.floor(getPrice(priceName) * amount)
                    local drm = math.floor(getDreamPrice(priceName) * amount)
                    ui.name.Text = (#name > 14) and name:sub(1,12)..".." or name
                    ui.price.Text = (drm > 0) and (sup.." V\n"..drm.." ₽") or (sup.." V")
                    ui.details.Text = formatDetails(name, chromaMode[i])
                else
                    ui.name.Text = "Пусто"; ui.price.Text = "0 V"; ui.details.Text = "❌"
                end
            else
                ui.name.Text = "Пусто"; ui.price.Text = "0 V"; ui.details.Text = "❌"
            end
        end
    end
    
    local yourCont = tradeGui.Container.Trade.YourOffer.Container
    local theirCont = tradeGui.Container.Trade.TheirOffer.Container
    updateSide(yourCont, yourSlots, yourChromaMode)
    updateSide(theirCont, theirSlots, theirChromaMode)
    
    local yV, yR = calculateTotal("YourOffer", YOUR_MAX_SLOT, yourChromaMode)
    local tV, tR = calculateTotal("TheirOffer", THEIR_MAX_SLOT, theirChromaMode)
    
    yourTotalLabel.Text = "TOTAL: "..math.floor(yV).." V"
    theirTotalLabel.Text = "TOTAL: "..math.floor(tV).." V"
    yourDreamLabel.Text = (yR > 0) and ("💸 "..math.floor(yR).." ₽") or ""
    theirDreamLabel.Text = (tR > 0) and ("💸 "..math.floor(tR).." ₽") or ""
    
    if yV > tV then
        yourTotalLabel.TextColor3 = Color3.new(0,1,0)
        theirTotalLabel.TextColor3 = Color3.new(1,0,0)
    elseif tV > yV then
        yourTotalLabel.TextColor3 = Color3.new(1,0,0)
        theirTotalLabel.TextColor3 = Color3.new(0,1,0)
    else
        yourTotalLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
        theirTotalLabel.TextColor3 = Color3.new(0.7,0.7,0.7)
    end
end

-- ==================== 6. ЗАПУСК ====================
loadDataFromGitHub()

spawn(function()
    while task.wait(0.3) do
        pcall(updateAll)
    end
end)

print("[ZXC] Скрипт готов! Иконка -> " .. (iconAsset and "папка Icons_ZXC" or "стандартная") ..
      " | Фон -> " .. (bgAsset and "папка Backgrounds_Ghoul" or "стандартный"))
