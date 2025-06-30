local AIO = AIO or require("AIO")
local MythicHandlers = AIO.AddHandlers("AIO_Mythic", {})

local MythicRewardConfig = {
    pets      = true,
    mounts    = true,
    equipment = false,
    spells    = false,
}

local MythicBosses = {
    [574] = { -- Utgarde Keep
        bosses = {23953, 24200, 24201, 23954}, final = 23954, names = {"Prince Keleseth", "Skarvald the Constructor", "Dalronn the Controller", "Ingvar the Plunderer"}, timer = 1100},
    [575] = { -- Utgarde Pinnacle
        bosses = {26668, 26687, 26693, 26861}, final = 26861, names = {"Svala Sorrowgrave", "Gortok Palehoof", "Skadi the Ruthless", "King Ymiron"}, timer = 1200},
    [576] = { -- The Nexus
        bosses = {26731, 26763, 26794, 26723}, final = 26723, names = {"Grand Magus Telestra", "Anomalus", "Ormorok the Tree-Shaper", "Keristrasza"}, timer = 1500},
    [599] = { -- Halls of Stone
        bosses = {27977, 27975, 27978}, final = 27978, names = {"Krystallus", "Maiden of Grief", "Sjonnir The Ironshaper"}, timer = 1800},
    [600] = { -- Drak'Tharon Keep
        bosses = {26630, 26631, 27483, 26632}, final = 26632, names = {"Trollgore", "Novos the Summoner", "King Dred", "The Prophet Tharon'ja"}, timer = 1500},
    [601] = { -- Azjol-Nerub
        bosses = {28684, 28921, 29120}, final = 29120, names = {"Krik'thir the Gatewatcher", "Hadronox", "Anub'arak"}, timer = 1800},
    [602] = { -- Halls of Lightning
        bosses = {28586, 28587, 28546, 28923}, final = 28923, names = {"General Bjarngrim", "Volkhan", "Ionar", "Loken"}, timer = 1800},
    [604] = { -- Gundrak
        bosses = {29304, 29573, 29305, 29932, 29306}, final = 29306, names = {"Slad'ran", "Drakkari Colossus", "Moorabi", "Eck the Ferocious", "Gal'darah"}, timer = 1500},
    [608] = { -- The Violet Hold
        bosses = {31134}, final = 31134, names = {"Cyanigosa"}, timer = 1500},
    [619] = { -- Ahn'kahet: The Old Kingdom
        bosses = {29309, 29308, 29310, 30258, 29311}, final = 29311, names = {"Elder Nadox", "Prince Taldaram", "Jedoga Shadowseeker", "Amanitar", "Herald Volazj"}, timer = 1500},
    [578] = { -- The Oculus
        bosses = {27654, 27447, 27655, 27656}, final = 27656, names = {"Drakos the Interrogator", "Varos Cloudstrider", "Mage-Lord Urom", "Ley-Guardian Eregos"}, timer = 1500},
    [595] = { -- The Culling of Stratholme
        bosses = {26529, 26530, 26532, 32273, 26533}, final = 26533, names = {"Meathook", "Salramm the Fleshcrafter", "Chrono-Lord Epoch", "Infinite Corruptor", "Mal'Ganis"}, timer = 1500},
    [650] = { -- Trial of the Champion
        bosses = {35451}, final = 35451, names = {"The Black Knight"}, timer = 690},
    [632] = { -- Forge of Souls
        bosses = {36497, 36502}, final = 36502, names = {"Bronjahm", "Devourer of Souls"}, timer = 1500},
    [658] = { -- Pit of Saron
        bosses = {36494, 36476, 36477, 36658}, final = 36658, names = {"Forgemaster Garfrost", "Ick", "Krick", "Scourgelord Tyrannus"}, timer = 1800},
    [668] = { -- Halls of Reflection
        bosses = {38112, 38113, 36954}, final = 36954, names = {"Falric", "Marwyn", "The Lich King"}, timer = 1800}
}

local DungeonNames = {
    [574] = "Utgarde Keep",
    [575] = "Utgarde Pinnacle",
    [576] = "The Nexus",
    [578] = "The Oculus",
    [595] = "The Culling of Stratholme",
    [599] = "Halls of Stone",
    [600] = "Drak'Tharon Keep",
    [601] = "Azjol-Nerub",
    [602] = "Halls of Lightning",
    [604] = "Gundrak",
    [608] = "The Violet Hold",
    [619] = "Ahn'kahet: The Old Kingdom",
    [632] = "The Forge of Souls",
    [650] = "Trial of the Champion",
    [658] = "Pit of Saron",
    [668] = "Halls of Reflection"
}

local mythicDungeonIds = {
    [574]=true, [575]=true, [576]=true, [578]=true, [595]=true,
    [599]=true, [600]=true, [601]=true, [602]=true, [604]=true,
    [608]=true, [619]=true, [632]=true, [650]=true, [658]=true, [668]=true
}

local PlayerRatingCache = {}
local PlayerKeysCache = {}
local PlayerNamesCache = {}
local WeeklyAffixesCache = nil
local ActiveRunsCache = {}
local LeaderboardCache = {
    topThree = {},
    dungeonTop = {},
    lastUpdate = 0
}
local LEADERBOARD_CACHE_DURATION = 900 -- 15 minutes

