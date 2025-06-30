local DUNGEONS = {
    [574] = { name = "Utgarde Keep", icon = "Interface\\Icons\\achievement_boss_svalasorrowgrave" },
    [575] = { name = "Utgarde Pinnacle", icon = "Interface\\Icons\\achievement_boss_kingymiron" },
    [576] = { name = "The Nexus", icon = "Interface\\Icons\\spell_frost_frozencore" },
    [578] = { name = "The Oculus", icon = "Interface\\Icons\\achievement_boss_eregos" },
    [595] = { name = "The Culling of\nStratholme", icon = "Interface\\Icons\\achievement_dungeon_cotstratholme_normal" },
    [599] = { name = "Halls of Stone", icon = "Interface\\Icons\\achievement_boss_sjonnir" },
    [600] = { name = "Drak'Tharon Keep", icon = "Interface\\Icons\\inv_bone_skull_04" },
    [601] = { name = "Azjol-Nerub", icon = "Interface\\Icons\\inv_misc_head_nerubian_01" },
    [602] = { name = "Halls of Lightning", icon = "Interface\\Icons\\achievement_boss_archaedas" },
    [604] = { name = "Gundrak", icon = "Interface\\Icons\\achievement_boss_galdarah" },
    [608] = { name = "The Violet Hold", icon = "Interface\\Icons\\achievement_reputation_kirintor" },
    [619] = { name = "Ahn'kahet: The Old Kingdom", icon = "Interface\\Icons\\achievement_boss_yoggsaron_01" },
    [632] = { name = "The Forge of Souls", icon = "Interface\\Icons\\achievement_boss_devourerofsouls" },
    [650] = { name = "Trial of the Champion", icon = "Interface\\Icons\\achievement_reputation_argentcrusader" },
    [658] = { name = "Pit of Saron", icon = "Interface\\Icons\\achievement_boss_scourgelordtyrannus" },
    [668] = { name = "Halls of Reflection", icon = "Interface\\Icons\\achievement_dungeon_icecrown_frostmourne" },
}

local DUNGEON_ORDER = {
    574, 575, 576, 578,
    595, 599, 600, 601,
    602, 604, 608, 619,
    632, 650, 658, 668
}

local AFFIXES = {
    ["Enrage"] = { icon = "Interface\\Icons\\spell_nature_shamanrage", color = "|cffff0000", description = "Boosts physical damage and attack speed, making attacks more relentless." },
    ["Rejuvenating"] = { icon = "Interface\\Icons\\ability_druid_empoweredrejuvination", color = "|cff00ff00", description = "Gradually restores health over time, keeping the creature sustained in battle." },
    ["Turtling"] = { icon = "Interface\\Icons\\ability_warrior_shieldmastery", color = "|cffffff00", description = "Significantly reduces damage taken, increasing survivability." },
    ["Shamanism"] = { icon = "Interface\\Icons\\spell_fire_totemofwrath", color = "|cffa335ee", description = "Enhances spell power, Strength, Agility, and melee speed. Also improves Fire resistance and critical strike chance." },
    ["Magus"] = { icon = "Interface\\Icons\\ability_mage_hotstreak", color = "|cff3399ff", description = "Decreases magic damage received, strengthens armor and Frost resistance, and may slow attackers. Retaliates with Fire damage, increases critical strike effectiveness, and allows swift casting for certain Mage spells." },
    ["Priest Empowered"] = { icon = "Interface\\Icons\\spell_holy_searinglightpriest", color = "|cffcccccc", description = "Fortifies stamina, absorbs incoming damage, and grants protection against Fear effects. Strengthens armor and spell power, with shadow magic restoring health for the caster and nearby allies." },
    ["Demonism"] = { icon = "Interface\\Icons\\ability_warlock_demonicpower", color = "|cff8b0000", description = "Amplifies spell power, gains additional benefits from Spirit, regenerates health periodically, and harms nearby foes." },
    ["Falling Stars"] = { icon = "Interface\\Icons\\ability_druid_starfall", color = "|cff66ccff", description = "Calls down celestial forces, bombarding enemies from above." },
}

