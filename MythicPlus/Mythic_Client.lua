local activeAffixes = {}
local AIO = AIO or require("AIO")
local L = {
    Text = function(self, category, key, localeIndex)
        if not self[category] or not self[category][key] then
            return key
        end
        
        if not self[category][key][localeIndex] then
            return self[category][key][0]
        end
        
        return self[category][key][localeIndex]
    end,
    Items = {},
    Dungeons = {},
    UI = {}
}
if AIO.AddAddon() then
    return
end

local MythicHandlers = AIO.AddHandlers("AIO_Mythic", {})
local lastKeystoneLink = nil
local lastMapName = nil
local lastTierLevel = nil
local fmt, floor = string.format, math.floor
local localeDataReceived = false

function MythicHandlers.ReceiveLocaleData(_, category, entries)
    if type(entries) == "table" then
        L[category] = entries
        if L.Items and L.Dungeons and L.UI then
            localeDataReceived = true
            if MythicPlusFrame then
                UpdateLocalizedElements()
            end
        end
    end
end

function MythicGetText(category, key)
    local localeIndex = GetLocale() and MythicGetLocaleIndex() or 0
    return L:Text(category, key, localeIndex)
end

function MythicGetLocaleIndex()
    local locale = GetLocale()
    local localeMap = {
        ["enUS"] = 0, ["enGB"] = 0,
        ["koKR"] = 1,
        ["frFR"] = 2,
        ["deDE"] = 3,
        ["zhCN"] = 4,
        ["zhTW"] = 5,
        ["esES"] = 6,
        ["esMX"] = 7,
        ["ruRU"] = 8
    }
    return localeMap[locale] or 0
end

function UpdateLocalizedElements()
    if DUNGEONS then
        for mapId, dungeonData in pairs(DUNGEONS) do
            dungeonData.name = MythicGetText("Dungeons", dungeonData.originalName)
        end
    end
    
    if MythicPlusFrame then
        if tabs then
            for i, tab in ipairs(tabs) do
                if i == 1 then
                    tab:SetText(MythicGetText("UI", "Overview"))
                elseif i == 2 then
                    tab:SetText(MythicGetText("UI", "Score"))
                elseif i == 3 then
                    tab:SetText(MythicGetText("UI", "Leaderboard"))
                end
            end
        end
        
        if MythicPlusFrame.overviewTitle then
            MythicPlusFrame.overviewTitle:SetText(MythicGetText("UI", "Overview"))
        end
        if MythicPlusFrame.scoreTitle then
            MythicPlusFrame.scoreTitle:SetText(MythicGetText("UI", "Score"))
        end
        if MythicPlusFrame.leaderboardTitle then
            MythicPlusFrame.leaderboardTitle:SetText(MythicGetText("UI", "Leaderboard"))
        end
    
    if frame and frame.affixButtons then
        for _, button in ipairs(frame.affixButtons) do
            if button.affixName then
                local isActive = frame.currentAffixes and 
                    (button.affixName == frame.currentAffixes[1] or 
                     button.affixName == frame.currentAffixes[2] or 
                     button.affixName == frame.currentAffixes[3])
                
                button.label:SetText((isActive and "|cff00ff00" or "") .. MythicGetText("UI", button.affixName))
                button:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    local color = AFFIXES[button.affixName].color or "|cffffffff"
                    GameTooltip:SetText(color .. MythicGetText("UI", button.affixName) .. "|r")
                    GameTooltip:AddLine(AFFIXES[button.affixName].description or "", 1, 1, 1, true)
                    GameTooltip:Show()
                end)
            end
        end
    end
    if frame and frame.scoreButtons then
        for i, button in ipairs(frame.scoreButtons) do
            local mapId = DUNGEON_ORDER[i]
            if mapId and DUNGEONS[mapId] then
                button.nameLabel:SetText(DUNGEONS[mapId].name)
            end
        end
    end
    if frame and frame.leaderboardButtons then
        for i, button in ipairs(frame.leaderboardButtons) do
            local mapId = DUNGEON_ORDER[i]
            if mapId then
                button:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetText(MythicGetText("Dungeons", DUNGEONS[mapId].originalName))
                    GameTooltip:Show()
                end)
            end
        end
    end
        if MythicPlusFrame:IsVisible() and MythicPlusFrame.currentTab then
            SetActiveTab(MythicPlusFrame.currentTab)
        end
    end
end

