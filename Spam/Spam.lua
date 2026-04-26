-- ==================== Spam - Modern Flat Auto-Spam ====================
-- =========================================================================

-- ==================== DATABASE ====================
SpamDB = SpamDB or {
    messages = {},
    delay = 60,
    random = false,
    channel = "SAY",
    autoReplyEnabled = true,
    autoReplyMessage = "I'm busy at the moment. Sorry.",
    timerEnabled = false,
    minimap = {
        hide = false,
        position = 45
    }
}

-- Default messages se il DB è vuoto
if #SpamDB.messages == 0 then
    SpamDB.messages = {
        "[Spam]",
        "[Spam]",
        "[Spam]",
        "[Spam]",
        "[Spam]"
    }
end

-- ==================== COLORI FLAT MODERNI ====================
local colors = {
    primary = { r = 0.00, g = 0.60, b = 1.00 },
    primaryDark = { r = 0.00, g = 0.40, b = 0.80 },
    background = { r = 0.07, g = 0.07, b = 0.07 },
    surface = { r = 0.12, g = 0.12, b = 0.12 },
    surfaceLight = { r = 0.18, g = 0.18, b = 0.18 },
    text = { r = 0.95, g = 0.95, b = 0.95 },
    textDim = { r = 0.65, g = 0.65, b = 0.65 },
    success = { r = 0.20, g = 0.80, b = 0.40 },
    border = { r = 0.25, g = 0.25, b = 0.25 }
}

-- ==================== FUNZIONI UTILITY ====================
local function SendToChannel(msg, channel)
    if not msg or msg == "" then return end
    
    if string.match(channel, "CHANNEL%d+") then
        local channelNum = tonumber(string.match(channel, "CHANNEL(%d+)"))
        if channelNum then
            SendChatMessage(msg, "CHANNEL", nil, channelNum)
            return
        end
    end
    SendChatMessage(msg, channel)
end

-- ==================== FRAME PRINCIPALE ====================
local frame = CreateFrame("Frame", "SpamFrame", UIParent)
frame:SetSize(480, 700)
frame:SetPoint("CENTER")
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
frame:SetBackdropColor(colors.background.r, colors.background.g, colors.background.b, 0.95)
frame:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

-- ==================== TITLE BAR  ====================
local titleBar = CreateFrame("Frame", nil, frame)
titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -8)
titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -8)
titleBar:SetHeight(30)

local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("LEFT", titleBar, "LEFT", 10, 0)
titleText:SetText("Spam - Auto-Spam System")
titleText:SetTextColor(colors.primary.r, colors.primary.g, colors.primary.b)

local closeBtn = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", -5, -3)
closeBtn:SetScript("OnClick", function() frame:Hide() end)

-- ==================== CONTAINER PER IL CONTENUTO ====================
local content = CreateFrame("Frame", nil, frame)
content:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 10, -10)
content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 45)

-- ==================== FUNZIONE PER CREARE SEPARATORI ====================
local function CreateSeparator(parent, yOffset)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    line:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, yOffset)
    line:SetHeight(1)
    line:SetTexture(colors.border.r, colors.border.g, colors.border.b, 0.5)
    return line
end

-- ==================== SEZIONE MESSAGGI ====================
local msgHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
msgHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -10)
msgHeader:SetText("MESSAGES")
msgHeader:SetTextColor(colors.textDim.r, colors.textDim.g, colors.textDim.b)

CreateSeparator(content, -35)

local msgBoxes = {}
for i = 1, 5 do
    local yPos = -50 - (i-1) * 38
    
    local numLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    numLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 15, yPos)
    numLabel:SetText(i .. ".")
    numLabel:SetTextColor(colors.primary.r, colors.primary.g, colors.primary.b)
    
    local boxContainer = CreateFrame("Frame", nil, content)
    boxContainer:SetPoint("TOPLEFT", content, "TOPLEFT", 40, yPos - 2)
    boxContainer:SetSize(380, 24)
    boxContainer:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 1,
    })
    boxContainer:SetBackdropColor(colors.surface.r, colors.surface.g, colors.surface.b, 1)
    boxContainer:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
    
    local msgBox = CreateFrame("EditBox", nil, boxContainer)
    msgBox:SetPoint("TOPLEFT", boxContainer, "TOPLEFT", 5, -2)
    msgBox:SetPoint("BOTTOMRIGHT", boxContainer, "BOTTOMRIGHT", -5, 2)
    msgBox:SetFontObject("GameFontNormalSmall")
    msgBox:SetAutoFocus(false)
    msgBox:SetMaxLetters(255)
    
    msgBox:SetScript("OnTextChanged", function(self)
        SpamDB.messages[i] = self:GetText()
    end)
    
    msgBox:SetScript("OnEnter", function(self)
        boxContainer:SetBackdropBorderColor(colors.primary.r, colors.primary.g, colors.primary.b, 1)
    end)
    
    msgBox:SetScript("OnLeave", function(self)
        boxContainer:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
    end)
    
    msgBoxes[i] = msgBox