local activeAffixes = {}
local AIO = AIO or require("AIO")
if AIO.AddAddon() then
    return
end
local MythicHandlers = AIO.AddHandlers("AIO_Mythic", {})

local reloadCheckFrame = CreateFrame("Frame")
reloadCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
reloadCheckFrame:SetScript("OnEvent", function(self, event, isLogin, isReload)
    if isReload then
        C_Timer.After(1.0, CheckMythicAfterReload)
    end
end)

local lastKeystoneLink = nil
local lastMapName = nil
local fmt, floor = string.format, math.floor

function MythicHandlers.ReceiveMapName(_, mapName)
    lastMapName = mapName

    if GameTooltip:IsShown() then
        local name, link = GameTooltip:GetItem()
        if link and name and string.find(name, "Mythic Keystone") then
            GameTooltip:Hide()
            GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
            GameTooltip:SetHyperlink(link)
        end
    end
end

local lineAdded = false
local function OnTooltipSetItem(tooltip)
    local name, link = tooltip:GetItem()
    if not name or not string.find(name, "Mythic Keystone") then return end
    if link ~= lastKeystoneLink then
        lastKeystoneLink = link
        lastMapName = "Loading..."
        AIO.Handle("AIO_Mythic", "RequestMapName")
    end
    local line = _G[tooltip:GetName() .. "TextLeft2"]
    if line then
        line:SetText("|cffa335eeMythic+ |r" .. (lastMapName or "Loading..."))
        line:Show()
        tooltip:Show()
    end
end

local function OnTooltipCleared(tooltip)
    lineAdded = false
end

GameTooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
GameTooltip:HookScript("OnTooltipCleared", OnTooltipCleared)

local mythicMiniButton = CreateFrame("Button", "MythicPlusMiniButton", Minimap)
mythicMiniButton:SetSize(24, 24)
mythicMiniButton:SetFrameStrata("MEDIUM")
mythicMiniButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

mythicMiniButton:SetNormalTexture("Interface\\AddOns\\Blizzard_AchievementUI\\UI-Achievement-MinimapButton")
mythicMiniButton:SetPushedTexture("Interface\\AddOns\\Blizzard_AchievementUI\\UI-Achievement-MinimapButton-Down")

local icon = mythicMiniButton:CreateTexture(nil, "ARTWORK")
icon:SetTexture("Interface\\Icons\\achievement_bg_wineos_underxminutes")
icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
icon:SetAllPoints(mythicMiniButton)

local border = mythicMiniButton:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetSize(64, 64)
border:SetPoint("CENTER", mythicMiniButton, "CENTER", 12, -12)

mythicMiniButton:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -20, 70)

mythicMiniButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Mythic+")
    GameTooltip:Show()
end)

mythicMiniButton:SetScript("OnLeave", GameTooltip_Hide)

mythicMiniButton:SetScript("OnClick", function()
    if MythicPlusFrame:IsShown() then
        PlaySound("igCharacterInfoClose")
        MythicPlusFrame:Hide()
    else
        PlaySound("igCharacterInfoOpen")
        MythicPlusFrame:Show()
    end
end)

function MythicHandlers.ReceiveWeeklyAffixes(_, affix1, affix2, affix3)
    local function colorize(name)
        return (AFFIXES[name].color or "|cffffffff") .. name .. "|r"
    end

    local text = "This week's affixes: " ..
        colorize(affix1) .. ", " ..
        colorize(affix2) .. ", " ..
        colorize(affix3)

    MythicPlusFrame.affixText:SetText(text)
    
    MythicPlusFrame.currentAffixes = {affix1, affix2, affix3}

    for _, button in ipairs(MythicPlusFrame.affixButtons) do
        local name = button.affixName
        local label = button.label
        local isActive = name == affix1 or name == affix2 or name == affix3
        label:SetText((isActive and "|cff00ff00" or "") .. name)
    end
end

MythicPlusFrame = CreateFrame("Frame", "MythicPlusFrame", UIParent, "UIPanelDialogTemplate")
local frame = MythicPlusFrame