local DUNGEONS = {
    [574] = { originalName = "Utgarde Keep", name = "Utgarde Keep", icon = "Interface\\Icons\\achievement_boss_svalasorrowgrave" },
    [575] = { originalName = "Utgarde Pinnacle", name = "Utgarde Pinnacle", icon = "Interface\\Icons\\achievement_boss_kingymiron" },
    [576] = { originalName = "The Nexus", name = "The Nexus", icon = "Interface\\Icons\\spell_frost_frozencore" },
    [578] = { originalName = "The Oculus", name = "The Oculus", icon = "Interface\\Icons\\achievement_boss_eregos" },
    [595] = { originalName = "The Culling of Stratholme", name = "The Culling of Stratholme", icon = "Interface\\Icons\\achievement_dungeon_cotstratholme_normal" },
    [599] = { originalName = "Halls of Stone", name = "Halls of Stone", icon = "Interface\\Icons\\achievement_boss_sjonnir" },
    [600] = { originalName = "Drak'Tharon Keep", name = "Drak'Tharon Keep", icon = "Interface\\Icons\\inv_bone_skull_04" },
    [601] = { originalName = "Azjol-Nerub", name = "Azjol-Nerub", icon = "Interface\\Icons\\inv_misc_head_nerubian_01" },
    [602] = { originalName = "Halls of Lightning", name = "Halls of Lightning", icon = "Interface\\Icons\\achievement_boss_archaedas" },
    [604] = { originalName = "Gundrak", name = "Gundrak", icon = "Interface\\Icons\\achievement_boss_galdarah" },
    [608] = { originalName = "The Violet Hold", name = "The Violet Hold", icon = "Interface\\Icons\\achievement_reputation_kirintor" },
    [619] = { originalName = "Ahn'kahet: The Old Kingdom", name = "Ahn'kahet: The Old Kingdom", icon = "Interface\\Icons\\achievement_boss_yoggsaron_01" },
    [632] = { originalName = "The Forge of Souls", name = "The Forge of Souls", icon = "Interface\\Icons\\achievement_boss_devourerofsouls" },
    [650] = { originalName = "Trial of the Champion", name = "Trial of the Champion", icon = "Interface\\Icons\\achievement_reputation_argentcrusader" },
    [658] = { originalName = "Pit of Saron", name = "Pit of Saron", icon = "Interface\\Icons\\achievement_boss_scourgelordtyrannus" },
    [668] = { originalName = "Halls of Reflection", name = "Halls of Reflection", icon = "Interface\\Icons\\achievement_dungeon_icecrown_frostmourne" },
}

AIO.Handle("AIO_Mythic", "RequestLocaleData", "Items")
AIO.Handle("AIO_Mythic", "RequestLocaleData", "Dungeons")
AIO.Handle("AIO_Mythic", "RequestLocaleData", "UI")

local updateFrame = CreateFrame("Frame")
updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
updateFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(1, function()
            AIO.Handle("AIO_Mythic", "RequestLocaleData", "Items")
            AIO.Handle("AIO_Mythic", "RequestLocaleData", "Dungeons")
            AIO.Handle("AIO_Mythic", "RequestLocaleData", "UI")
        end)
    end
end)

local DUNGEON_ORDER = {
    574, 575, 576, 578,
    595, 599, 600, 601,
    602, 604, 608, 619,
    632, 650, 658, 668
}

local AFFIXES = {
    ["Enrage"] = { icon = "Interface\\Icons\\spell_nature_shamanrage", color = "|cffff0000", description = function() return MythicGetText("UI", "Enrage Description") end },
    ["Rejuvenating"] = { icon = "Interface\\Icons\\ability_druid_empoweredrejuvination", color = "|cff00ff00", description = function() return MythicGetText("UI", "Rejuvenating Description") end },
    ["Turtling"] = { icon = "Interface\\Icons\\ability_warrior_shieldmastery", color = "|cffffff00", description = function() return MythicGetText("UI", "Turtling Description") end },
    ["Shamanism"] = { icon = "Interface\\Icons\\spell_fire_totemofwrath", color = "|cffa335ee", description = function() return MythicGetText("UI", "Shamanism Description") end },
    ["Magus"] = { icon = "Interface\\Icons\\ability_mage_hotstreak", color = "|cff3399ff", description = function() return MythicGetText("UI", "Magus Description") end },
    ["Priest Empowered"] = { icon = "Interface\\Icons\\spell_holy_searinglightpriest", color = "|cffcccccc", description = function() return MythicGetText("UI", "Priest Empowered Description") end },
    ["Demonism"] = { icon = "Interface\\Icons\\ability_warlock_demonicpower", color = "|cff8b0000", description = function() return MythicGetText("UI", "Demonism Description") end },
    ["Falling Stars"] = { icon = "Interface\\Icons\\ability_druid_starfall", color = "|cff66ccff", description = function() return MythicGetText("UI", "Falling Stars Description") end },
}

function MythicHandlers.ReceiveMapNameAndTier(_, mapName, tier)
    local originalMapName = mapName
    for id, dungeon in pairs(DUNGEONS) do
        if dungeon.originalName == mapName then
            mapName = MythicGetText("Dungeons", dungeon.originalName)
            break
        end
    end
    
    lastMapName = mapName
    lastTierLevel = tier

    if GameTooltip:IsShown() then
        local name, link = GameTooltip:GetItem()
        if link and name and (string.find(name, "Mythic Keystone") or string.find(name, MythicGetText("Items", "Mythic Keystone"))) then
            GameTooltip:Hide()
            GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
            GameTooltip:SetHyperlink(link)
        end
    end