end

-- ==================== IMPOSTAZIONI SPAM ====================
local spamHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
spamHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -260)
spamHeader:SetText("SPAM SETTINGS")
spamHeader:SetTextColor(colors.textDim.r, colors.textDim.g, colors.textDim.b)

CreateSeparator(content, -285)

local randomContainer = CreateFrame("Frame", nil, content)
randomContainer:SetPoint("TOPLEFT", content, "TOPLEFT", 15, -300)
randomContainer:SetSize(180, 25)

local randomCheck = CreateFrame("CheckButton", nil, randomContainer, "UICheckButtonTemplate")
randomCheck:SetPoint("LEFT", randomContainer, "LEFT", 0, 0)
randomCheck:SetScript("OnClick", function(self)
    SpamDB.random = self:GetChecked()
end)

local randomText = randomContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
randomText:SetPoint("LEFT", randomCheck, "RIGHT", 5, 0)
randomText:SetText("Random message order")
randomText:SetTextColor(colors.text.r, colors.text.g, colors.text.b)

local delayContainer = CreateFrame("Frame", nil, content)
delayContainer:SetPoint("TOPLEFT", randomContainer, "BOTTOMLEFT", 0, -15)
delayContainer:SetSize(250, 30)

local delayLabel = delayContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
delayLabel:SetPoint("LEFT", delayContainer, "LEFT", 0, 0)
delayLabel:SetText("Delay:")
delayLabel:SetTextColor(colors.text.r, colors.text.g, colors.text.b)

local delayInputContainer = CreateFrame("Frame", nil, delayContainer)
delayInputContainer:SetPoint("LEFT", delayLabel, "RIGHT", 10, 0)
delayInputContainer:SetSize(60, 22)
delayInputContainer:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 1,
})
delayInputContainer:SetBackdropColor(colors.surface.r, colors.surface.g, colors.surface.b, 1)
delayInputContainer:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)

local delayBox = CreateFrame("EditBox", nil, delayInputContainer)
delayBox:SetPoint("TOPLEFT", delayInputContainer, "TOPLEFT", 3, -2)
delayBox:SetPoint("BOTTOMRIGHT", delayInputContainer, "BOTTOMRIGHT", -3, 2)
delayBox:SetFontObject("GameFontNormalSmall")
delayBox:SetNumeric(true)
delayBox:SetAutoFocus(false)

delayBox:SetScript("OnTextChanged", function(self)
    local val = tonumber(self:GetText())
    if val then SpamDB.delay = val end
end)

delayBox:SetScript("OnEnter", function(self)
    delayInputContainer:SetBackdropBorderColor(colors.primary.r, colors.primary.g, colors.primary.b, 1)
end)

delayBox:SetScript("OnLeave", function(self)
    delayInputContainer:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
end)

local delaySec = delayContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
delaySec:SetPoint("LEFT", delayInputContainer, "RIGHT", 5, 0)
delaySec:SetText("seconds")
delaySec:SetTextColor(colors.textDim.r, colors.textDim.g, colors.textDim.b)

-- ==================== SELEZIONE CANALE ====================
local channelHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
channelHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -380)
channelHeader:SetText("CHANNEL")
channelHeader:SetTextColor(colors.textDim.r, colors.textDim.g, colors.textDim.b)

CreateSeparator(content, -405)

-- Dropdown canali
local channels = {
    { value = "SAY", label = "Say" },
    { value = "YELL", label = "Yell" },
    { value = "PARTY", label = "Party" },
    { value = "RAID", label = "Raid" },
    { value = "GUILD", label = "Guild" },
    { value = "INSTANCE_CHAT", label = "Instance" },
    { value = "CHANNEL1", label = "Channel 1" },
    { value = "CHANNEL2", label = "Channel 2" },
    { value = "CHANNEL3", label = "Channel 3" },
    { value = "CHANNEL4", label = "Channel 4" },
    { value = "CHANNEL5", label = "Channel 5" },
    { value = "CHANNEL6", label = "Channel 6" },
    { value = "CHANNEL7", label = "Channel 7" },
    { value = "CHANNEL8", label = "Channel 8" },
    { value = "CHANNEL9", label = "Channel 9" },
    { value = "CHANNEL10", label = "Channel 10" },
}

-- Dropdown usando UIDropDownMenu
local channelDropdown = CreateFrame("Frame", "SpamChannelDropDown", content, "UIDropDownMenuTemplate")
channelDropdown:SetPoint("TOPLEFT", content, "TOPLEFT", 15, -430)
UIDropDownMenu_SetWidth(channelDropdown, 140)