frame:SetSize(600, 400)
frame:SetPoint("CENTER", UIParent, "CENTER", 270, 270)
frame:SetToplevel(true)
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnHide", function(self)PlaySound("igCharacterInfoClose") self:StopMovingOrSizing() end)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

for _, region in ipairs({frame:GetRegions()}) do
    if region:GetObjectType() == "Texture" then
        region:Hide()
    end
end

local parchmentBG = frame:CreateTexture(nil, "BACKGROUND")
parchmentBG:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment")
parchmentBG:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
parchmentBG:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
parchmentBG:SetTexCoord(0, 1, 1, 0)
parchmentBG:SetVertexColor(0.7, 0.7, 0.7, 1)

local parchmentBorder = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
parchmentBorder:SetAllPoints(frame)
parchmentBorder:SetBackdrop({
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
parchmentBorder:SetBackdropBorderColor(1, 1, 1, 1)
frame.parchmentBG = parchmentBG
table.insert(UISpecialFrames, "MythicPlusFrame")

frame:Hide()

local tabBackground = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
tabBackground:SetSize(100, 400)
tabBackground:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
tabBackground:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
tabBackground:SetBackdropColor(0.1, 0.1, 0.1, 0.6)

local tabTitle = tabBackground:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
tabTitle:SetPoint("TOP", tabBackground, "TOP", 0, -15)
tabTitle:SetText("|cffa335eeMythic+|r")

local function CreateTabButton(parent, text, index, onClick)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(80, 30)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -40 - ((index - 1) * 35))
    button:SetText(text)
    button:SetNormalFontObject("GameFontNormal")

    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(0.3, 0.3, 0.3, 0.3)
    button.bg = bg

    button:SetScript("OnClick", function()
        onClick(index)
    end)

    return button
end

local overviewTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
overviewTitle:SetPoint("TOP", frame, "TOP", 40, -20)
overviewTitle:SetText("Overview")
overviewTitle:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
frame.overviewTitle = overviewTitle

local scoreTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
scoreTitle:SetPoint("TOP", frame, "TOP", 40, -20)
scoreTitle:SetText("Score")
scoreTitle:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
frame.scoreTitle = scoreTitle
scoreTitle:Hide()

function MythicHandlers.ReceiveTotalPoints(_, totalPoints, dungeonScores)
    frame.scoreText:SetText("Score: " .. string.format("%.2f", totalPoints))

    for i, mapId in ipairs(DUNGEON_ORDER) do
        local score = dungeonScores[tostring(mapId)] or 0
        local button = frame.scoreButtons[i]

        if button and button.scoreLabel then
            button.scoreLabel:SetText(tostring(score))
        end
    end
end

local scoreText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
scoreText:SetPoint("TOP", frame.scoreTitle, "BOTTOM", 0, -10)
scoreText:SetText("Score: Loading...")
frame.scoreText = scoreText
scoreText:Hide()

frame.scoreButtons = {}

local scoreButtonSize = 50
local scoreCols = 4
local scoreButtonSpacingX = 60
local scoreButtonSpacingY = 26
local scoreStartX = -(scoreCols * scoreButtonSize + (scoreCols - 1) * scoreButtonSpacingX) / 2 + 25

for i, mapId in ipairs(DUNGEON_ORDER) do
    local name = DUNGEONS[mapId].name or ("Map " .. mapId)
    local icon = DUNGEONS[mapId].icon or "Interface\\Icons\\inv_misc_questionmark"

    local button = CreateFrame("Button", nil, frame)
    button:SetSize(scoreButtonSize, scoreButtonSize)

    local row = math.floor((i - 1) / scoreCols)
    local col = (i - 1) % scoreCols
    button:SetPoint(
        "TOP",
        scoreText,
        "BOTTOM",
        scoreStartX + col * (scoreButtonSize + scoreButtonSpacingX),
        -20 - row * (scoreButtonSize + scoreButtonSpacingY)
    )

    local tex = button:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetTexture(icon)
    local scoreFontSize = 16
    local scoreLabel = button:CreateFontString(nil, "OVERLAY")
    scoreLabel:SetPoint("CENTER", button, "CENTER", 0, -15)
    scoreLabel:SetFont("Fonts\\FRIZQT__.TTF", scoreFontSize, "OUTLINE, THICK")
    scoreLabel:SetText("0")
    button.scoreLabel = scoreLabel

    local nameLabel = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    nameLabel:SetPoint("TOP", button, "BOTTOM", 0, -2)
    nameLabel:SetWidth(scoreButtonSize + 40)
    nameLabel:SetWordWrap(true)
    nameLabel:SetText(DUNGEONS[mapId].name or ("Map " .. mapId))
    nameLabel:SetJustifyH("CENTER")
    nameLabel:SetJustifyV("TOP")
    button.nameLabel = nameLabel

    button:Hide()
    frame.scoreButtons[i] = button
end

local leaderboardTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
leaderboardTitle:SetPoint("TOP", frame, "TOP", 40, -20)
leaderboardTitle:SetText("Leaderboard")
leaderboardTitle:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
frame.leaderboardTitle = leaderboardTitle
leaderboardTitle:Hide()

frame.podiums = {}

local podiumSpecs = {
    { height = 60, color = {0.8, 0.8, 0.8,}, x = -140 },
    { height = 90, color = {0.95, 0.84, 0.0}, x = 0 },
    { height = 40, color = {0.72, 0.45, 0.2}, x = 140 },
}

for i, spec in ipairs(podiumSpecs) do
    local podium = CreateFrame("Frame", nil, frame)
    podium:SetSize(135, spec.height)
    podium:SetPoint("BOTTOM", frame, "TOP", spec.x + 35, -170)

    local bg = podium:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(spec.color[1], spec.color[2], spec.color[3], 1)

    local name = podium:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("BOTTOM", podium, "TOP", 0, 4)
    name:SetText("—")
    podium.name = name

    local score = podium:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    score:SetPoint("CENTER", podium, "CENTER")
    score:SetText("0")
    podium.score = score

    podium:Hide()
    frame.podiums[i] = podium
end

frame.leaderboardButtons = {}
local lbButtonSize = 53
local lbSpacingX = 20
local lbSpacingY = 15
local lbCols = 6
local lbStartX = -(lbCols * lbButtonSize + (lbCols - 1) * lbSpacingX) / 2 + 166

for i, mapId in ipairs(DUNGEON_ORDER) do
    local button = CreateFrame("Button", nil, frame)
    button:SetSize(lbButtonSize, lbButtonSize)

    local row = math.floor((i - 1) / lbCols)
    local col = (i - 1) % lbCols
    button:SetPoint(
        "TOP",
        frame.podiums[1],
        "BOTTOM",
        lbStartX + col * (lbButtonSize + lbSpacingX),
        -20 - row * (lbButtonSize + lbSpacingY)
    )

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(DUNGEONS[mapId].icon or "Interface\\Icons\\inv_misc_questionmark")

    button:Hide()
    frame.leaderboardButtons[i] = button
end

function MythicHandlers.ReceiveLeaderboard(_, topThree, dungeonTop)
local visualToRank = {2, 1, 3}

    for i = 1, 3 do
        local rank = visualToRank[i]
        local entry = topThree[rank]
        local podium = frame.podiums[i]

        if entry then
            podium.name:SetText(entry.name)
            podium.score:SetText(string.format("%.2f", entry.points))
            podium.name:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE, THICK")
            podium.score:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        else
            podium.name:SetText("—")
            podium.score:SetText("0")
            podium.name:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE, THICK")
            podium.score:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
        end
    end

    for i, mapId in ipairs(DUNGEON_ORDER) do
        local top = dungeonTop[tostring(mapId)]
        local button = frame.leaderboardButtons[i]
        if button then
            button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(DUNGEONS[mapId].name or ("Dungeon " .. mapId))
                if top then
                    GameTooltip:AddLine("Top: " .. top.name, 1, 1, 0)
                    GameTooltip:AddLine("Score: " .. top.score, 1, 1, 1)
                else
                    GameTooltip:AddLine("No record", 0.7, 0.7, 0.7)
                end
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", GameTooltip_Hide)
        end
    end
end

local affixText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
affixText:SetPoint("TOP", frame, "TOP", 35, -60)
affixText:SetJustifyH("CENTER")
affixText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
affixText:SetText("This week's affixes: Loading...")
frame.affixText = affixText

local affixNames = {
    "Enrage", "Rejuvenating", "Turtling", "Shamanism",
    "Magus", "Priest Empowered", "Demonism", "Falling Stars"
}

frame.affixButtons = {}
local buttonSize = 80
local buttonSpacing = 30
local columns = 4
local totalWidth = columns * buttonSize + (columns - 1) * buttonSpacing
local startX = -(totalWidth / 2) + 80

for i, name in ipairs(affixNames) do
    local button = CreateFrame("Button", nil, frame)
    button:SetSize(buttonSize, buttonSize)

    local row = math.floor((i - 1) / columns)
    local col = (i - 1) % columns
    button:SetPoint(
        "TOP",
        frame,
        "TOP",
        startX + col * (buttonSize + buttonSpacing),
        -120 - row * (buttonSize + buttonSpacing)
    )

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(AFFIXES[name].icon or "Interface\\Icons\\spell_nature_polymorph")

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOP", button, "BOTTOM", 0, -2)
    label:SetText(name)

    button.affixName = name
    button.label = label

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local color = AFFIXES[name].color or "|cffffffff"
        GameTooltip:SetText(color .. name .. "|r")
        GameTooltip:AddLine(AFFIXES[name].description or "", 1, 1, 1, true)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    frame.affixButtons[i] = button
end

local tabs = {}
local function SetActiveTab(index)
    PlaySound("igMainMenuOptionCheckBoxOn")
    for i, tab in ipairs(tabs) do
        tab.bg:SetTexture(i == index and 0.8 or 0.3, i == index and 0.8 or 0.3, i == index and 0.2 or 0.3, 0.5)
    end

    local showOverview = index == 1
    local showScore = index == 2
    local showLeaderboard = index == 3

    if showOverview then
        frame.overviewTitle:Show()
        frame.affixText:Show()
        for _, button in ipairs(frame.affixButtons) do
            button:Show()
        end
    else
        frame.overviewTitle:Hide()
        frame.affixText:Hide()
        for _, button in ipairs(frame.affixButtons) do
            button:Hide()
        end
    end

    if showScore then
        frame.scoreTitle:Show()
        frame.scoreText:Show()
        for _, btn in ipairs(frame.scoreButtons) do
            btn:Show()
        end
        AIO.Handle("AIO_Mythic", "RequestTotalPoints")
    else
        frame.scoreTitle:Hide()
        frame.scoreText:Hide()
        for _, btn in ipairs(frame.scoreButtons) do
            btn:Hide()
        end
    end

    if showLeaderboard then
        frame.leaderboardTitle:Show()
        for _, podium in ipairs(frame.podiums) do podium:Show() end
        for _, btn in ipairs(frame.leaderboardButtons) do btn:Show() end
        AIO.Handle("AIO_Mythic", "RequestLeaderboard")
    else
        frame.leaderboardTitle:Hide()
        for _, podium in ipairs(frame.podiums) do podium:Hide() end
        for _, btn in ipairs(frame.leaderboardButtons) do btn:Hide() end
    end

    if showOverview then
        AIO.Handle("AIO_Mythic", "RequestWeeklyAffixes")
    end
end

tabs[1] = CreateTabButton(frame, "Overview", 1, SetActiveTab)
tabs[2] = CreateTabButton(frame, "Score", 2, SetActiveTab)
tabs[3] = CreateTabButton(frame, "Leaderboard", 3, SetActiveTab)

SetActiveTab(1)

function MythicHandlers.StartMythicTimerGUI(_, mapId, tier, duration, bossNames, potentialGain)
    potentialGain = tonumber(potentialGain) or 0
    if type(bossNames) ~= "table" then bossNames = {} end
    local maxDeaths = (tier == 1) and 6 or 4
    WatchFrame:Hide(); WATCHFRAME_COLLAPSED = true

    local timerFrame = CreateFrame("Frame", nil, UIParent)
    timerFrame:SetSize(320, 120 + #bossNames * 18)
    timerFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -20, -120)
    timerFrame:SetMovable(true)
    timerFrame:EnableMouse(true)
    timerFrame:RegisterForDrag("LeftButton")
    timerFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    timerFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    local progressBar = timerFrame:CreateTexture(nil, "BACKGROUND")
    progressBar:SetTexture("Interface\\MythicPlus\\textures\\MythicBar.blp")
    progressBar:SetSize(0, 128)
    progressBar:SetPoint("LEFT", timerFrame, "LEFT", 0, -10)
    progressBar:SetTexCoord(0, 0, 0, 1)
    progressBar:Hide()

    local function updateProgress(killedBosses, totalBosses)
        if totalBosses == 0 then return end
        
        local progress = math.min(killedBosses / totalBosses, 1.0)
        local maxWidth = 256
        local currentWidth = maxWidth * progress
        
        if progress > 0 then
            progressBar:Show()
            progressBar:SetWidth(currentWidth)
            progressBar:SetTexCoord(0, progress, 0, 1)
        else
            progressBar:Hide()
        end
    end

    local goldenFrame = timerFrame:CreateTexture(nil, "ARTWORK")
    goldenFrame:SetTexture("Interface\\MythicPlus\\textures\\MythicFrame.blp")
    goldenFrame:SetSize(256, 128)
    goldenFrame:SetPoint("LEFT", timerFrame, "LEFT", 0, -10)
    goldenFrame:SetTexCoord(0, 1, 0, 1)

    local dungeonText = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    dungeonText:SetPoint("TOP", goldenFrame, "TOP", 0, -12)
    local dungeonName = (DUNGEONS[mapId] and DUNGEONS[mapId].name) or ("Map "..mapId)
    dungeonText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    dungeonText:SetText(fmt("|cffFFD700%s|r", dungeonName))

    local tierText = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    tierText:SetPoint("TOP", goldenFrame, "LEFT", 50, 26)
    tierText:SetFont("Fonts\\FRIZQT__.TTF", 16, "")
    tierText:SetText(fmt("|cffFFD700Level %d|r", tier))

    local timerText = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    timerText:SetPoint("CENTER", goldenFrame, "LEFT", 48, -6)
    timerText:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
    timerText:SetText(fmt("%02d:%02d", floor(duration/60), duration%60))

    local deaths, penalty, bonus = 0, 0, 0
    local scoreLabel = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scoreLabel:SetPoint("BOTTOM", goldenFrame, "BOTTOM", 60, 50)
    
    local gold, red, green, reset = "|cffFFD700", "|cffff0000", "|cff33ff33", "|r"
    local scoreStr = gold..potentialGain..reset.." "..gold.."("..reset..red.."-"..penalty..reset..gold.."/"..reset..green.."+"..bonus..reset..gold..")"..reset.." "..gold..deaths.."/"..maxDeaths..reset
    scoreLabel:SetText(scoreStr)

    local affixContainer = CreateFrame("Frame", nil, timerFrame)
    affixContainer:SetSize(200, 30)
    affixContainer:SetPoint("BOTTOM", scoreLabel, "TOP", 40, 11)

    local affixIcons = {}
    local currentAffixes = {}

    if MythicPlusFrame and MythicPlusFrame.currentAffixes then
        currentAffixes = MythicPlusFrame.currentAffixes
    end

    local numAffixes = math.min(tier, 3)
    local iconSize = 20
    local iconSpacing = 4
    local totalWidth = (numAffixes * iconSize) + ((numAffixes - 1) * iconSpacing)
    local startX = -totalWidth / 2

    for i = 1, numAffixes do
        local affixName = currentAffixes[i]
        if affixName and AFFIXES[affixName] then
            local icon = CreateFrame("Button", nil, affixContainer)
            icon:SetSize(iconSize, iconSize)
            icon:SetPoint("LEFT", affixContainer, "LEFT", startX + (i-1) * (iconSize + iconSpacing) + 30, -5)
            
            local texture = icon:CreateTexture(nil, "ARTWORK")
            texture:SetAllPoints()
            texture:SetTexture(AFFIXES[affixName].icon)
            
            icon:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                local color = AFFIXES[affixName].color or "|cffffffff"
                GameTooltip:SetText(color .. affixName .. "|r")
                GameTooltip:AddLine(AFFIXES[affixName].description or "", 1, 1, 1, true)
                GameTooltip:Show()
            end)
            
            icon:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
            
            affixIcons[i] = icon
        end
    end

    local bossLabels = {}
    for i, name in ipairs(bossNames) do
        local lbl = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("TOPLEFT", goldenFrame, "BOTTOMLEFT", 20, 10 - (i-1)*16)
        lbl:SetText(fmt("%d/%d %s", 0, 1, name))
        lbl.bossName = name
        bossLabels[i] = lbl
    end

    local elapsed = 0
    timerFrame:SetScript("OnUpdate", function(self, dt)
        if self.stopped then return end
        elapsed = elapsed + dt
        local left = duration - elapsed
        if left < 0 then left = 0 end
        local m,s = floor(left/60), floor(left%60)
        local ratio = left/duration
        local color = "|cff00ff00"
        if ratio < 0.3 then color = "|cffff0000"
        elseif ratio < 0.6 then color = "|cffffff00" end
        timerText:SetText(fmt("%s%02d:%02d|r", color, m, s))
    end)

    timerFrame:Show()

    MythicBossTimerUI = {
        frame = timerFrame,
        timerText = timerText,
        scoreLabel = scoreLabel,
        labels = bossLabels,
        progressBar = progressBar,
        updateProgress = updateProgress,
        totalBosses = #bossNames,
        killedBosses = 0,
        potentialGain = potentialGain,
        penalty = 0,
        bonus = 0,
        deaths = 0,
        maxDeaths = maxDeaths,
    }
