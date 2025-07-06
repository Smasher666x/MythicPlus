# MythicPlus for AzerothCore (Eluna + AIO)

## Disclaimer

This project is for **educational purposes only**.

**Important Legal Notice:**
- All graphical assets, sounds, and textures used in this project are the intellectual property of **Blizzard Entertainment, Inc.**
- We do not own, claim ownership of, or distribute any copyrighted Blizzard content
- Users must source these assets from their own legitimate World of Warcraft installation
- Custom client files are required for full functionality - see [`Data/Client/README.md`](Data/Client/README.md) for setup instructions
- This project provides only the server-side scripting framework - no Blizzard assets are included

---

> **Inspired by:** [Doodihealz/MythicPlus](https://github.com/Doodihealz/MythicPlus)  
> Huge thanks for the original inspiration and ideas!

---

## Requirements

- [AzerothCore Eluna module](https://github.com/azerothcore/mod-eluna)
- [Rochet2's AIO (All-In-One) framework](https://github.com/Rochet2/AIO)

---

## What is this?

This project **brings** a full Mythic+ experience to your AzerothCore Wrath of the Lich King server, built using **Eluna** scripting and the **AIO** framework.

Features include:

- **Custom in-game GUI** (no extra addons needed for players)
- **Sound effects** and **images** for a polished experience
- **Weekly affixes** and scaling difficulty (unlimited tiers)
- **Timed runs** with Blizzlike rating system, serverwide leaderboards, and rewards
- **Custom loot system** with support for pets, mounts, gear, spells
- **Weekly vault system** with customizable rewards
- **Overtime completion** system for loot without rating gains

---

## Features

### Core System
- **No Addon Required:** All players need is the patch file—no extra downloads or setup.
- **Single Keystone System:** Players maintain one keystone that upgrades/downgrades based on performance.
- **Unlimited Keystone Levels:** No artificial cap on keystone difficulty.
- **Blizzlike Rating System:** Implements the official Mythic+ rating calculation from retail WoW.

### Advanced Mechanics
- **Enemy Forces:** New win condition requiring elimination of a specified number of enemies per dungeon.
- **Overtime Mode:** Players can continue after time expires to complete the dungeon for loot (but no rating).
- **Custom Affix System:** 8 unique affixes with intelligent exclusions to preserve boss mechanics.
- **Death Limits:** Configurable death limits that end runs (6 deaths on +1, 4 deaths on +2 and above).

### GUI & Interface
- **AIO-powered GUI:** See your score, affixes, timers, and leaderboards in a custom interface.
- **Real-time Timer:** Shows remaining time, deaths, enemy forces progress, and boss completion.
- **Weekly Vault GUI:** Interactive vault interface for claiming weekly rewards.
- **Dungeon-specific Information:** Boss names, completion status, and progress tracking.

### Loot & Rewards
- **Performance-based Loot:** Higher keystone levels and better performance increase loot chances.
- **Class & Armor Proficiency:** Automatic filtering ensures players only receive usable gear.
- **Faction-specific Rewards:** Items can be restricted to Alliance, Horde, or neutral.
- **Bracket System:** Flexible loot distribution based on keystone tier ranges.

### Weekly Systems
- **Weekly Vault:** Collect rewards based on your highest completed keystones each week.
- **Automated Vault Generation:** Vault items are automatically generated every Wednesday at 8 AM.
- **Weekly Affixes:** Randomly selected affixes each week that scale with keystone tier.

---

## How to Customize

### Loot Configuration

#### Basic Reward Types
In `Mythic_Server.lua`, find the `MythicRewardConfig` section:

```lua
local MythicRewardConfig = {
    pets      = true,
    mounts    = true,
    equipment = false,  -- Set to true to enable gear rewards
    spells    = false,  -- Set to true to enable spell learning
}
```

#### Mythic+ Loot Brackets (`MYTHIC_LOOT_BRACKETS`)
Located in `Mythic_Server.lua`, these define tier ranges for loot distribution:

```lua
local MYTHIC_LOOT_BRACKETS = {
    ["low_tier"] = {1, 2, 3},           -- Keystones 1-3
    ["mid_tier"] = {4, 5, 6, 7},        -- Keystones 4-7
    ["high_tier"] = {8, 9, 10, 11, 12}, -- Keystones 8-12
    ["endgame"] = {15, 16, 17, 18, 19, 20}, -- Keystones 15-20
    ["pets"] = {5, 6, 7, 8, 9},         -- Pet rewards for keystones 5-9
    ["all"] = "all"                     -- Available on all keystone levels
}
```

**How to modify:**
- Add new brackets: `["my_bracket"] = {10, 11, 12, 13}`
- Modify existing ranges: Change the numbers in the arrays
- Use in database: Set `loot_bracket` column to your bracket name

#### Vault Loot Brackets (`VAULT_LOOT_BRACKETS`)
Similar to mythic loot brackets but for weekly vault rewards:

```lua
local VAULT_LOOT_BRACKETS = {
    ["vault_low"] = {1, 2, 3, 4, 5},        -- Low-tier vault rewards
    ["vault_mid"] = {6, 7, 8, 9, 10},       -- Mid-tier vault rewards
    ["vault_high"] = {11, 12, 13, 14, 15},  -- High-tier vault rewards
    ["vault_legendary"] = {16, 17, 18, 19, 20}, -- Legendary vault rewards
    ["all"] = "all"                         -- Available for all vault tiers
}
```

#### Dungeon Configuration (`MythicBosses`)
Each dungeon's settings are defined in the `MythicBosses` table:

```lua
local MythicBosses = {
    [574] = { -- Utgarde Keep
        bosses = {23953, 24200, 24201, 23954}, -- Boss creature IDs
        final = 23954,                          -- Final boss ID
        names = {"Prince Keleseth", "Skarvald the Constructor", "Dalronn the Controller", "Ingvar the Plunderer"},
        timer = 1500,                           -- Time limit in seconds (25 minutes)
        enemies = 45                            -- Required enemy forces (set to 0 to disable)
    },
    -- Add more dungeons following the same pattern
}
```

**How to add a new dungeon:**
1. Find the map ID of your dungeon
2. Add an entry following the pattern above
3. Add the map ID to the `mythicDungeonIds` table
4. Place a Mythic Pedestal (creature ID 900001) in the dungeon

### Database Tables

#### `world_mythic_loot` Table
This table controls all Mythic+ run rewards:

| Column         | Type        | Description                                                                                 |
|----------------|-------------|---------------------------------------------------------------------------------------------|
| id             | int         | Auto-increment primary key                                                                  |
| itemid         | int         | Item/Spell/Skill ID to reward                                                               |
| itemname       | varchar     | Name for reference (not used by script)                                                     |
| amount         | int         | Amount to give (usually 1)                                                                  |
| type           | varchar     | "gear", "pet", "mount", "spell"                                                             |
| faction        | char(1)     | "A" (Alliance), "H" (Horde), or "N" (Neutral)                                               |
| loot_bracket   | varchar     | Bracket name or tier range (see examples below)                                             |
| chancePercent  | float       | Drop chance (e.g. 0.2 for 0.2%)                                                             |
| additionalID   | int         | (Optional) Extra item/spell/skill to give                                                   |
| additionalType | varchar     | (Optional) "item", "spell", or "skill"                                                      |

**Loot Bracket Examples:**
- `"low_tier"` - Uses the bracket defined in `MYTHIC_LOOT_BRACKETS`
- `"1-3"` - Keystones 1 through 3
- `"10+"` - Keystone 10 and above
- `"5"` - Only keystone 5
- `"all"` - All keystone levels

**Example entries:**
```sql
INSERT INTO world_mythic_loot (itemid, itemname, type, faction, loot_bracket, chancePercent) VALUES
(12354, 'Palomino Bridle', 'mount', 'A', 'high_tier', 0.1),
(40110, 'Haunted Memento', 'pet', 'N', '5+', 0.5),
(13262, 'Ashbringer', 'gear', 'N', '15+', 0.01);
```

#### `world_vault_loot` Table
This table controls weekly vault rewards:

| Column         | Type        | Description                                                                                 |
|----------------|-------------|---------------------------------------------------------------------------------------------|
| id             | int         | Auto-increment primary key                                                                  |
| itemid         | int         | Item ID to reward                                                                           |
| loot_bracket   | varchar     | Vault bracket name or tier range                                                            |
| chancePercent  | float       | Selection weight (higher = more likely to be chosen)                                        |
| faction        | char(1)     | "A" (Alliance), "H" (Horde), or "N" (Neutral)                                               |

**Example entries:**
```sql
INSERT INTO world_vault_loot (itemid, loot_bracket, chancePercent, faction) VALUES
(49623, 'vault_low', 10.0, 'N'),      -- Common reward for low-tier vaults
(49644, 'vault_high', 5.0, 'N'),      -- Rare reward for high-tier vaults
(50818, 'vault_legendary', 1.0, 'N'); -- Very rare legendary vault reward
```

### Weekly Systems

#### Affix Configuration
Weekly affixes are defined in the `WEEKLY_AFFIX_POOL`:

```lua
local WEEKLY_AFFIX_POOL = {
    { spell = 8599, name = "Enrage" },
    { spell = {48441, 61301}, name = "Rejuvenating" },
    { spell = 871, name = "Turtling" },
    -- Add more affixes following this pattern
}
```

#### Vault Generation Schedule
The vault system automatically generates rewards every Wednesday at 8 AM server time. This is configured in the `ScheduleVaultGeneration()` function and runs automatically on server startup.

---

## Installation

1. **Copy the Folder:**  
   Place the entire `MythicPlus` folder into your AzerothCore `/lua-scripts` directory.

2. **Import SQL Tables:**  
   - Import all `.sql` files from `Data/SQL/world` into your **world** database.
   - Import all `.sql` files from `Data/SQL/characters` into your **characters** database.

3. **Client Setup:**  
   - **You must create your own custom patch file** to enable the MythicPlus interface, textures, and sounds.
   - Follow the detailed instructions in [`Data/Client/README.md`](Data/Client/README.md) to create your custom patch file.
   - The patch file is required for proper display of the MythicPlus GUI, timer, vault interface, and custom textures.

4. **Restart Server and Client:**  
   - Restart your AzerothCore server.
   - Restart your WoW client.

5. **Enjoy Mythic+!**  

---

## How It Works

1. **Getting Started:** Complete any heroic dungeon to receive your first Mythic Keystone.
2. **Using Keystones:** Enter a heroic dungeon and interact with the Mythic Pedestal to start a timed run.
3. **Completion:** Complete all bosses and required enemy forces within the time limit for full rewards.
4. **Overtime:** If time expires, you can continue for loot but won't gain rating or keystone upgrades.
5. **Progression:** Your keystone upgrades (+1 to +3) or downgrades (-1) based on performance.
6. **Weekly Rewards:** Collect vault rewards based on your highest completed keystones each week.
7. **Finding the Vault:** The Mythic Vault can be found in Dalaran, in front of the Violet Hold dungeon entrance, on the circular platform to the left side.

---

## Support, Issues & Tips

If you enjoy this project and want to support further development, you can leave a tip at [ko-fi.com/huptiq](https://ko-fi.com/huptiq).

If you encounter any bugs, broken code, or unexpected behavior, **please create an issue** on this repository so it can be fixed!  
Feature requests and suggestions are also very welcome—feel free to open an issue if you have an idea for improvement.

---

## License

MythicPlus for AzerothCore - A Mythic+ system using Eluna and AIO.  
Copyright (C) 2025 huptiq

This project is licensed under the [GNU GENERAL PUBLIC LICENSE Version 3](LICENSE).

**Third-Party Assets:**
- World of Warcraft®, Wrath of the Lich King® are registered trademarks of Blizzard Entertainment, Inc.
- All game assets, textures, sounds, and other copyrighted materials remain the property of Blizzard Entertainment, Inc.