end

local lineAdded = false
function OnTooltipSetItem(tooltip)
    local name, link = tooltip:GetItem()
    local englishName = "Mythic Keystone"
    local localizedName = MythicGetText("Items", "Mythic Keystone")
    
    if not name or (not string.find(name, englishName) and not string.find(name, localizedName)) then 
        return 
    end
    
    if link ~= lastKeystoneLink then
        lastKeystoneLink = link
        lastMapName = "Loading..."
        lastTierLevel = "Loading..."
        AIO.Handle("AIO_Mythic", "RequestMapNameAndTier")
    end
    local line = _G[tooltip:GetName() .. "TextLeft2"]
    if line then
        local tierText = lastTierLevel and lastTierLevel ~= "Loading..." and ("+" .. lastTierLevel) or ""
        line:SetText("|cffa335ee" .. MythicGetText("UI", "Mythic") .. tierText .. " |r" .. (lastMapName or "Loading..."))
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
    GameTooltip:SetText(MythicGetText("UI", "Mythic+"))
    if self.hasVaultLoot then
        GameTooltip:AddLine(MythicGetText("UI", "There is loot in your Vault in Dalaran City"), 1, 1, 0)
    end
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
        return (AFFIXES[name].color or "|cffffffff") .. MythicGetText("UI", name) .. "|r"
    end

    local text = MythicGetText("UI", "This week's affixes:") .. " " ..
        colorize(affix1) .. ", " ..
        colorize(affix2) .. ", " ..
        colorize(affix3)

    MythicPlusFrame.affixText:SetText(text)
    
    MythicPlusFrame.currentAffixes = {affix1, affix2, affix3}

    for _, button in ipairs(MythicPlusFrame.affixButtons) do
        local name = button.affixName
        local label = button.label
        local isActive = name == affix1 or name == affix2 or name == affix3
        label:SetText((isActive and "|cff00ff00" or "") .. MythicGetText("UI", name))
    end
end

MythicPlusFrame = CreateFrame("Frame", "MythicPlusFrame", UIParent)
local frame = MythicPlusFrame

if localeDataReceived then
    UpdateLocalizedElements()
end

frame:SetSize(720, 480)
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

local paperBG = frame:CreateTexture(nil, "BACKGROUND")
paperBG:SetTexture("Interface\\MythicPlus\\textures\\Paper")
paperBG:SetAllPoints(frame)
paperBG:SetTexCoord(0, 1, 75/1024, (1024-75)/1024)

local borderSize = 167
local borderCornerTexCoordW = 167/256
local borderCornerTexCoordH = 168/256
local borderExpansion = math.floor(borderSize * 0.1)

local topLeftCorner = frame:CreateTexture(nil, "ARTWORK")
topLeftCorner:SetTexture("Interface\\MythicPlus\\textures\\Border")
topLeftCorner:SetSize(borderSize, borderSize)
topLeftCorner:SetPoint("TOPLEFT", frame, "TOPLEFT", -borderExpansion, borderExpansion)
topLeftCorner:SetTexCoord(0, borderCornerTexCoordW, 0, borderCornerTexCoordH)

local topRightCorner = frame:CreateTexture(nil, "ARTWORK")
topRightCorner:SetTexture("Interface\\MythicPlus\\textures\\Border")
topRightCorner:SetSize(borderSize, borderSize)
topRightCorner:SetPoint("TOPRIGHT", frame, "TOPRIGHT", borderExpansion, borderExpansion)
topRightCorner:SetTexCoord(borderCornerTexCoordW, 0, 0, borderCornerTexCoordH)

local bottomLeftCorner = frame:CreateTexture(nil, "ARTWORK")
bottomLeftCorner:SetTexture("Interface\\MythicPlus\\textures\\Border")
bottomLeftCorner:SetSize(borderSize, borderSize)
bottomLeftCorner:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -borderExpansion, -borderExpansion)
bottomLeftCorner:SetTexCoord(0, borderCornerTexCoordW, borderCornerTexCoordH, 0)

local bottomRightCorner = frame:CreateTexture(nil, "ARTWORK")
bottomRightCorner:SetTexture("Interface\\MythicPlus\\textures\\Border")
bottomRightCorner:SetSize(borderSize, borderSize)
bottomRightCorner:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", borderExpansion, -borderExpansion)
bottomRightCorner:SetTexCoord(borderCornerTexCoordW, 0, borderCornerTexCoordH, 0)

local topBorder = frame:CreateTexture(nil, "ARTWORK")
topBorder:SetTexture("Interface\\MythicPlus\\textures\\Border_Top")
topBorder:SetHeight(32)
topBorder:SetPoint("TOPLEFT", topLeftCorner, "TOPRIGHT", 0, 0)
topBorder:SetPoint("TOPRIGHT", topRightCorner, "TOPLEFT", 0, 0)
local topBorderWidth = 720 + (borderExpansion * 2) - (borderSize * 2)
local topTexCoordRight = math.min(1.0, topBorderWidth / 1024)
topBorder:SetTexCoord(0, topTexCoordRight, 0, 1)

