# MythicPlus Client Setup

To make the `MythicPlus` features work correctly, you must use a custom patch file for your WoW client. Addons alone cannot provide all required functionality.

## 1. Use the Provided Patch File

- Copy `Data/Client/MPQ/Patch-Z.MPQ` into your WoW client's `.../World of Warcraft/Data/` folder.
- **Important:** If you already have a `Patch-Z.MPQ` file, you must merge the contents into one file to avoid load-order issues.

### How to Merge:
- Use the `.csv` files in `Data/Client/Raw/changes`.
- Open your existing `.dbc` files (`item.dbc` and `ItemDisplayInfo.dbc`) using [WDBXEditor](https://github.com/WowDevTools/WDBXEditor).
- Select `Import` -> `Import from CSV` and choose the respective `.csv` file.
- Ensure the following options are selected:
  - `Import New`
  - `Has Header Row?`
  - `Take Newest`
- Save the `.dbc` files and implement them back into your `.mpq` file.

### **Warning:**
- We use specific IDs in `item.dbc` (`900100, 900101, 900102`) and `ItemDisplayInfo.dbc` (`62471`). Existing content with these IDs will be overwritten.

---

## 2. Create Your Own Patch File

- Use the files in `Data/Client/Raw/all` to create your own `.mpq` file.
- Use a tool like [Ladik's MPQ Editor](https://www.hiveworkshop.com/threads/ladiks-mpq-editor.249562/) to create the patch.
- Replicate the folder structure:
  ```
  DBFilesClient/
      Item.dbc
      ItemDisplayInfo.dbc
  Interface/
      Icons/
          inv_relics_hourglass.blp
      MythicPlus/
          sounds/
              UI_BattlegroundCountdown_End.ogg
              UI_BattlegroundCountdown_Timer.ogg
          textures/
              BigTimerNumbers.blp
  ```
- Save the `.mpq` file and place it in your WoW client's `Data` folder.

---

For further assistance, feel free to reach out!