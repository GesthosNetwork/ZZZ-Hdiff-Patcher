## ZZZ-Hdiff Patcher: a tool for manually updating ZZZ properly

If you update the game by simply copying all the *update files* and then replacing them in the game client directory, that's actually not the correct way. You should merge the `.pck.hdiff` update with the old `.pck` file and delete the obsolete files listed in `deletefiles.txt`.

## How to use?

For example, you want to update the game from 2.0.0 to 2.1.0:

1. Put the following files in the same place as `ZenlessZoneZero.exe`:
   - `AudioPatch_2.0.0-2.1.0.txt`
   - `Cleanup_2.0.0-2.1.0.txt`
   - `hpatchz.exe`
   - `7z.exe`
   - `Start.bat`
   - `game_2.0.0-2.1.0_hdiff.zip`
   - `audio_en-us_2.0.0-2.1.0_hdiff.zip`

2. Run `Start.bat` and wait until the process finishes.
3. Now, your game is updated!

## Note
  - Overview of the merging process:
    ```
    Banks0.pck (59.5 MB)        // old file, before update
    + Banks0.pck.hdiff (3.0 MB) // hdiff update
    -----------------------------
    = Banks0.pck (62.5 MB)      // new size after update
    ```