local function LoadPlayerCache(guid)
    local ratingQuery = CharDBQuery(string.format([[
        SELECT total_points, total_runs, claimed_tier1, claimed_tier2, claimed_tier3,
               `574`, `575`, `576`, `578`, `595`, `599`, `600`, `601`, `602`, `604`, `608`, `619`, `632`, `650`, `658`, `668`
        FROM character_mythic_rating WHERE guid = %d
    ]], guid))
    
    if ratingQuery then
        PlayerRatingCache[guid] = {
            total_points = ratingQuery:GetDouble(0),
            total_runs = ratingQuery:GetUInt32(1),
            claimed_tier1 = ratingQuery:GetUInt32(2),
            claimed_tier2 = ratingQuery:GetUInt32(3),
            claimed_tier3 = ratingQuery:GetUInt32(4),
            [574] = ratingQuery:GetUInt32(5),
            [575] = ratingQuery:GetUInt32(6),
            [576] = ratingQuery:GetUInt32(7),
            [578] = ratingQuery:GetUInt32(8),
            [595] = ratingQuery:GetUInt32(9),
            [599] = ratingQuery:GetUInt32(10),
            [600] = ratingQuery:GetUInt32(11),
            [601] = ratingQuery:GetUInt32(12),
            [602] = ratingQuery:GetUInt32(13),
            [604] = ratingQuery:GetUInt32(14),
            [608] = ratingQuery:GetUInt32(15),
            [619] = ratingQuery:GetUInt32(16),
            [632] = ratingQuery:GetUInt32(17),
            [650] = ratingQuery:GetUInt32(18),
            [658] = ratingQuery:GetUInt32(19),
            [668] = ratingQuery:GetUInt32(20)
        }
    else
        PlayerRatingCache[guid] = {
            total_points = 0,
            total_runs = 0,
            claimed_tier1 = 0,
            claimed_tier2 = 0,
            claimed_tier3 = 0,
            [574] = 0, [575] = 0, [576] = 0, [578] = 0, [595] = 0, [599] = 0,
            [600] = 0, [601] = 0, [602] = 0, [604] = 0, [608] = 0, [619] = 0,
            [632] = 0, [650] = 0, [658] = 0, [668] = 0
        }
    end
    
    local keyQuery = CharDBQuery(string.format("SELECT mapId FROM character_mythic_keys WHERE guid = %d", guid))
    if keyQuery then
        PlayerKeysCache[guid] = keyQuery:GetUInt32(0)
    else
        PlayerKeysCache[guid] = nil
    end
end

local function SavePlayerRatingCache(guid)
    local cache = PlayerRatingCache[guid]
    if not cache then return end
    
    CharDBExecute(string.format([[
        INSERT INTO character_mythic_rating 
        (guid, total_runs, total_points, claimed_tier1, claimed_tier2, claimed_tier3, 
         `574`, `575`, `576`, `578`, `595`, `599`, `600`, `601`, `602`, `604`, `608`, `619`, `632`, `650`, `658`, `668`, last_updated)
        VALUES (%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, FROM_UNIXTIME(%d))
        ON DUPLICATE KEY UPDATE
        total_runs = %d, total_points = %d, claimed_tier1 = %d, claimed_tier2 = %d, claimed_tier3 = %d,
        `574` = %d, `575` = %d, `576` = %d, `578` = %d, `595` = %d, `599` = %d, `600` = %d, `601` = %d, `602` = %d,
        `604` = %d, `608` = %d, `619` = %d, `632` = %d, `650` = %d, `658` = %d, `668` = %d, last_updated = FROM_UNIXTIME(%d)
    ]], 
    guid, cache.total_runs, cache.total_points, cache.claimed_tier1, cache.claimed_tier2, cache.claimed_tier3,
    cache[574], cache[575], cache[576], cache[578], cache[595], cache[599], cache[600], cache[601], cache[602],
    cache[604], cache[608], cache[619], cache[632], cache[650], cache[658], cache[668], os.time(),
    cache.total_runs, cache.total_points, cache.claimed_tier1, cache.claimed_tier2, cache.claimed_tier3,
    cache[574], cache[575], cache[576], cache[578], cache[595], cache[599], cache[600], cache[601], cache[602],
    cache[604], cache[608], cache[619], cache[632], cache[650], cache[658], cache[668], os.time()))
end

local function UpdateLeaderboardCache()
    local now = os.time()
    if now - LeaderboardCache.lastUpdate < LEADERBOARD_CACHE_DURATION then
        return
    end
    
    local top3Query = CharDBQuery([[ SELECT guid, total_points FROM character_mythic_rating ORDER BY total_points DESC LIMIT 3 ]])
    LeaderboardCache.topThree = {}
    if top3Query then
        repeat
            local guid = top3Query:GetUInt32(0)
            local points = top3Query:GetDouble(1)
            local name = PlayerNamesCache[guid] or "Unknown"
            if name == "Unknown" then
                local nameQ = CharDBQuery("SELECT name FROM characters WHERE guid = " .. guid)
                if nameQ then
                    name = nameQ:GetString(0)
                    PlayerNamesCache[guid] = name
                end
            end
            table.insert(LeaderboardCache.topThree, { name = name, points = points })
        until not top3Query:NextRow()
    end
    
    LeaderboardCache.dungeonTop = {}
    local dungeonIds = {574, 575, 576, 578, 595, 599, 600, 601, 602, 604, 608, 619, 632, 650, 658, 668}
    for _, dungeonId in ipairs(dungeonIds) do
        local query = CharDBQuery("SELECT guid, `" .. dungeonId .. "` FROM character_mythic_rating ORDER BY `" .. dungeonId .. "` DESC LIMIT 1")
        if query and query:GetUInt32(1) > 0 then
            local guid = query:GetUInt32(0)
            local score = query:GetUInt32(1)
            local name = PlayerNamesCache[guid] or "Unknown"
            if name == "Unknown" then
                local nameQ = CharDBQuery("SELECT name FROM characters WHERE guid = " .. guid)
                if nameQ then
                    name = nameQ:GetString(0)
                    PlayerNamesCache[guid] = name
                end
            end
            LeaderboardCache.dungeonTop[tostring(dungeonId)] = { name = name, score = score }
        end
    end
    
    LeaderboardCache.lastUpdate = now
end

local PEDESTAL_NPC_ENTRY = 900001
local KEY_IDS = {
    [1] = 900100,
    [2] = 900101,
    [3] = 900102
}
local WEEKLY_AFFIX_POOL = {
    { spell = 8599, name = "Enrage" },
    { spell = {48441, 61301}, name = "Rejuvenating" },
    { spell = 871, name = "Turtling" },
    { spell = {57662, 57621, 58738, 8515}, name = "Shamanism" },
    { spell = {43015, 43008, 43046, 57531, 12043}, name = "Magus" },
    { spell = {48161, 48066, 6346, 48168, 15286}, name = "Priest Empowered" },
    { spell = {47893, 50589}, name = "Demonism" },
    { spell = 53201, name = "Falling Stars" }
}