local bottomBorder = frame:CreateTexture(nil, "ARTWORK")
bottomBorder:SetTexture("Interface\\MythicPlus\\textures\\Border_Bottom")
bottomBorder:SetHeight(32)
bottomBorder:SetPoint("BOTTOMLEFT", bottomLeftCorner, "BOTTOMRIGHT", 0, 0)
bottomBorder:SetPoint("BOTTOMRIGHT", bottomRightCorner, "BOTTOMLEFT", 0, 0)
local bottomTexCoordRight = math.min(1.0, topBorderWidth / 1024)
bottomBorder:SetTexCoord(0, bottomTexCoordRight, 0, 1)

local leftBorder = frame:CreateTexture(nil, "ARTWORK")
leftBorder:SetTexture("Interface\\MythicPlus\\textures\\Border_Left")
leftBorder:SetWidth(32)
leftBorder:SetPoint("TOPLEFT", topLeftCorner, "BOTTOMLEFT", -1, 0)
leftBorder:SetPoint("BOTTOMLEFT", bottomLeftCorner, "TOPLEFT", -1, 0)
local leftBorderHeight = 480 + (borderExpansion * 2) - (borderSize * 2)
local leftTexCoordBottom = math.min(1.0, leftBorderHeight / 1024)
leftBorder:SetTexCoord(0, 1, 0, leftTexCoordBottom)

local rightBorder = frame:CreateTexture(nil, "ARTWORK")
rightBorder:SetTexture("Interface\\MythicPlus\\textures\\Border_Right")
rightBorder:SetWidth(32)
rightBorder:SetPoint("TOPRIGHT", topRightCorner, "BOTTOMRIGHT", 1, 0)
rightBorder:SetPoint("BOTTOMRIGHT", bottomRightCorner, "TOPRIGHT", 1, 0)
local rightTexCoordBottom = math.min(1.0, leftBorderHeight / 1024)
rightBorder:SetTexCoord(0, 1, 0, rightTexCoordBottom)

table.insert(UISpecialFrames, "MythicPlusFrame")
frame:Hide()

local tabBackground = CreateFrame("Frame", nil, frame)
tabBackground:SetSize(120, 400)
tabBackground:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -20)

local function CreateStyledTabButton(parent, text, index, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(100, 32)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -20 - ((index - 1) * 35))
    button:SetText(text)
    button:SetNormalFontObject("GameFontNormal")
    button:GetNormalTexture():SetVertexColor(0.8, 0.2, 0.2, 1)
    button:GetHighlightTexture():SetVertexColor(1, 0.3, 0.3, 1)
    button:GetPushedTexture():SetVertexColor(0.6, 0.1, 0.1, 1)
    button.isSelected = false
    button:SetScript("OnClick", function()
        onClick(index)
    end)

    return button
end

local function CreateBannerTitle(parent, text, anchorPoint)
    local banner = parent:CreateTexture(nil, "OVERLAY")
    banner:SetTexture("Interface\\MythicPlus\\textures\\Banner")
    banner:SetSize(256, 64)
    banner:SetPoint("TOP", parent, "TOP", 40, anchorPoint)
    
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("CENTER", banner, "CENTER", 0, 0)
    title:SetText(text)
    title:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
    title:SetTextColor(1, 1, 1)
    
    return banner, title
end

local overviewBanner, overviewTitle = CreateBannerTitle(frame, MythicGetText("UI", "Overview"), 0)
frame.overviewTitle = overviewTitle
frame.overviewBanner = overviewBanner

local scoreBanner, scoreTitle = CreateBannerTitle(frame, MythicGetText("UI", "Score"), 0)
frame.scoreTitle = scoreTitle
frame.scoreBanner = scoreBanner
scoreBanner:Hide()
scoreTitle:Hide()

local leaderboardBanner, leaderboardTitle = CreateBannerTitle(frame, MythicGetText("UI", "Leaderboard"), 0)
frame.leaderboardTitle = leaderboardTitle
frame.leaderboardBanner = leaderboardBanner
leaderboardBanner:Hide()
leaderboardTitle:Hide()

local affixText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
affixText:SetPoint("TOP", overviewBanner, "BOTTOM", 0, -10)
affixText:SetJustifyH("CENTER")
affixText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
affixText:SetText(MythicGetText("UI", "This week's affixes:") .. " Loading...")
frame.affixText = affixText

local scoreText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
scoreText:SetPoint("TOP", scoreBanner, "BOTTOM", 0, -10)
scoreText:SetText("Score: Loading...")
frame.scoreText = scoreText
scoreText:Hide()

local affixNames = {
    "Enrage", "Rejuvenating", "Turtling", "Shamanism",
    "Magus", "Priest Empowered", "Demonism", "Falling Stars"
}

