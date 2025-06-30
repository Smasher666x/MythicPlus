# MythicPlus AddOn

## Important Information

This addon provides Mythic+ features for World of Warcraft 3.3.5a, but **custom item icons cannot be implemented directly through the addon**. To enable custom item icons, you must create a custom patch file for your client.

### Steps to Create a Custom Patch File

1. **Locate the Required Files:**
   - Navigate to `.../Client/Raw/DBFilesClient/`.
   - Copy the contents of this folder (e.g., `Item.dbc`, `ItemDisplayInfo.dbc`).

2. **Create a Patch File:**
   - Use a tool like [Ladik's MPQ Editor](https://www.hiveworkshop.com/threads/ladiks-mpq-editor.249562/) to create a new `.mpq` file.
   - Name the file `patch-XYZ.mpq` (replace `XYZ` with a unique identifier, e.g., `patch-M`).

3. **Insert the Files:**
   - Inside the `.mpq` file, replicate the folder structure:
     ```
     DBFilesClient/
         Item.dbc
         ItemDisplayInfo.dbc
     ```

4. **Place the Patch File:**
   - Move the `.mpq` file into your WoW client's `Data` folder.

5. **Restart Your Client:**
   - Restart your WoW client to load the new patch.

### Why is This Necessary?

World of Warcraft addons cannot overwrite `.dbc` files directly. These files must be implemented as part of a custom patch file to modify the client.
