-- Spam

local channels = {
    { value = "SAY",           label = "Say"      },
    { value = "YELL",          label = "Yell"     },
    { value = "PARTY",        label = "Party"    },
    { value = "RAID",         label = "Raid"     },
    { value = "GUILD",        label = "Guild"    },
    { value = "INSTANCE_CHAT",label = "Instance" },
    { value = "CHANNEL1",     label = "Channel 1" },
    { value = "CHANNEL2",     label = "Channel 2" },
    { value = "CHANNEL3",     label = "Channel 3" },
    { value = "CHANNEL4",     label = "Channel 4" },
    { value = "CHANNEL5",     label = "Channel 5" },
    { value = "CHANNEL6",     label = "Channel 6" },
    { value = "CHANNEL7",     label = "Channel 7" },
    { value = "CHANNEL8",     label = "Channel 8" },
    { value = "CHANNEL9",     label = "Channel 9" },
    { value = "CHANNEL10",    label = "Channel 10" },
}

local builtinChannelInfo = {
    SAY           = "Say - Visible to nearby players",
    YELL          = "Yell - Visible to far players",
    PARTY         = "Party - Party members only",
    RAID          = "Raid - Raid members only",
    GUILD         = "Guild - Guild members only",
    INSTANCE_CHAT = "Instance - Battleground / Instance group",
}

local function GetChannelTooltipText(ch)
    if builtinChannelInfo[ch.value] then
        return builtinChannelInfo[ch.value]
    end
    local channelNum = tonumber(string.match(ch.value, "CHANNEL(%d+)"))
    if channelNum then
        local name = GetChannelName(channelNum)
        if name and name ~= "" then
            return "Channel " .. channelNum .. " - " .. tostring(name)
        end
        return "Channel " .. channelNum .. " (not joined)"
    end
    return ch.label
end

local defaults = {
    messages = {},
    delay = 60,
    random = false,
    channel = "SAY",
    channels = { SAY = true },
    autoReplyEnabled = true,
    autoReplyMessage = "I'm busy at the moment. Sorry.",
    timerEnabled = false,
    minimap = {
        hide = false,
        position = 45
    }
}

SpamDB = SpamDB or {}

local function mergeDefaults(saved, default)
    for k, v in pairs(default) do
        if saved[k] == nil then
            saved[k] = v
        elseif type(v) == "table" and type(saved[k]) == "table" then
            mergeDefaults(saved[k], v)
        end
    end
end
mergeDefaults(SpamDB, defaults)

if type(SpamDB.channels) ~= "table" then
    SpamDB.channels = {}
end

if SpamDB.channel and next(SpamDB.channels) == nil then
    SpamDB.channels[SpamDB.channel] = true
end

if next(SpamDB.channels) == nil then
    SpamDB.channels = { SAY = true }
end

for k, v in pairs(SpamDB.channels) do
    if v ~= true and v ~= false then
        SpamDB.channels[k] = (v and true) or false
    end
end

if #SpamDB.messages == 0 then
    SpamDB.messages = {
        "[Spam]",
        "[Spam]",
        "[Spam]",
        "[Spam]",
        "[Spam]"
    }
end

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

local function SendToAllChannels(msg)
    if not msg or msg == "" then return end
    if type(SpamDB.channels) ~= "table" then return end
    for _, ch in ipairs(channels) do
        if SpamDB.channels[ch.value] then
            SendToChannel(msg, ch.value)
        end
    end
end

local frame = CreateFrame("Frame", "SpamFrame", UIParent)
frame:SetSize(620, 760)
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

local content = CreateFrame("Frame", nil, frame)
content:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 10, -10)
content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 55)

local function CreateSeparator(parent, yOffset)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)
    line:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, yOffset)
    line:SetHeight(1)
    line:SetTexture(colors.border.r, colors.border.g, colors.border.b, 0.5)
    return line
end

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
    boxContainer:SetSize(540, 24)
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
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
        GameTooltip:ClearLines()
        GameTooltip:AddLine("Message " .. i, colors.primary.r, colors.primary.g, colors.primary.b)
        local txt = self:GetText()
        if txt and txt ~= "" then
            GameTooltip:AddLine(txt, colors.text.r, colors.text.g, colors.text.b, true)
        else
            GameTooltip:AddLine("(empty)", colors.textDim.r, colors.textDim.g, colors.textDim.b, true)
        end
        GameTooltip:Show()
    end)

    msgBox:SetScript("OnLeave", function(self)
        boxContainer:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
        GameTooltip:Hide()
    end)

    msgBoxes[i] = msgBox
end

local spamHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
spamHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -255)
spamHeader:SetText("SPAM SETTINGS")
spamHeader:SetTextColor(colors.textDim.r, colors.textDim.g, colors.textDim.b)

CreateSeparator(content, -280)

local randomContainer = CreateFrame("Frame", nil, content)
randomContainer:SetPoint("TOPLEFT", content, "TOPLEFT", 15, -295)
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
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Delay", colors.primary.r, colors.primary.g, colors.primary.b)
    GameTooltip:AddLine("Seconds between each auto-spam tick", colors.textDim.r, colors.textDim.g, colors.textDim.b, true)
    GameTooltip:Show()
end)

delayBox:SetScript("OnLeave", function(self)
    delayInputContainer:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
    GameTooltip:Hide()
end)

local delaySec = delayContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
delaySec:SetPoint("LEFT", delayInputContainer, "RIGHT", 5, 0)
delaySec:SetText("seconds")
delaySec:SetTextColor(colors.textDim.r, colors.textDim.g, colors.textDim.b)

local channelHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
channelHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -365)
channelHeader:SetText("CHANNELS  (hover to see real name)")
channelHeader:SetTextColor(colors.textDim.r, colors.textDim.g, colors.textDim.b)

CreateSeparator(content, -380)

local selectAllBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
selectAllBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 15, -390)
selectAllBtn:SetSize(90, 20)
selectAllBtn:SetText("SELECT ALL")
selectAllBtn:SetNormalFontObject("GameFontNormalSmall")
selectAllBtn:SetHighlightFontObject("GameFontNormalSmall")

local deselectAllBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
deselectAllBtn:SetPoint("TOPLEFT", selectAllBtn, "TOPRIGHT", 5, 0)
deselectAllBtn:SetSize(90, 20)
deselectAllBtn:SetText("CLEAR ALL")
deselectAllBtn:SetNormalFontObject("GameFontNormalSmall")
deselectAllBtn:SetHighlightFontObject("GameFontNormalSmall")

local channelCheckboxes = {}
local channelGridY = -420
local channelRowHeight = 22
local channelColX = { 15, 165, 315, 465 }

for idx, ch in ipairs(channels) do
    local row = math.floor((idx - 1) / 4) + 1
    local col = (idx - 1) % 4 + 1
    local yPos = channelGridY - (row - 1) * channelRowHeight
    local xPos = channelColX[col]

    local cb = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", content, "TOPLEFT", xPos, yPos)
    cb:SetHitRectInsets(0, -100, 0, 0)

    local lbl = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    lbl:SetText(ch.label)
    lbl:SetTextColor(colors.text.r, colors.text.g, colors.text.b)

    cb:SetChecked(SpamDB.channels[ch.value] == true)

    cb:SetScript("OnClick", function(self)
        if type(SpamDB.channels) ~= "table" then SpamDB.channels = {} end
        SpamDB.channels[ch.value] = self:GetChecked()
    end)

    cb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(ch.label, colors.primary.r, colors.primary.g, colors.primary.b)
        GameTooltip:AddLine(GetChannelTooltipText(ch), colors.text.r, colors.text.g, colors.text.b, true)
        GameTooltip:Show()
    end)

    cb:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    channelCheckboxes[idx] = cb
end

selectAllBtn:SetScript("OnClick", function()
    if type(SpamDB.channels) ~= "table" then SpamDB.channels = {} end
    for _, ch in ipairs(channels) do
        SpamDB.channels[ch.value] = true
    end
    for _, cb in ipairs(channelCheckboxes) do
        cb:SetChecked(true)
    end
end)

deselectAllBtn:SetScript("OnClick", function()
    if type(SpamDB.channels) ~= "table" then SpamDB.channels = {} end
    for _, ch in ipairs(channels) do
        SpamDB.channels[ch.value] = false
    end
    for _, cb in ipairs(channelCheckboxes) do
        cb:SetChecked(false)
    end
end)

local replyHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
replyHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -555)
replyHeader:SetText("AUTO-REPLY")
replyHeader:SetTextColor(colors.textDim.r, colors.textDim.g, colors.textDim.b)

CreateSeparator(content, -580)

local replyContainer = CreateFrame("Frame", nil, content)
replyContainer:SetPoint("TOPLEFT", content, "TOPLEFT", 15, -595)
replyContainer:SetSize(540, 70)

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
replyInputContainer:SetSize(540, 24)
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
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Auto-Reply Message", colors.primary.r, colors.primary.g, colors.primary.b)
    local txt = self:GetText()
    if txt and txt ~= "" then
        GameTooltip:AddLine(txt, colors.text.r, colors.text.g, colors.text.b, true)
    else
        GameTooltip:AddLine("(empty)", colors.textDim.r, colors.textDim.g, colors.textDim.b, true)
    end
    GameTooltip:Show()
end)

replyBox:SetScript("OnLeave", function(self)
    replyInputContainer:SetBackdropBorderColor(colors.border.r, colors.border.g, colors.border.b, 1)
    GameTooltip:Hide()
end)

local bottomBar = CreateFrame("Frame", nil, frame)
bottomBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 12)
bottomBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 12)
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
sendBtn:SetSize(110, 24)
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
        SendToAllChannels(msg)
    end
end)

local minimapBtn = CreateFrame("Button", "SpamMinimapBtn", Minimap)
minimapBtn:SetSize(32, 32)
minimapBtn:SetFrameStrata("FULLSCREEN")
minimapBtn:SetFrameLevel(100)

minimapBtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52, -SpamDB.minimap.position)
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

local icon = minimapBtn:CreateTexture(nil, "BACKGROUND")
icon:SetTexture("Interface\\AddOns\\Spam\\icon.tga")
icon:SetAllPoints()

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

SLASH_SPAM1 = "/spam"
SLASH_SPAM2 = "/sp"

SlashCmdList["SPAM"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

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
                SendToAllChannels(msg)
            end
        end
    end
end)

local function LoadSettings()
    for i, box in ipairs(msgBoxes) do
        box:SetText(SpamDB.messages[i] or "")
    end

    delayBox:SetText(tostring(SpamDB.delay))

    randomCheck:SetChecked(SpamDB.random)

    replyCheck:SetChecked(SpamDB.autoReplyEnabled)
    replyBox:SetText(SpamDB.autoReplyMessage or "")

    timerCheck:SetChecked(SpamDB.timerEnabled)

    if type(SpamDB.channels) ~= "table" then SpamDB.channels = { SAY = true } end
    for idx, cb in ipairs(channelCheckboxes) do
        cb:SetChecked(SpamDB.channels[channels[idx].value] == true)
    end

    print("|cff0099FFSpam|r loaded. Type /spam or /sp to open.")
end

C_Timer.After(1, LoadSettings)