end

function MythicHandlers.UpdateMythicScore(_, newPenalty, newDeaths)
    local ui = MythicBossTimerUI
    if not ui or not ui.scoreLabel then return end
    ui.penalty = tonumber(newPenalty) or ui.penalty
    ui.deaths  = tonumber(newDeaths)   or ui.deaths

    local gold  = "|cffcc9933"
    local red   = "|cffff0000"
    local green = "|cff33ff33"
    local reset = "|r"

    local scoreStr =
        gold..ui.potentialGain..reset.." ".. 
        gold.."("..reset..
        red.."-"..ui.penalty..reset..
        gold.."/"..reset..
        green.."+"..ui.bonus..reset..
        gold..")"..reset.." ".. 
        gold..ui.deaths.."/"..ui.maxDeaths..reset

    ui.scoreLabel:SetText(scoreStr)
end

function MythicHandlers.FinalizeMythicScore(_, finalPenalty, finalDeaths, finalBonus)
    local ui = MythicBossTimerUI
    if not ui or not ui.scoreLabel then return end
    ui.penalty = tonumber(finalPenalty) or ui.penalty
    ui.deaths  = tonumber(finalDeaths)  or ui.deaths
    ui.bonus   = tonumber(finalBonus)   or ui.bonus

    local gold  = "|cffcc9933"
    local red   = "|cffff0000"
    local green = "|cff33ff33"
    local reset = "|r"

    local scoreStr =
        gold..ui.potentialGain..reset.." ".. 
        gold.."("..reset..
        red.."-"..ui.penalty..reset..
        gold.."/"..reset..
        green.."+"..ui.bonus..reset..
        gold..")"..reset.." ".. 
        gold..ui.deaths.."/"..ui.maxDeaths..reset

    ui.scoreLabel:SetText(scoreStr)