-- Variabile per tenere traccia del testo corrente
local currentChannelText = ""

-- Funzione per aggiornare il testo del dropdown
local function SetDropdownText(text)
    currentChannelText = text
    UIDropDownMenu_SetText(channelDropdown, text)
end

-- Inizializza il dropdown
UIDropDownMenu_Initialize(channelDropdown, function()
    -- Pulisci il menu
    UIDropDownMenu_ClearAll(channelDropdown)
    
    -- Aggiungi i canali
    for _, channel in ipairs(channels) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = channel.label
        info.value = channel.value
        info.func = function()
            SpamDB.channel = channel.value
            SetDropdownText(channel.label)
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- Imposta il testo iniziale dopo un piccolo ritardo per sicurezza
C_Timer.After(0.1, function()
    for _, channel in ipairs(channels) do
        if channel.value == SpamDB.channel then
            SetDropdownText(channel.label)
            break
        end
    end
end)

-- Funzione per aggiornare il testo
local function UpdateChannelText()
    for _, channel in ipairs(channels) do
        if channel.value == SpamDB.channel then
            SetDropdownText(channel.label)
            break
        end
    end
end

-- ==================== AUTO-REPLY SECTION ====================
local replyHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
replyHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -480)
replyHeader:SetText("AUTO-REPLY")
replyHeader:SetTextColor(colors.textDim.r, colors.textDim.g, colors.textDim.b)

CreateSeparator(content, -505)

local replyContainer = CreateFrame("Frame", nil, content)
replyContainer:SetPoint("TOPLEFT", content, "TOPLEFT", 15, -520)
replyContainer:SetSize(400, 70)

local replyCheck = CreateFrame("CheckButton", nil, replyContainer, "UICheckButtonTemplate")
replyCheck:SetPoint("TOPLEFT", replyContainer, "TOPLEFT", 0, 0)
replyCheck:SetScript("OnClick", function(self)
    SpamDB.autoReplyEnabled = self:GetChecked()
end)

local replyCheckText = replyContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
replyCheckText:SetPoint("LEFT", replyCheck, "RIGHT", 5, 0)
replyCheckText:SetText("Enable auto-reply to whispers")
replyCheckText:SetTextColor(colors.text.r, colors.text.g, colors.text.b)

local replyInputContainer = CreateFrame("Frame", nil, replyContainer)
replyInputContainer:SetPoint("TOPLEFT", replyCheck, "BOTTOMLEFT", 0, -8)
replyInputContainer:SetSize(350, 24)
replyInputContainer:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 1,
})
replyInputContainer:SetBackdropColor(colors.surface.r, colors.surface.g, colors.surface.b, 1)
replyInputContainer:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)

local replyBox = CreateFrame("EditBox", nil, replyInputContainer)
replyBox:SetPoint("TOPLEFT", replyInputContainer, "TOPLEFT", 5, -2)
replyBox:SetPoint("BOTTOMRIGHT", replyInputContainer, "BOTTOMRIGHT", -5, 2)
replyBox:SetFontObject("GameFontNormalSmall")
replyBox:SetAutoFocus(false)
replyBox:SetMaxLetters(255)

replyBox:SetScript("OnTextChanged", function(self)
    SpamDB.autoReplyMessage = self:GetText()
end)

replyBox:SetScript("OnEnter", function(self)
    replyInputContainer:SetBackdropBorderColor(colors.primary.r, colors.primary.g, colors.primary.b, 1)
end)

replyBox:SetScript("OnLeave", function(self)
    replyInputContainer:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
end)

-- ==================== BOTTOM BUTTONS ====================
local bottomBar = CreateFrame("Frame", nil, frame)
bottomBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
bottomBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
bottomBar:SetHeight(30)

local timerCheck = CreateFrame("CheckButton", nil, bottomBar, "UICheckButtonTemplate")
timerCheck:SetPoint("LEFT", bottomBar, "LEFT", 5, 0)
timerCheck:SetScript("OnClick", function(self)
    SpamDB.timerEnabled = self:GetChecked()
end)

local timerText = bottomBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
timerText:SetPoint("LEFT", timerCheck, "RIGHT", 5, 0)
timerText:SetText("Auto-spam")
timerText:SetTextColor(colors.text.r, colors.text.g, colors.text.b)

local sendBtn = CreateFrame("Button", nil, bottomBar, "UIPanelButtonTemplate")
sendBtn:SetPoint("RIGHT", bottomBar, "RIGHT", -5, 0)
sendBtn:SetSize(100, 22)
sendBtn:SetText("SEND NOW")
sendBtn:SetNormalFontObject("GameFontNormalSmall")
sendBtn:SetHighlightFontObject("GameFontNormalSmall")