frame.affixButtons = {}
local buttonSize = 80
local buttonSpacing = 30
local columns = 4
local totalWidth = columns * buttonSize + (columns - 1) * buttonSpacing
local startX = -(totalWidth / 2) + 40

for i, name in ipairs(affixNames) do
    local button = CreateFrame("Button", nil, frame)
    button:SetSize(buttonSize, buttonSize)

    local row = math.floor((i - 1) / columns)
    local col = (i - 1) % columns
    button:SetPoint(
        "TOP",
        affixText,
        "BOTTOM",
        startX + col * (buttonSize + buttonSpacing),
        -40 - row * (buttonSize + buttonSpacing)
    )

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(AFFIXES[name].icon or "Interface\\Icons\\spell_nature_polymorph")

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOP", button, "BOTTOM", 0, -2)
    label:SetFont("Fonts\\FRIZQT__.TTF", 12, "")
    label:SetText(name)

    button.affixName = name
    button.label = label

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local color = AFFIXES[name].color or "|cffffffff"
        GameTooltip:SetText(color .. MythicGetText("UI", name) .. "|r")
        local description = AFFIXES[name].description
        if type(description) == "function" then
            description = description()
        end
        GameTooltip:AddLine(description or "", 1, 1, 1, true)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    frame.affixButtons[i] = button
end

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
    nameLabel:SetPoint("TOP", button, "BOTTOM", 0, 0)
    nameLabel:SetWidth(scoreButtonSize + 40)
    nameLabel:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    nameLabel:SetWordWrap(true)
    nameLabel:SetText(DUNGEONS[mapId].name or ("Map " .. mapId))
    nameLabel:SetJustifyH("CENTER")
    nameLabel:SetJustifyV("TOP")
    button.nameLabel = nameLabel

    button:Hide()
    frame.scoreButtons[i] = button
end

frame.podiums = {}
local podiumSpecs = {
    { height = 60, color = {0.8, 0.8, 0.8,}, x = -140 },
    { height = 90, color = {0.95, 0.84, 0.0}, x = 0 },
    { height = 40, color = {0.72, 0.45, 0.2}, x = 140 },
}

for i, spec in ipairs(podiumSpecs) do
    local podium = CreateFrame("Frame", nil, frame)
    podium:SetSize(135, spec.height)
    podium:SetPoint("BOTTOM", leaderboardBanner, "TOP", spec.x + 0, -200)

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

local tabs = {}
local function SetActiveTab(index)
    PlaySound("igMainMenuOptionCheckBoxOn")
    frame.currentTab = index
    
    for i, tab in ipairs(tabs) do
        if i == index then
            tab.isSelected = true
            tab:GetNormalTexture():SetVertexColor(1, 0.4, 0.4, 1)
            tab:GetHighlightTexture():SetVertexColor(1, 0.5, 0.5, 1)
        else
            tab.isSelected = false
            tab:GetNormalTexture():SetVertexColor(0.8, 0.2, 0.2, 1)
            tab:GetHighlightTexture():SetVertexColor(1, 0.3, 0.3, 1)
        end
    end

    local showOverview = index == 1
    local showScore = index == 2
    local showLeaderboard = index == 3
    if showOverview then
        frame.overviewBanner:Show()
        frame.overviewTitle:Show()
        frame.affixText:Show()
        for _, button in ipairs(frame.affixButtons) do
            button:Show()
        end
    else
        frame.overviewBanner:Hide()
        frame.overviewTitle:Hide()
        frame.affixText:Hide()
        for _, button in ipairs(frame.affixButtons) do
            button:Hide()
        end
    end
    if showScore then
        frame.scoreBanner:Show()
        frame.scoreTitle:Show()
        frame.scoreText:Show()
        for _, btn in ipairs(frame.scoreButtons) do
            btn:Show()
        end
        AIO.Handle("AIO_Mythic", "RequestTotalPoints")
    else
        frame.scoreBanner:Hide()
        frame.scoreTitle:Hide()
        frame.scoreText:Hide()
        for _, btn in ipairs(frame.scoreButtons) do
            btn:Hide()
        end
    end
    if showLeaderboard then
        frame.leaderboardBanner:Show()
        frame.leaderboardTitle:Show()
        for _, podium in ipairs(frame.podiums) do podium:Show() end
        for _, btn in ipairs(frame.leaderboardButtons) do btn:Show() end
        AIO.Handle("AIO_Mythic", "RequestLeaderboard")
    else
        frame.leaderboardBanner:Hide()
        frame.leaderboardTitle:Hide()
        for _, podium in ipairs(frame.podiums) do podium:Hide() end
        for _, btn in ipairs(frame.leaderboardButtons) do btn:Hide() end
    end

    if showOverview then
        AIO.Handle("AIO_Mythic", "RequestWeeklyAffixes")
    end
end

