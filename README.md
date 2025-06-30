# MythicPlus for AzerothCore (Eluna + AIO)

## Disclaimer

This project is for **educational purposes only**.  
Some files used within `Patch-Z.MPQ` are owned and licensed by Blizzard Entertainment, and all rights to those files remain with Blizzard.

---

> **Inspired by:** [Doodihealz/MythicPlus](https://github.com/Doodihealz/MythicPlus)  
> Huge thanks for the original inspiration and ideas!

---

## Requirements

- [AzerothCore Eluna module](https://github.com/azerothcore/mod-eluna)
- [Rochet2's AIO (All-In-One) framework](https://github.com/Rochet2/AIO)

---

## What is this?

This project **aims to bring** a full Mythic+ experience to your AzerothCore Wrath of the Lich King server, built using **Eluna** scripting and the **AIO** framework.  
It is still under development (work in progress).

Features include:

- **Custom in-game GUI** (no extra addons needed for players)
- **Sound effects** and **images** for a polished experience
- **Weekly affixes** and scaling difficulty (3 tiers currently)
- **Timed runs** with score, serverwide leaderboards, and rewards
- **Custom loot system** with support for pets, mounts, gear, spells

---

## Features

- **No Addon Required:** All players need is the patch file—no extra downloads or setup.
- **AIO-powered GUI:** See your score, affixes, timers, and leaderboards in a custom interface.
- **Weekly Affixes:** Randomly selected affixes each week, scaling with Mythic+ tier.
- **Timed Runs:** Beat the clock for better rewards and higher scores.
- **Custom Loot Table:** Configure rare mounts, pets, gear, and spells as Mythic+ rewards.
- **Faction & Class Filtering:** Rewards can be restricted by faction or class/armor type.
- **Automatic Keystone Management:** Keys are upgraded/downgraded based on performance.
- **Leaderboard:** Track the best players and dungeon clears on your server.
- **No Core Modifications Needed:** Just using the database and Eluna/AIO.

---

## Planned Features

- **Weekly Vault Reward:** A system to grant players a special reward once per week based on their Mythic+ performance.
- **Better GUI:** A rework on the curent GUI by using the actual Mythic+ GUI.
- **Downgrade or Change bound dungeon:** An NPC that will allow you to downgrade your keystone and/or randomize the bound dungeon.

---

## Configuration

At the top of `Mythic_Server.lua` you’ll find:

    local MythicRewardConfig = {
        pets      = true,
        mounts    = true,
        equipment = true,
        spells    = true,
    }

Set these to `true` or `false` to enable/disable each reward type.

---

## Custom Loot Table: `world_mythic_loot`

All Mythic+ rewards are managed in the `world_mythic_loot` table (see `Data/SQL/world/world_mythic_loot.sql`).  
Each row defines a possible reward. The columns are:

| Column         | Type        | Description                                                                                 |
|----------------|-------------|---------------------------------------------------------------------------------------------|
| id             | int         | Auto-increment primary key                                                                  |
| itemid         | int         | Item/Spell/Skill ID to reward                                                               |
| itemname       | varchar     | Name for display                                                                            |
| amount         | int         | Amount to give (usually 1)                                                                  |
| type           | varchar     | "gear", "pet", "mount", "spell"                                                             |
| faction        | char(1)     | "A" (Alliance), "H" (Horde), or "N" (Neutral)                                               |
| chanceOnTier   | int         | See below                                                                                   |
| chancePercent  | float       | Drop chance (e.g. 0.2 for 0.2%)                                                             |
| additionalID   | int         | (Optional) Extra item/spell/skill to give                                                   |
| additionalType | varchar     | (Optional) "item", "spell", or "skill"                                                      |

### `chanceOnTier` Logic

| Value | Drops on...           |
|-------|-----------------------|
| 3     | Tier 3 and above      |
| 2     | Tier 2 and above      |
| 1     | Tier 1 and above      |
| 0     | All tiers             |
| -1    | Only tier 1           |
| -2    | Only tier 2           |
| -3    | Only tier 3           |

---

## Installation

1. **Copy the Folder:**  
   Place the entire `MythicPlus` folder into your AzerothCore `/lua-scripts` directory.

2. **Import SQL Tables:**  
   - Import all `.sql` files from `Data/SQL/world` into your **world** database.
   - Import all `.sql` files from `Data/SQL/characters` into your **characters** database.

3. **Client Patch:**  
   - Move `Data/Patch-Z.MPQ` from this repo into your WoW client's `Data` folder.
   - If you already have a `Patch-Z.MPQ`, either merge the contents or rename this file (e.g., `Patch-Y.MPQ`).  
     The patch should be loaded late (alphabetically last) to avoid being overwritten by other patches.

4. **Restart Server and Client:**  
   - Restart your AzerothCore server.
   - Restart your WoW client.

5. **Enjoy Mythic+ !!**  


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
# MythicPlus
Mythic+ system for AzerothCore using Eluna and AIO, featuring custom GUI, weekly affixes, timed runs, and configurable rewards.