local function GetCurrentMythicResetDate()
    local now = os.time()
    local t = os.date("*t", now)

    local daysToSubtract = (t.wday - 4) % 7
    t.day = t.day - daysToSubtract
    t.hour = 6
    t.min = 0
    t.sec = 0

    return os.date("%Y-%m-%d", os.time(t))
end

local function LoadOrRollWeeklyAffixes()
    if WeeklyAffixesCache then return end
    
    local resetDate = GetCurrentMythicResetDate()
    local result = CharDBQuery(string.format("SELECT affix1, affix2, affix3 FROM character_mythic_weekly_affixes WHERE week_start = '%s'", resetDate))

    if result then
        local names = { result:GetString(0), result:GetString(1), result:GetString(2) }
        WeeklyAffixesCache = {}
        for _, name in ipairs(names) do
            for _, affix in ipairs(WEEKLY_AFFIX_POOL) do
                if affix.name == name then
                    table.insert(WeeklyAffixesCache, affix)
                    break
                end
            end
        end
    else
        local shuffled = {}
        for i = 1, #WEEKLY_AFFIX_POOL do shuffled[i] = WEEKLY_AFFIX_POOL[i] end
        for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end
        local affix1, affix2, affix3 = shuffled[1], shuffled[2], shuffled[3]

        WeeklyAffixesCache = { affix1, affix2, affix3 }

        CharDBExecute(string.format([[
            INSERT INTO character_mythic_weekly_affixes (week_start, affix1, affix2, affix3)
            VALUES ('%s', '%s', '%s', '%s')
        ]], resetDate, affix1.name, affix2.name, affix3.name))
    end
end

LoadOrRollWeeklyAffixes()

local penaltyPerDeath = 10
local RATING_CAP = 2000
local fmt, floor = string.format, math.floor

if MYTHIC_BOSS_KILL_TRACKER == nil then MYTHIC_BOSS_KILL_TRACKER = {} end
if MYTHIC_FLAG_TABLE == nil then MYTHIC_FLAG_TABLE = {} end
if MYTHIC_AFFIXES_TABLE == nil then MYTHIC_AFFIXES_TABLE = {} end
if MYTHIC_LOOP_HANDLERS == nil then MYTHIC_LOOP_HANDLERS = {} end
if MYTHIC_REWARD_CHANCE_TABLE == nil then MYTHIC_REWARD_CHANCE_TABLE = {} end

local MythicLootTable = {}