tabs[1] = CreateStyledTabButton(tabBackground, MythicGetText("UI", "Overview"), 1, SetActiveTab)
tabs[2] = CreateStyledTabButton(tabBackground, MythicGetText("UI", "Score"), 2, SetActiveTab)
tabs[3] = CreateStyledTabButton(tabBackground, MythicGetText("UI", "Leaderboard"), 3, SetActiveTab)

SetActiveTab(1)

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
                GameTooltip:SetText(MythicGetText("Dungeons", DUNGEONS[mapId].originalName))
                
                if top then
                    GameTooltip:AddLine(MythicGetText("UI", "Highest Score:"), 1, 1, 0)
                    GameTooltip:AddLine("  " .. top.name .. ": " .. top.score, 1, 1, 1)
                    if top.highestKey and top.highestKey > 0 then
                        local highestKeyText = MythicGetText("UI", "Highest Key +%d by:"):format(top.highestKey)
                        GameTooltip:AddLine(highestKeyText, 1, 1, 0)
                        if top.keyHolderNames and #top.keyHolderNames > 0 then
                            for _, memberName in ipairs(top.keyHolderNames) do
                                GameTooltip:AddLine("  " .. memberName, 0.8, 1, 0.8)
                            end
                        else
                            GameTooltip:AddLine("  " .. MythicGetText("UI", "Unknown"), 0.8, 1, 0.8)
                        end
                    else
                        GameTooltip:AddLine(MythicGetText("UI", "Highest Key: None completed in time"), 0.7, 0.7, 0.7)
                    end
                else
                    GameTooltip:AddLine(MythicGetText("UI", "No records available"), 0.7, 0.7, 0.7)
                end
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", GameTooltip_Hide)
        end
    end
end

local affixNames = {
    "Enrage", "Rejuvenating", "Turtling", "Shamanism",
    "Magus", "Priest Empowered", "Demonism", "Falling Stars"
}

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

SetActiveTab(1)

function MythicHandlers.StartMythicTimerGUI(_, mapId, tier, duration, bossNames, potentialGain, enemiesRequired)
    potentialGain = tonumber(potentialGain) or 0
    enemiesRequired = tonumber(enemiesRequired) or 50
    if type(bossNames) ~= "table" then bossNames = {} end
    local maxDeaths = (tier == 1) and 6 or 4
    WatchFrame:Hide(); WATCHFRAME_COLLAPSED = true

    local baseHeight = 140 + #bossNames * 18
    local frameHeight = (enemiesRequired > 0) and (baseHeight + 28) or baseHeight

    local timerFrame = CreateFrame("Frame", nil, UIParent)
    timerFrame:SetSize(320, frameHeight)
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

    local numAffixes = math.min(tier, 4)
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
                GameTooltip:SetText(affixName)
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
        lbl:SetTextColor(1, 0.82, 0)
        lbl.bossName = name
        bossLabels[i] = lbl
    end
    local enemyLabel, enemyProgressFrame, enemyPercentText
    if enemiesRequired > 0 then
        enemyLabel = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        enemyLabel:SetPoint("TOPLEFT", goldenFrame, "BOTTOMLEFT", 20, 10 - #bossNames*16)
        enemyLabel:SetText("0/1 " .. MythicGetText("UI", "Enemy Forces"))
        enemyLabel:SetTextColor(1, 0.82, 0)
        
        enemyProgressFrame = CreateFrame("StatusBar", nil, timerFrame)
        enemyProgressFrame:SetSize(200, 12)
        enemyProgressFrame:SetPoint("TOPLEFT", enemyLabel, "BOTTOMLEFT", 0, -10)
        enemyProgressFrame:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        enemyProgressFrame:SetStatusBarColor(0.2, 0.8, 0.2)
        enemyProgressFrame:SetMinMaxValues(0, 100)
        enemyProgressFrame:SetValue(0)
        
        local enemyProgressBorder = CreateFrame("Frame", nil, timerFrame, BackdropTemplateMixin and "BackdropTemplate")
        enemyProgressBorder:SetAllPoints(enemyProgressFrame)
        enemyProgressBorder:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        enemyProgressBorder:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
        
        enemyPercentText = enemyProgressFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        enemyPercentText:SetPoint("CENTER", enemyProgressFrame, "CENTER")
        enemyPercentText:SetText("0%")
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
        enemyLabel = enemyLabel,
        enemyProgressFrame = enemyProgressFrame,
        enemyPercentText = enemyPercentText,
        enemiesRequired = enemiesRequired,
        enemiesCurrent = 0
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

function MythicHandlers.UpdateVaultStatus(_, hasLoot)
    if hasLoot then
        mythicMiniButton.hasVaultLoot = true
        if not mythicMiniButton.glowTexture then
            mythicMiniButton.glowTexture = mythicMiniButton:CreateTexture(nil, "OVERLAY")
            mythicMiniButton.glowTexture:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
            mythicMiniButton.glowTexture:SetSize(48, 48)
            mythicMiniButton.glowTexture:SetPoint("CENTER")
            mythicMiniButton.glowTexture:SetBlendMode("ADD")
        end
        mythicMiniButton.glowTexture:Show()
    else
        mythicMiniButton.hasVaultLoot = false
        if mythicMiniButton.glowTexture then
            mythicMiniButton.glowTexture:Hide()
        end
    end
end

function MythicHandlers.QueryItemData(_, item1, item2, item3)
    if not MythicHiddenTooltip then
        MythicHiddenTooltip = CreateFrame("GameTooltip", "MythicHiddenTooltip", nil, "GameTooltipTemplate")
        MythicHiddenTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    end
    
    local function QueryItem(itemId)
        if itemId and itemId > 0 then
            MythicHiddenTooltip:SetHyperlink("item:"..itemId..":0:0:0:0:0:0:0")
            MythicHiddenTooltip:Show()
        end
    end
    
    if item1 and item1 > 0 then
        QueryItem(item1)
    end
    
    if item2 and item2 > 0 then
        local item2Timer = CreateFrame("Frame")
        item2Timer.elapsed = 0
        item2Timer:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= 0.1 then
                QueryItem(item2)
                self:SetScript("OnUpdate", nil)
            end
        end)
    end
    
    if item3 and item3 > 0 then
        local item3Timer = CreateFrame("Frame")
        item3Timer.elapsed = 0
        item3Timer:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= 0.2 then
                QueryItem(item3)
                self:SetScript("OnUpdate", nil)
            end
        end)
    end