end

function MythicHandlers.MarkBossKilled(_, mapId, bossIndex)
    local ui = MythicBossTimerUI
    if not ui or not ui.labels then return end
    
    local lbl = ui.labels[bossIndex]
    if lbl and lbl.bossName then
        lbl:SetText(fmt("|cff26c426%d/%d %s|r", 1, 1, lbl.bossName))
        
        ui.killedBosses = ui.killedBosses + 1
        if ui.updateProgress then
            ui.updateProgress(ui.killedBosses, ui.totalBosses)
        end
    end
end

function MythicHandlers.StopMythicTimerGUI(_, remaining)
    local ui = MythicBossTimerUI
    if ui and ui.timerText then
        if type(remaining) == "number" then
            local m, s = floor(remaining/60), floor(remaining%60)
            ui.timerText:SetText(fmt("|cffffff00%02d:%02d|r", m, s))
        end
        ui.frame.stopped = true
    end
end

function MythicHandlers.KillMythicTimerGUI()
    WatchFrame:Show(); WATCHFRAME_COLLAPSED = nil
    if MythicBossTimerUI and MythicBossTimerUI.frame then
        MythicBossTimerUI.frame.stopped = true
        MythicBossTimerUI.frame:Hide()
        MythicBossTimerUI.frame:SetScript("OnUpdate", nil)
        MythicBossTimerUI.frame:SetParent(nil)
        MythicBossTimerUI.frame = nil
    end
    MythicBossTimerUI = nil
