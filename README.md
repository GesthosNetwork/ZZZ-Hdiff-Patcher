# ZZZ-Hdiff Patcher: a tool for updating ZZZ properly

If you update the game by simply copying all the *update files* and then replacing them in the game client directory, that's actually not the correct way. You should merge the `.pck.hdiff` update with the old `.pck` file and delete the obsolete files listed in `deletefiles.txt`.

## How to use?

For example, you want to update the game from 1.0.1 to 1.1.0:

1. Make sure you have extracted all files from the `game_1.0.1_1.1.0_hdiff.zip` and `audio_en-us_1.0.1_1.1.0_hdiff.zip`, then replace them in the `1.0.1` game client directory.
2. Place the following files in the same folder as `ZenlessZoneZero.exe`:
   - `hdiffz.exe`
   - `hpatchz.exe`
   - `Start.bat`
   - `Cleanup_1.0.1-1.1.0.txt`
   - `AudioPatch_Common_1.0.1-1.1.0.txt`
   - `AudioPatch_English_1.0.1-1.1.0.txt`
   - `AudioPatch_Japanese_1.0.1-1.1.0.txt`
   - `AudioPatch_Chinese_1.0.1-1.1.0.txt`
   - `AudioPatch_Korean_1.0.1-1.1.0.txt`
3. Run `Start.bat` and wait until the process finishes.
4. Now, your game is updated to version `1.1.0`.

## Note
  - Overview of the merging process:
    ```
    Banks0.pck (59.5 MB)        // old file, before update
    + Banks0.pck.hdiff (3.0 MB) // hdiff update
    -----------------------------
    = Banks0.pck (62.5 MB)      // new file with new size, after update
    ```