end

function MythicHandlers.ShowVaultGUI(_, item1, item2, item3, tier1, tier2, tier3)
    AIO.Handle("AIO_Mythic", "QueryItemData", item1, item2, item3)
    if VaultFrame then
        VaultFrame:Hide()
    end
    
    VaultFrame = CreateFrame("Frame", "MythicVaultFrame", UIParent)
    VaultFrame:SetSize(600, 450)
    VaultFrame:SetPoint("CENTER")
    VaultFrame:SetToplevel(true)
    
    local vaultBG = VaultFrame:CreateTexture(nil, "BACKGROUND")
    vaultBG:SetTexture("Interface\\MythicPlus\\textures\\VaultFrame")
    vaultBG:SetAllPoints(VaultFrame)
    vaultBG:SetTexCoord(0, 1, 177/1024, (1024-177)/1024)

    local title = VaultFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", VaultFrame, "TOP", 0, -40)
    title:SetText(MythicGetText("UI", "Mythic+ Vault"))
    title:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
    title:SetTextColor(1, 0.82, 0)
    
    local subtitle = VaultFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -2)
    subtitle:SetText(MythicGetText("UI", "Choose item reward"))
    subtitle:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    subtitle:SetTextColor(0.9, 0.9, 0.9)
    
    local items = {item1, item2, item3}
    local tiers = {tier1, tier2, tier3}
    local selectedIndex = nil
    local itemButtons = {}
    
    for i = 1, 3 do
        if items[i] and items[i] > 0 then
            local button = CreateFrame("Button", nil, VaultFrame)
            button:SetSize(72, 72)
            button:SetPoint("TOP", subtitle, "BOTTOM", -190 + (i-1)*190, -80)
                      
            local icon = button:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(button)
            button.icon = icon
            
            local itemTexture = GetItemIcon(items[i])
            if itemTexture then
                icon:SetTexture(itemTexture)
            else
                icon:SetTexture("Interface\\Icons\\inv_misc_questionmark")
            end
            
            local tierLabel = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            tierLabel:SetPoint("TOP", button, "BOTTOM", 0, -5)
            tierLabel:SetText(MythicGetText("UI", "Tier") .. " " .. (tiers[i] or "?"))
            tierLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
            tierLabel:SetTextColor(1, 0.82, 0)
            button.tierLabel = tierLabel
                    
            button:SetScript("OnClick", function(self)
                selectedIndex = i
                
                for j, btn in ipairs(itemButtons) do
                    if j == i then
                        btn.icon:SetDesaturated(false)
                        btn.tierLabel:SetTextColor(1, 0.82, 0)
                    else
                        btn.icon:SetDesaturated(true)
                        btn.tierLabel:SetTextColor(0.5, 0.5, 0.5)
                    end
                end
                
                if VaultFrame.confirmButton then
                    VaultFrame.confirmButton:Enable()
                    VaultFrame.confirmButton:SetText("Confirm Selection")
                end
                
                if VaultFrame.selectionText then
                    local itemName, itemLink, itemRarity = GetItemInfo(items[i])
                    if itemLink then
                        VaultFrame.selectionText:SetText("Selected: " .. itemLink)
                    else
                        VaultFrame.selectionText:SetText("Selected: |cffffffff[Unknown Item]|r")
                    end
                    VaultFrame.selectionText:SetTextColor(1, 0.82, 0)
                end
            end)
            
            button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                
                local itemLink = select(2, GetItemInfo(items[i]))
                if itemLink then
                    GameTooltip:SetHyperlink(tostring(itemLink))
                else
                    print("Item link not found for item ID:", items[i])
                    local tooltipTimer = CreateFrame("Frame")
                    tooltipTimer.elapsed = 0
                    tooltipTimer:SetScript("OnUpdate", function(frame, elapsed)
                        frame.elapsed = frame.elapsed + elapsed
                        if frame.elapsed >= 0.1 then
                            local link = select(2, GetItemInfo(items[i]))
                            if link and GameTooltip:IsOwned(self) then
                                GameTooltip:SetHyperlink(link)
                            end
                            frame:SetScript("OnUpdate", nil)
                        end
                    end)
                end
                GameTooltip:Show()
                
                if selectedIndex ~= i then
                    if not self.highlightTexture then
                        self.highlightTexture = self:CreateTexture(nil, "HIGHLIGHT")
                        self.highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
                        self.highlightTexture:SetAllPoints(self)
                        self.highlightTexture:SetBlendMode("ADD")
                        self.highlightTexture:SetVertexColor(1, 1, 1, 0.3)
                    end
                    self.highlightTexture:Show()
                end
            end)
            button:SetScript("OnLeave", function(self)
                GameTooltip_Hide()
                if self.highlightTexture then
                    self.highlightTexture:Hide()
                end
            end)
            button:SetScript("OnMouseDown", function(self)
                icon:SetPoint("TOPLEFT", 1, -1)
                icon:SetPoint("BOTTOMRIGHT", 1, -1)
            end)
            button:SetScript("OnMouseUp", function(self)
                icon:SetAllPoints(self)
            end)
            itemButtons[i] = button
        end
    end
    
    local selectionText = VaultFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    selectionText:SetPoint("TOP", VaultFrame, "TOP", 0, -300)
    selectionText:SetText(MythicGetText("UI", "No item selected"))
    selectionText:SetTextColor(1, 0.82, 0)
    selectionText:SetFont("Fonts\\FRIZQT__.TTF", 14, "")
    VaultFrame.selectionText = selectionText
    
    local confirmButton = CreateFrame("Button", nil, VaultFrame, "UIPanelButtonTemplate")
    confirmButton:SetSize(140, 30)
    confirmButton:SetPoint("BOTTOM", VaultFrame, "BOTTOM", 0, 40)
    confirmButton:SetText(MythicGetText("UI", "Select an Item"))
    confirmButton:Disable()
    VaultFrame.confirmButton = confirmButton
    confirmButton:SetScript("OnClick", function(self)
        if selectedIndex then
            AIO.Handle("AIO_Mythic", "SelectVaultItem", selectedIndex)
            VaultFrame:Hide()
        end
    end)
    
    local cancelButton = CreateFrame("Button", nil, VaultFrame, "UIPanelButtonTemplate")
    cancelButton:SetSize(100, 30)
    cancelButton:SetPoint("BOTTOMLEFT", VaultFrame, "BOTTOMLEFT", 20, 40)
    cancelButton:SetText(MythicGetText("UI", "Cancel"))
    cancelButton:SetScript("OnClick", function(self)
        VaultFrame:Hide()
    end)
    VaultFrame:SetScript("OnHide", function(self)
        selectedIndex = nil
    end)
    VaultFrame:Show()