sendBtn:SetScript("OnClick", function()
    local msg = SpamDB.messages[1] or ""
    
    if SpamDB.random then
        local pool = {}
        for _, m in ipairs(SpamDB.messages) do
            if m and m ~= "" then table.insert(pool, m) end
        end
        if #pool > 0 then
            msg = pool[math.random(#pool)]
        end
    end
    
    if msg and msg ~= "" then
        SendToChannel(msg, SpamDB.channel)
    end
end)

-- ==================== MINIMAP BUTTON ====================
local minimapBtn = CreateFrame("Button", "SpamMinimapBtn", Minimap)
minimapBtn:SetSize(32, 32)
minimapBtn:SetFrameStrata("FULLSCREEN")
minimapBtn:SetFrameLevel(100)

-- Posiziona il pulsante
minimapBtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52, -SpamDB.minimap.position)

-- Rendi il bottone dragabile
minimapBtn:SetMovable(true)
minimapBtn:SetClampedToScreen(true)
minimapBtn:RegisterForDrag("LeftButton")
minimapBtn:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
minimapBtn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1)
    if yOfs then
        SpamDB.minimap.position = -yOfs
    end
end)

-- Icona del bottone
local icon = minimapBtn:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\AddOns\\Spam\\icon.tga")
icon:SetAllPoints()

-- Fallback se l'icona non esiste
C_Timer.After(1, function()
    if not icon:GetTexture() then
        icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    end
end)

if not SpamDB.minimap.hide then
    minimapBtn:Show()
else
    minimapBtn:Hide()
end

minimapBtn:SetScript("OnClick", function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end)

minimapBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(minimapBtn, "ANCHOR_LEFT")
    GameTooltip:SetText("Spam")
    GameTooltip:AddLine("Click to open", 1, 1, 1)
    GameTooltip:AddLine("Drag to move", 0.5, 0.5, 1)
    GameTooltip:Show()
end)

minimapBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- ==================== SLASH COMMAND ====================
SLASH_SPAM1 = "/spam"
SLASH_SPAM2 = "/sp"

SlashCmdList["SPAM"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- ==================== AUTO-REPLY EVENT HANDLER ====================
local lastReplies = {}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("CHAT_MSG_WHISPER")
eventFrame:SetScript("OnEvent", function(_, event, msg, sender)
    if event == "CHAT_MSG_WHISPER" then
        if SpamDB.autoReplyEnabled and SpamDB.autoReplyMessage and SpamDB.autoReplyMessage ~= "" then
            local now = GetTime()
            local lastReply = lastReplies[sender] or 0
            
            if (now - lastReply) >= 3600 then
                SendChatMessage(SpamDB.autoReplyMessage, "WHISPER", nil, sender)
                lastReplies[sender] = now
                
                for player, time in pairs(lastReplies) do
                    if (now - time) > 3600 then
                        lastReplies[player] = nil
                    end
                end
            end
        end
    end
end)

-- ==================== TIMER PER AUTO-SPAM ====================
local timerElapsed = 0
local timerFrame = CreateFrame("Frame")
timerFrame:SetScript("OnUpdate", function(self, elapsed)
    if SpamDB.timerEnabled and SpamDB.delay then
        timerElapsed = timerElapsed + elapsed
        if timerElapsed >= SpamDB.delay then
            timerElapsed = 0
            
            local msg = SpamDB.messages[1] or ""
            
            if SpamDB.random then
                local pool = {}
                for _, m in ipairs(SpamDB.messages) do
                    if m and m ~= "" then table.insert(pool, m) end
                end
                if #pool > 0 then
                    msg = pool[math.random(#pool)]
                end
            end
            
            if msg and msg ~= "" then
                SendToChannel(msg, SpamDB.channel)
            end
        end
    end
end)

-- ==================== LOAD SAVED DATA ====================
local function LoadSettings()
    -- Carica i messaggi
    for i, box in ipairs(msgBoxes) do
        box:SetText(SpamDB.messages[i] or "")
    end
    
    -- Carica delay
    delayBox:SetText(tostring(SpamDB.delay))
    
    -- Carica random checkbox
    randomCheck:SetChecked(SpamDB.random)
    
    -- Carica canale
    C_Timer.After(0.2, UpdateChannelText)
    
    -- Carica auto-reply
    replyCheck:SetChecked(SpamDB.autoReplyEnabled)
    replyBox:SetText(SpamDB.autoReplyMessage or "")
    
    -- Carica timer
    timerCheck:SetChecked(SpamDB.timerEnabled)
    
    print("|cff0099FFSpam|r loaded. Type /spam or /sp to open.")
end

-- Inizializza dopo 1 secondo
C_Timer.After(1, LoadSettings)