end

function MythicHandlers.StartCountdown(_, seconds)
    seconds = tonumber(seconds) or 10

    if CountdownFrame then
        CountdownFrame:Hide()
        CountdownFrame:SetScript("OnUpdate", nil)
    end

    if not CountdownFrame then
        local frame = CreateFrame("Frame", "CountdownFrame", UIParent)
        frame:SetSize(512, 256)
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 250)
        frame:SetFrameStrata("FULLSCREEN_DIALOG")
        frame:Hide()

        frame.digit1 = frame:CreateTexture(nil, "ARTWORK")
        frame.digit1:SetSize(256, 170)
        frame.digit1:SetPoint("CENTER", frame, "CENTER", -70, 0)
        frame.digit1:SetTexture("Interface\\MythicPlus\\textures\\BigTimerNumbers")

        frame.digit2 = frame:CreateTexture(nil, "ARTWORK")
        frame.digit2:SetSize(256, 170)
        frame.digit2:SetPoint("CENTER", frame, "CENTER", 70, 0)
        frame.digit2:SetTexture("Interface\\MythicPlus\\textures\\BigTimerNumbers")

        CountdownFrame = frame
    end

    local frame = CountdownFrame
    frame:Show()

    local function setDigits(num)
        local texW, texH = 1024, 512
        local digitW, digitH = 256, 170
        local columns = 4

        local n1 = math.floor(num / 10)
        local n2 = num % 10

        local function setDigit(tex, digit)
            local col = digit % columns
            local row = math.floor(digit / columns)
            local l = (col * digitW) / texW
            local r = ((col + 1) * digitW) / texW
            local t = (row * digitH) / texH
            local b = ((row + 1) * digitH) / texH
            tex:SetTexCoord(l, r, t, b)
            tex:Show()
        end

        if n1 > 0 then
            setDigit(frame.digit1, n1)
            frame.digit1:Show()
            frame.digit2:SetPoint("CENTER", frame, "CENTER", 70, 0)
        else
            frame.digit1:Hide()
            frame.digit2:SetPoint("CENTER", frame, "CENTER", 0, 0)
        end
        setDigit(frame.digit2, n2)
    end

    setDigits(seconds)
    PlaySoundFile("Interface\\MythicPlus\\sounds\\UI_BattlegroundCountdown_Timer.ogg", "master")

    local remaining = seconds
    frame:SetScript("OnUpdate", function(self, elapsed)
        if not self.lastUpdate then self.lastUpdate = 0 end
        self.lastUpdate = self.lastUpdate + elapsed
        if self.lastUpdate >= 1 then
            self.lastUpdate = self.lastUpdate - 1
            remaining = remaining - 1
            if remaining > 0 then
                setDigits(remaining)
                PlaySoundFile("Interface\\MythicPlus\\sounds\\UI_BattlegroundCountdown_Timer.ogg", "master")
            else
                PlaySoundFile("Interface\\MythicPlus\\sounds\\UI_BattlegroundCountdown_End.ogg", "master")
                self:Hide()
                self:SetScript("OnUpdate", nil)
            end
        end
    end)
end