end

function MythicHandlers.CloseVaultGUI()
    if VaultFrame then
        VaultFrame:Hide()
    end
end

function MythicHandlers.UpdateEnemyForces(_, current, required, percentage, completed)
    local ui = MythicBossTimerUI
    if not ui or not ui.enemyLabel then return end
    ui.enemiesCurrent = current
    ui.enemiesRequired = required
    local completedText = completed and "1" or "0"
    ui.enemyLabel:SetText(fmt("%s/1 %s", completedText, MythicGetText("UI", "Enemy Forces")))
    ui.enemyProgressFrame:SetValue(percentage)
    ui.enemyPercentText:SetText(fmt("%.0f%%", percentage))
    if completed then
        ui.enemyLabel:SetTextColor(0.15, 0.76, 0.15)
    else
        ui.enemyLabel:SetTextColor(1, 0.82, 0)
    end
end

function MythicHandlers.ReceiveTotalPoints(_, totalPoints, dungeonScores)
    if not frame.scoreText then return end
    frame.scoreText:SetText(MythicGetText("UI", "Total Score:") .. " " .. string.format("%.2f", totalPoints or 0))
    for i, mapId in ipairs(DUNGEON_ORDER) do
        local button = frame.scoreButtons[i]
        if button and button.scoreLabel then
            local score = dungeonScores and dungeonScores[tostring(mapId)] or 0
            button.scoreLabel:SetText(tostring(score))
            if button.nameLabel and DUNGEONS[mapId] then
                button.nameLabel:SetText(MythicGetText("Dungeons", DUNGEONS[mapId].originalName))
            end
        end
    end
end