local function LoadMythicLootTable()
    MythicLootTable = {}
    local q = WorldDBQuery("SELECT itemid, itemname, amount, type, faction, chanceOnTier, chancePercent, additionalID, additionalType FROM world_mythic_loot")
    if q then
        repeat
            table.insert(MythicLootTable, {
                itemid         = q:GetUInt32(0),
                itemname       = q:GetString(1),
                amount         = q:GetUInt32(2),
                type           = q:GetString(3),
                faction        = q:GetString(4),
                chanceOnTier   = q:GetInt32(5),
                chancePercent  = q:GetFloat(6),
                additionalID   = q:IsNull(7) and nil or q:GetUInt32(7),
                additionalType = q:IsNull(8) and nil or q:GetString(8),
            })
        until not q:NextRow()
    end
    print("[Mythic+] Loaded " .. #MythicLootTable .. " mythic+ loot entries.")
end

LoadMythicLootTable()

local function GetAffixSet(tier)
    local affixes = {}
    for i = 1, tier do
        local affix = WeeklyAffixesCache[i]
        if affix then
            if type(affix.spell) == "table" then
                for _, s in ipairs(affix.spell) do
                    table.insert(affixes, s)
                end
            else
                table.insert(affixes, affix.spell)
            end
        end
    end
    return affixes
end

local function GetAffixNameSet(tier)
    local names = {}
    for i = 1, tier do
        local affix = WeeklyAffixesCache[i]
        if affix then
            table.insert(names, affix.name)
        end
    end
    return table.concat(names, ", ")
end

local function LeaveDungeonMap(event, player)
    local mapId = player:GetMapId()
    if not mythicDungeonIds[mapId] then
        AIO.Handle(player, "AIO_Mythic", "KillMythicTimerGUI")
    end
end

local function GetRandomMythicMapId()
    local ids = {574, 575, 576, 578, 595, 599, 600, 601, 602, 604, 608, 619, 632, 650, 658, 668}
    return ids[math.random(1, #ids)]
end

local function PlayerHasAnyKeystone(player)
    return player:HasItem(900100) or player:HasItem(900101) or player:HasItem(900102)
end

local function IsRunActive(instanceId)
    return MYTHIC_FLAG_TABLE[instanceId] == true
end

local function HasValidKeyForCurrentDungeon(player)
    local guid = player:GetGUIDLow()
    local mapId = player:GetMapId()
    return PlayerKeysCache[guid] == mapId
end

local function CalculatePotentialGain(currentRating, tier)
    local baseline, cap1, cap2, maxRating = 100, 800, 1600, 2000

    if tier == 1 then
        if currentRating >= cap1 then return 0 end
        local gain = baseline
        if currentRating + gain > cap1 then gain = cap1 - currentRating end
        return gain
    elseif tier == 2 then
        if currentRating >= cap2 then return 0 end
        local gain = baseline * 2
        if currentRating + gain > cap2 then gain = cap2 - currentRating end
        return gain
    elseif tier >= 3 then
        if currentRating < cap1 then
            return baseline * 3
        elseif currentRating < cap2 then
            return baseline * 2
        elseif currentRating < maxRating then
            local gain = baseline
            if currentRating + gain > maxRating then
                gain = maxRating - currentRating
            end
            return gain
        else
            return 0
        end
    end
    return 0
end

local function CalculateBonus(currentRating, runTier)
    if currentRating < 800 then
        if runTier == 2 then
            return 50
        elseif runTier >= 3 then
            return 80
        end
    elseif currentRating >= 800 and currentRating < 1600 then
        if runTier >= 3 then
            return 50
        end
    end
    return 0
end

local function RecalculateTotalPoints(guid)
    local cache = PlayerRatingCache[guid]
    if not cache then return end
    
    local dungeonColumns = {574, 575, 576, 578, 595, 599, 600, 601, 602, 604, 608, 619, 632, 650, 658, 668}
    local total = 0
    
    for _, mapId in ipairs(dungeonColumns) do
        total = total + (cache[mapId] or 0)
    end
    
    local avg = total / #dungeonColumns
    cache.total_points = avg
    
    SavePlayerRatingCache(guid)
end

local function ApplyAuraToNearbyCreatures(player, affixes)
    local seen = {}
    local map = player:GetMap()
    if not map then
        return
    end

    local MYTHIC_SCAN_RADIUS = 240
    local count = 0

    local creatures = player:GetCreaturesInRange(MYTHIC_SCAN_RADIUS, nil, 1, 1)
    for _, creature in ipairs(creatures) do
        local guid = creature:GetGUIDLow()
        local faction = creature:GetFaction()

        if not seen[guid]
            and creature:IsAlive()
            and creature:IsInWorld()
            and not creature:IsPlayer()
            and faction ~= 2 and faction ~= 3 and faction ~= 4
            and faction ~= 31 and faction ~= 35 and faction ~= 188 and faction ~= 1629
            and faction ~= 114 and faction ~= 115 and faction ~= 1
        then
            seen[guid] = true
            count = count + 1
            for _, spellId in ipairs(affixes) do
                if not creature:HasAura(spellId) then
                    creature:AddAura(spellId, creature)
                end
            end
        end
    end
end

local function DowngradeKeystoneOnFail(player, tier)
    if tier == 3 then
        if not PlayerHasAnyKeystone(player) then player:AddItem(900101, 1) end
        player:SendBroadcastMessage("[Mythic+] Your key has been downgraded.")
    elseif tier == 2 then
        if not PlayerHasAnyKeystone(player) then player:AddItem(900100, 1) end
        player:SendBroadcastMessage("[Mythic+] Your key has been downgraded.")
    end
end

local function SetEndOfRunUnitFlags(player)
    if not player or not player:IsInWorld() then return end
    local map = player:GetMap()
    if not map then return end
    local instanceId = map:GetInstanceId()

    local UNIT_FLAG_NOT_SELECTABLE = 33554432
    local UNIT_FLAG_NON_ATTACKABLE = 2
    local UNIT_FLAG_IMMUNE_TO_PC = 256
    local UNIT_FLAG_IMMUNE_TO_NPC = 512

    local flagsToAdd = UNIT_FLAG_NOT_SELECTABLE + UNIT_FLAG_NON_ATTACKABLE + UNIT_FLAG_IMMUNE_TO_PC + UNIT_FLAG_IMMUNE_TO_NPC

    local function bitwise_or(a, b)
        local result, bitval = 0, 1
        while a > 0 or b > 0 do
            if (a % 2 == 1) or (b % 2 == 1) then
                result = result + bitval
            end
            a = math.floor(a / 2)
            b = math.floor(b / 2)
            bitval = bitval * 2
        end
        return result
    end

    local creatures = player:GetCreaturesInRange(2000, nil, 1, 1)
    for _, creature in ipairs(creatures) do
        local cMap = creature:GetMap()
        if cMap and cMap:GetInstanceId() == instanceId then
            local currentFlags = creature:GetUnitFlags() or 0
            local newFlags = bitwise_or(currentFlags, flagsToAdd)
            if newFlags ~= currentFlags then
                creature:SetUnitFlags(newFlags)
            end
        end
    end
end

local function StartAuraLoop(player, instanceId, mapId, affixes, interval)
    local guid = player:GetGUIDLow()
    if MYTHIC_LOOP_HANDLERS[instanceId] then
        RemoveEventById(MYTHIC_LOOP_HANDLERS[instanceId])
    end
    local eventId = CreateLuaEvent(function()
        local p = GetPlayerByGUID(guid)
        if not p then return end
        if not MYTHIC_FLAG_TABLE[instanceId] then return end
        if p:GetMapId() ~= mapId then
            local runData = ActiveRunsCache[instanceId]
            if runData and runData.run_id then
                CharDBExecute("UPDATE character_mythic_history SET completed = 2 WHERE run_id = " .. runData.run_id)
                p:SendBroadcastMessage("[Mythic+] You left the dungeon. The run is over.")
                local validPlayer = GetPlayerByGUID(guid)
                if validPlayer and validPlayer:IsInWorld() then
                    SetEndOfRunUnitFlags(validPlayer)
                end
                DowngradeKeystoneOnFail(p, runData.tier)
            end
            AIO.Handle(p, "AIO_Mythic", "KillMythicTimerGUI")
            MYTHIC_FLAG_TABLE[instanceId] = nil
            MYTHIC_AFFIXES_TABLE[instanceId] = nil
            MYTHIC_LOOP_HANDLERS[instanceId] = nil
            MYTHIC_REWARD_CHANCE_TABLE[instanceId] = nil
            ActiveRunsCache[instanceId] = nil
            if eventId ~= nil then
                RemoveEventById(eventId)
            end
            return
        end

        local bossData = MythicBosses[mapId]
        if bossData then
            local runData = ActiveRunsCache[instanceId]
            if runData then
                local now = os.time()
                local elapsed = now - runData.start_time
                if elapsed >= (bossData.timer or 900) then
                    CharDBExecute("UPDATE character_mythic_history SET completed = 2 WHERE run_id = " .. runData.run_id)
                    local validPlayer = GetPlayerByGUID(guid)
                    if validPlayer and validPlayer:IsInWorld() then
                        SetEndOfRunUnitFlags(validPlayer)
                    end
                    local group = p:GetGroup()
                    local members = group and group:GetMembers() or { p }
                    for _, member in ipairs(members) do
                        if member:IsInWorld() and member:GetMapId() == mapId then
                            AIO.Handle(member, "AIO_Mythic", "StopMythicTimerGUI", 0)
                            DowngradeKeystoneOnFail(member, runData.tier)
                        end
                    end
                    MYTHIC_FLAG_TABLE[instanceId] = nil
                    MYTHIC_AFFIXES_TABLE[instanceId] = nil
                    MYTHIC_LOOP_HANDLERS[instanceId] = nil
                    MYTHIC_REWARD_CHANCE_TABLE[instanceId] = nil
                    ActiveRunsCache[instanceId] = nil
                    if eventId ~= nil then
                        RemoveEventById(eventId)
                    end
                    return
                end
            end
        end

        ApplyAuraToNearbyCreatures(p, affixes)
    end, interval, 0)
    MYTHIC_LOOP_HANDLERS[instanceId] = eventId
end

function Pedestal_OnGossipHello(_, player, creature)
    if not PlayerHasAnyKeystone(player) then
        player:SendBroadcastMessage("[Mythic+] You do not have a Mythic Keystone.")
        player:GossipComplete()
        return
    end

    if not HasValidKeyForCurrentDungeon(player) then
        player:SendBroadcastMessage("[Mythic+] Your keystone does not appear to fit.")
        player:GossipComplete()
        return
    end

    player:GossipClearMenu()

    local keyTier, keyId
    if player:HasItem(900100) then
        keyTier = 1
        keyId = 900100
    elseif player:HasItem(900101) then
        keyTier = 2
        keyId = 900101
    elseif player:HasItem(900102) then
        keyTier = 3
        keyId = 900102
    end

    if keyTier then
        player:GossipMenuAddItem(5, string.format("Insert Keystone (Tier %d)", keyTier), 0, 100 + keyTier, false, "", 0)
        player:GossipMenuAddItem(2, "Step away", 0, 999)
        player:GossipSendMenu(1, creature)
    else
        player:SendBroadcastMessage("[Mythic+] You do not have a Mythic Keystone.")
        player:GossipComplete()
    end
end

function Pedestal_OnGossipSelect(_, player, _, _, intid)
    if not HasValidKeyForCurrentDungeon(player) then
        player:SendBroadcastMessage("[Mythic+] This keystone is not for this dungeon.")
        player:GossipComplete()
        return
    end

    if intid == 999 then 
        player:GossipComplete()
        return 
    end

    if intid >= 100 and intid <= 103 then
        local tier = intid - 100
        local keyId = KEY_IDS[tier]
    
        if not player:HasItem(keyId) then
            player:SendBroadcastMessage("[Mythic+] You do not have the required Tier " .. tier .. " Keystone.")
            player:GossipComplete()
            return
        end

        local map = player:GetMap()
        if not map or map:GetDifficulty() == 0 then
            player:SendBroadcastMessage("[Mythic+] Keystones cannot be used in Normal mode dungeons.")
            player:GossipComplete()
            return
        end

        local guid = player:GetGUIDLow()
        local now = os.time()
        local mapId = player:GetMapId()
        local instanceId = map:GetInstanceId()
        local group = player:GetGroup()
        local members = group and group:GetMembers() or {player}
        local today = os.date("%Y-%m-%d")
        local affixes = GetAffixSet(tier)
        local affixNames = {}

        for i = 1, tier do
            local affix = WeeklyAffixesCache[i]
            if affix then
                table.insert(affixNames, affix.name)
            end
        end

        local safeAffixNames = table.concat(affixNames, ", "):gsub("'", "''")
        
        for _, member in ipairs(members) do
            if member:IsInWorld() and member:GetMapId() == mapId then
                local mguid = member:GetGUIDLow()
                if not PlayerRatingCache[mguid] then
                    LoadPlayerCache(mguid)
                end
                
                local cache = PlayerRatingCache[mguid]
                if tier == 1 then cache.claimed_tier1 = cache.claimed_tier1 + 1
                elseif tier == 2 then cache.claimed_tier2 = cache.claimed_tier2 + 1
                elseif tier == 3 then cache.claimed_tier3 = cache.claimed_tier3 + 1
                end
                
                SavePlayerRatingCache(mguid)
            end
        end

        local guids = {}
        for i = 1, 5 do guids[i] = 0 end
        for i, member in ipairs(members) do
            if i > 5 then break end
            guids[i] = member:GetGUIDLow()
        end

        CharDBExecute(string.format([[ 
            INSERT INTO character_mythic_history (member_1, member_2, member_3, member_4, member_5, date, mapId, instanceId, tier, start_time, completed, deaths, affixes)
            VALUES (%d, %d, %d, %d, %d, '%s', %d, %d, %d, FROM_UNIXTIME(%d), 0, 0, '%s');
        ]], guids[1], guids[2], guids[3], guids[4], guids[5], today, mapId, instanceId, tier, now, safeAffixNames))
        
        local runIdQuery = CharDBQuery("SELECT LAST_INSERT_ID()")
        local runId = runIdQuery and runIdQuery:GetUInt32(0) or 0
        
        ActiveRunsCache[instanceId] = {
            guid = guid,
            mapId = mapId,
            tier = tier,
            start_time = now,
            deaths = 0,
            run_id = runId,
            members = {}
        }
        
        for _, member in ipairs(members) do
            if member:IsInWorld() and member:GetMapId() == mapId then
                table.insert(ActiveRunsCache[instanceId].members, member:GetGUIDLow())
            end
        end

        MYTHIC_FLAG_TABLE[instanceId] = false
        MYTHIC_AFFIXES_TABLE[instanceId] = affixes
        MYTHIC_REWARD_CHANCE_TABLE[instanceId] = tier == 1 and 1.5 or tier == 2 and 2.0 or 5.0

        local cache = PlayerRatingCache[guid]
        local currentRating = cache and cache[mapId] or 0
        local potentialGain = CalculatePotentialGain(currentRating, tier)

        player:RemoveItem(keyId, 1)
        PlayerKeysCache[guid] = nil
        CharDBExecute(string.format("DELETE FROM character_mythic_keys WHERE guid = %d AND mapId = %d", guid, mapId))

        local map_x, map_y, map_z, map_o = GetMapEntrance(mapId)
        local memberGuids = {}
        for _, member in ipairs(members) do
            if member:IsInWorld() and member:GetMapId() == mapId then
                table.insert(memberGuids, member:GetGUID())
                member:NearTeleport(map_x, map_y, map_z, map_o)
                member:SetRooted(true)
            end
        end

        local dungeoncreatures = player:GetCreaturesInRange(2000, nil, 0, 2)
        for _, creature in ipairs(dungeoncreatures) do
            creature:Respawn()
        end

        for _, guid in ipairs(memberGuids) do
            local member = GetPlayerByGUID(guid)
            if member and member:IsInWorld() and member:GetMapId() == mapId then
                AIO.Handle(member, "AIO_Mythic", "StartCountdown", 10)
            end
        end

        local starterGuid = player:GetGUID()

        CreateLuaEvent(function()
            local starter = GetPlayerByGUID(starterGuid)
            if not starter then return end

            for _, guid in ipairs(memberGuids) do
                local member = GetPlayerByGUID(guid)
                if member and member:IsInWorld() and member:GetMapId() == mapId then
                    member:SetRooted(false)
                end
            end
            MYTHIC_FLAG_TABLE[instanceId] = true
            ApplyAuraToNearbyCreatures(starter, affixes)
            StartAuraLoop(starter, instanceId, mapId, affixes, 6000)
            StartBossScanLoop(starter, instanceId, mapId, tier)
            local bossData = MythicBosses[mapId]
            if bossData then
                local tracker = { remaining = {}, indexMap = {}, tier = tier }
                for idx, entry in ipairs(bossData.bosses) do
                    tracker.remaining[#tracker.remaining + 1] = entry
                    tracker.indexMap[entry]                   = idx
                end
                MYTHIC_BOSS_KILL_TRACKER[instanceId] = tracker

                for _, guid in ipairs(memberGuids) do
                    local member = GetPlayerByGUID(guid)
                    if member and member:IsInWorld() and member:GetMapId() == mapId then
                        AIO.Handle(member, "AIO_Mythic", "StartMythicTimerGUI", mapId, tier, bossData.timer or 900, bossData.names or {}, potentialGain)
                    end
                end
            end
        end, 10000, 1)

        player:GossipComplete()
    end
end

function StartBossScanLoop(player, instanceId, mapId, tier)
    local bosses = MythicBosses[mapId]
    if not bosses or not bosses.bosses then
        print("[Mythic+][Error] No boss data for mapId: " .. mapId)
        return
    end

    MYTHIC_BOSS_KILL_TRACKER[instanceId] = {
        remaining = {},
        indexMap = {},
        tier = tier
    }

    for idx, entry in ipairs(bosses.bosses) do
        table.insert(MYTHIC_BOSS_KILL_TRACKER[instanceId].remaining, entry)
        MYTHIC_BOSS_KILL_TRACKER[instanceId].indexMap[entry] = idx
    end
end

local function MythicBossKillCheck(event, player, killed)
    local map = player:GetMap()
    if not map then return end
    local mapId      = map:GetMapId()
    local instanceId = map:GetInstanceId()

    if not IsRunActive(instanceId) then return end

    local NO_CORPSE_REMOVE_IDS = {
        [26692] = true, -- 'Ymirjar Harpooner' in Utgarde Pinnacle // would not spawn harpoons otherwise
        [28585] = true, -- 'Slag' in Halls of Lightning // respawn would be too fast
    }

    local entry   = killed:GetEntry()
    local tracker = MYTHIC_BOSS_KILL_TRACKER[instanceId]
    if not tracker then return end

    if not NO_CORPSE_REMOVE_IDS[entry] then
        killed:RemoveCorpse()
    end

    for i, bossEntry in ipairs(tracker.remaining) do
        if bossEntry == entry then
            table.remove(tracker.remaining, i)
            local bossIndex = tracker.indexMap[entry]
            local group   = player:GetGroup()
            local members = group and group:GetMembers() or { player }
            for _, member in ipairs(members) do
                if member:IsInWorld() and member:GetMapId() == mapId then
                    AIO.Handle(member, "AIO_Mythic", "MarkBossKilled", mapId, bossIndex)
                end
            end
            break
        end
    end

    if #tracker.remaining == 0 then
        local group   = player:GetGroup()
        local members = group and group:GetMembers() or { player }

        local now = os.time()
        local bossData = MythicBosses[mapId]
        local timerTotal = bossData and bossData.timer or 900

        local runData = ActiveRunsCache[instanceId]
        local startTimeRaw = runData and runData.start_time or now
        local deaths = runData and runData.deaths or 0

        local duration      = math.max(0, now - startTimeRaw)
        local remainingTime = math.max(0, timerTotal - duration)

        for _, member in ipairs(members) do
            if member:IsInWorld() and member:GetMapId() == mapId then
                AwardMythicPoints(member, tracker.tier, duration, deaths, remainingTime)
                SetEndOfRunUnitFlags(member)
            end
        end

        MYTHIC_BOSS_KILL_TRACKER[instanceId] = nil
        MYTHIC_FLAG_TABLE[instanceId]         = nil
        ActiveRunsCache[instanceId] = nil
    end
end

local function MythicPlayerDeath(event, killer, killed)
    local map = killed:GetMap()
    if not map or map:GetDifficulty() == 0 then return end

    local instanceId = map:GetInstanceId()
    local runData = ActiveRunsCache[instanceId]
    if not runData then return end

    runData.deaths = runData.deaths + 1
    local newDeaths = runData.deaths
    local tier = runData.tier

    CharDBExecute("UPDATE character_mythic_history SET deaths = " .. newDeaths .. " WHERE run_id = " .. runData.run_id)

    local penalty = newDeaths * penaltyPerDeath

    local group   = killed:GetGroup()
    local members = group and group:GetMembers() or { killed }
    for _, member in ipairs(members) do
        if member:IsInWorld() and member:GetMapId() == map:GetMapId() then
            AIO.Handle(member, "AIO_Mythic", "UpdateMythicScore", penalty, newDeaths)
        end
    end

    local limit = (tier == 1) and 6 or 4
    if newDeaths >= limit then
        CharDBExecute("UPDATE character_mythic_history SET completed = 2 WHERE run_id = " .. runData.run_id)
        for _, member in ipairs(members) do
            if member:IsInWorld() and member:GetMapId() == map:GetMapId() then
                AIO.Handle(member, "AIO_Mythic", "StopMythicTimerGUI", 0)
                DowngradeKeystoneOnFail(member, tier)
            end
        end

        MYTHIC_FLAG_TABLE[instanceId]    = nil
        MYTHIC_AFFIXES_TABLE[instanceId] = nil
        MYTHIC_REWARD_CHANCE_TABLE[instanceId] = nil
        ActiveRunsCache[instanceId] = nil
        if MYTHIC_LOOP_HANDLERS[instanceId] then
            RemoveEventById(MYTHIC_LOOP_HANDLERS[instanceId])
            MYTHIC_LOOP_HANDLERS[instanceId] = nil
        end
    end
end

local function isTierEligible(chanceOnTier, tier)
    if chanceOnTier == 0 then return true end
    if chanceOnTier > 0 then return tier >= chanceOnTier end
    if chanceOnTier < 0 then return tier == -chanceOnTier end
    return false
end

local function TryRewardMythicLoot(player, tier)
    local class = player:GetClass()
    local faction = player:GetTeam() == 67 and "A" or (player:GetTeam() == 469 and "H" or "N")
    local eligible = {}

    for _, loot in ipairs(MythicLootTable) do
        if loot.type == "pet"   and not MythicRewardConfig.pets      then goto continue end
        if loot.type == "mount" and not MythicRewardConfig.mounts    then goto continue end
        if loot.type == "gear"  and not MythicRewardConfig.equipment then goto continue end
        if loot.type == "spell" and not MythicRewardConfig.spells    then goto continue end
        if not isTierEligible(loot.chanceOnTier, tier) then goto continue end
        if loot.faction ~= "N" and loot.faction ~= faction then goto continue end
        if loot.type == "gear" then
            local itemQ = WorldDBQuery("SELECT class, subclass, InventoryType FROM item_template WHERE entry = " .. loot.itemid)
            if not itemQ then goto continue end
            local itemClass = itemQ:GetUInt32(0)
            local itemSubClass = itemQ:GetUInt32(1)
            local invType = itemQ:GetUInt32(2)
            local classArmor = {
                [1] = 4, [2] = 4, [6] = 4, [11]= 2, [3] = 3, [7] = 3, [4] = 2, [8] = 1, [5] = 1, [9] = 1,
            }
            local allowed = false
            if itemClass == 4 then
                local prof = classArmor[class]
                if prof and itemSubClass == prof then
                    if invType ~= 11 and invType ~= 12 and invType ~= 13 and invType ~= 14 and invType ~= 23 then
                        allowed = true
                    end
                end
            end
            if not allowed then goto continue end
        end

        table.insert(eligible, loot)
        ::continue::
    end

    if #eligible == 0 then return end

    local reward = eligible[math.random(1, #eligible)]
    if math.random() * 100 <= reward.chancePercent then
        if reward.type == "gear" or reward.type == "pet" or reward.type == "mount" then
            player:AddItem(reward.itemid, reward.amount)
            player:SendBroadcastMessage("[Mythic+] Reward: " .. reward.itemname)
        elseif reward.type == "spell" then
            player:LearnSpell(reward.itemid)
            player:SendBroadcastMessage("[Mythic+] Reward: Spell learned!")
        end
        if reward.additionalID and reward.additionalType then
            if reward.additionalType == "item" then
                player:AddItem(reward.additionalID, 1)
            elseif reward.additionalType == "spell" then
                player:LearnSpell(reward.additionalID)
            elseif reward.additionalType == "skill" then
                player:AdvanceSkill(reward.additionalID, 1)
            end
        end
    end
end

function AwardMythicPoints(player, tier, duration, deaths, remainingTime)
    local now        = os.time()
    local map        = player:GetMap()
    if not map then return end
    local mapId      = map:GetMapId()
    local instanceId = map:GetInstanceId()
    local guid       = player:GetGUIDLow()

    local cache = PlayerRatingCache[guid]
    if not cache then
        LoadPlayerCache(guid)
        cache = PlayerRatingCache[guid]
    end

    local previous = cache[mapId] or 0
    local c1, c2, c3 = cache.claimed_tier1, cache.claimed_tier2, cache.claimed_tier3

    local potentialGain = CalculatePotentialGain(previous, tier)
    local bonus = 0
    if potentialGain > 0 then
        bonus = CalculateBonus(previous, tier) + math.floor(remainingTime / 30) * 2
    end
    local penalty      = deaths * penaltyPerDeath
    local runGain      = math.max(0, potentialGain + bonus - penalty)
    local newRating    = math.min(previous + runGain, RATING_CAP)

    if tier == 1 then c1 = c1 + 1
    elseif tier == 2 then c2 = c2 + 1
    elseif tier == 3 then c3 = c3 + 1
    end

    cache[mapId] = newRating
    cache.total_runs = cache.total_runs + 1
    cache.claimed_tier1 = c1
    cache.claimed_tier2 = c2
    cache.claimed_tier3 = c3

    SavePlayerRatingCache(guid)

    local runData = ActiveRunsCache[instanceId]
    if runData and runData.run_id then
        CharDBExecute(string.format([[ 
            UPDATE character_mythic_history
               SET completed = 1,
                   end_time  = FROM_UNIXTIME(%d),
                   duration  = %d
             WHERE run_id = %d;
        ]], now, duration, runData.run_id))
    end

    AIO.Handle(player, "AIO_Mythic", "StopMythicTimerGUI", remainingTime)
    AIO.Handle(player, "AIO_Mythic", "FinalizeMythicScore", penalty, deaths, bonus)

    local dfmt = string.format("%02d:%02d", math.floor(duration/60), duration%60)
    player:SendBroadcastMessage(string.format(
      "[Mythic+] Tier %d completed in %s.\nNew Rating: %d (|cff00ff00+%d|r = +%d potential +%d bonus -%d penalty)",
      tier, dfmt, newRating, runGain, potentialGain, bonus, penalty
    ))

    local nextKey = nil
    if tier == 1 then nextKey = 900101
    elseif tier == 2 then nextKey = 900102
    end
    if nextKey and not PlayerHasAnyKeystone(player) then
        player:AddItem(nextKey, 1)
    end

    RecalculateTotalPoints(guid)
    TryRewardMythicLoot(player, tier)
    
    LeaderboardCache.lastUpdate = 0
end

function BindKeystoneToDungeon(event, player, item, count)
    local guid = player:GetGUIDLow()
    local newMapId = GetRandomMythicMapId()
    
    if item:GetEntry() == 900100 or item:GetEntry() == 900101 or item:GetEntry() == 900102 then
        PlayerKeysCache[guid] = newMapId
        
        CharDBExecute(string.format("REPLACE INTO character_mythic_keys (guid, mapId) VALUES (%d, %d)", guid, newMapId))
        if MythicHandlers and MythicHandlers.RequestMapName then
            MythicHandlers.RequestMapName(player)
        end
    end
end

local function HeroicEndbossKeyReward(event, player, killed)
    local map = player:GetMap()
    if not map then return end
    local mapId = map:GetMapId()
    local difficulty = map:GetDifficulty()
    if difficulty ~= 1 then return end

    local instanceId = map:GetInstanceId()
    if MYTHIC_FLAG_TABLE[instanceId] then return end

    local bossData = MythicBosses[mapId]
    if bossData and killed:GetEntry() == bossData.final then
        if not PlayerHasAnyKeystone(player) then
            player:AddItem(900100, 1)
            player:SendBroadcastMessage("[Mythic+] You received a Mythic Keystone!")
        end
    end
end

local function OnPlayerLogin(event, player)
    local guid = player:GetGUIDLow()
    LoadPlayerCache(guid)
    PlayerNamesCache[guid] = player:GetName()
end

local function OnPlayerLogout(event, player)
    local guid = player:GetGUIDLow()
    if PlayerRatingCache[guid] then
        SavePlayerRatingCache(guid)
    end
end

RegisterCreatureGossipEvent(PEDESTAL_NPC_ENTRY, 1, Pedestal_OnGossipHello)
RegisterCreatureGossipEvent(PEDESTAL_NPC_ENTRY, 2, Pedestal_OnGossipSelect)
RegisterPlayerEvent(7, MythicBossKillCheck)
RegisterPlayerEvent(7, HeroicEndbossKeyReward)
RegisterPlayerEvent(8, MythicPlayerDeath)
RegisterPlayerEvent(53, BindKeystoneToDungeon)
RegisterPlayerEvent(28, LeaveDungeonMap)
RegisterPlayerEvent(3, OnPlayerLogin)
RegisterPlayerEvent(4, OnPlayerLogout)

function MythicHandlers.RequestMapName(player)
    local guid = player:GetGUIDLow()
    local mapId = PlayerKeysCache[guid]

    if mapId then
        local mapName = DungeonNames[mapId] or ("Unknown (" .. mapId .. ")")
        AIO.Handle(player, "AIO_Mythic", "ReceiveMapName", mapName)
    else
        AIO.Handle(player, "AIO_Mythic", "ReceiveMapName", "No Keystone")
    end
end

function MythicHandlers.RequestWeeklyAffixes(player)
    if WeeklyAffixesCache and #WeeklyAffixesCache >= 3 then
        local affix1 = WeeklyAffixesCache[1].name
        local affix2 = WeeklyAffixesCache[2].name or "-"
        local affix3 = WeeklyAffixesCache[3].name or "-"
        AIO.Handle(player, "AIO_Mythic", "ReceiveWeeklyAffixes", affix1, affix2, affix3)
    else
        AIO.Handle(player, "AIO_Mythic", "ReceiveWeeklyAffixes", "?", "?", "?")
    end
end

function MythicHandlers.RequestTotalPoints(player)
    local guid = player:GetGUIDLow()
    local cache = PlayerRatingCache[guid]
    
    if not cache then
        LoadPlayerCache(guid)
        cache = PlayerRatingCache[guid]
    end

    if cache then
        local dungeonScores = {}
        local dungeonIds = {574, 575, 576, 578, 595, 599, 600, 601, 602, 604, 608, 619, 632, 650, 658, 668}
        for _, mapId in ipairs(dungeonIds) do
            dungeonScores[tostring(mapId)] = cache[mapId] or 0
        end

        AIO.Handle(player, "AIO_Mythic", "ReceiveTotalPoints", cache.total_points, dungeonScores)
    else
        AIO.Handle(player, "AIO_Mythic", "ReceiveTotalPoints", 0, {})
    end
end

function MythicHandlers.RequestLeaderboard(player)
    UpdateLeaderboardCache()
    AIO.Handle(player, "AIO_Mythic", "ReceiveLeaderboard", LeaderboardCache.topThree, LeaderboardCache.dungeonTop)
end

local activeMythicTimers = {}

function MythicHandlers.NotifyMythicStart(player, mapId, tier, instanceId)
    local data = MythicBosses[mapId]
    if not data then return end

    local bossIds = data.bosses
    local bossNames = data.names or {}
    local duration = data.timer or 900

    activeMythicTimers[instanceId] = {
        endTime = os.time() + duration,
        mapId = mapId,
        tier = tier,
        bossEntries = bossIds,
        bossNames = bossNames
    }

    AIO.Handle(player, "AIO_Mythic", "StartMythicTimerGUI", mapId, tier, duration, bossNames)
end