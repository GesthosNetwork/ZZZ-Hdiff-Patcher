@echo off
SetLocal EnableDelayedExpansion
chcp 65001 >nul
title ZZZ Hdiff Patcher © 2025 GesthosNetwork

set "oldVer=1.7.0"
set "newVer=2.0.0"

for /F "usebackq delims=" %%i in ("Cleanup_!oldVer!-!newVer!.txt") do (
    if exist "%%i" (echo Deleting "%%i" & attrib -R "%%i" & del "%%i")
)

if not exist "Audio_Chinese_pkg_version"  rd /s /q "%path1%" 2>nul
if not exist "Audio_English(US)_pkg_version" rd /s /q "%path2%" 2>nul
if not exist "Audio_Japanese_pkg_version" rd /s /q "%path3%" 2>nul
if not exist "Audio_Korean_pkg_version" rd /s /q "%path4%" 2>nul

rd /s /q "ZenlessZoneZero_Data\SDKCaches" "ZenlessZoneZero_Data\webCaches" 2>nul
del *.dmp *.bak *.log 2>nul

:Extract
choice /C YN /M "Do you want to start extracting all ZIP files?"
if errorlevel 2 echo Extraction skipped. & goto CheckFiles

for %%f in (*.zip *.7z) do (
    echo Extracting "%%f"... Please wait, do not close the console^^!
    "7z.exe" x "%%f" -o"." -y && del "%%f" && echo Done extracting "%%f"
    echo.
)

:CheckFiles
echo Verifying patch prerequisites from version !oldVer! to !newVer!...
timeout /nobreak /t 3 >nul

set "langRoot=ZenlessZoneZero_Data\StreamingAssets\Audio\Windows"
set "path1=%langRoot%\Full\Cn"
set "path2=%langRoot%\Full\En"
set "path3=%langRoot%\Full\Jp"
set "path4=%langRoot%\Full\Kr"

set hdiff=0
for %%i in ("%langRoot%\Full" "%langRoot%\Min" !path1! !path2! !path3! !path4!) do if exist "%%i\*.hdiff" set hdiff=1
if %hdiff%==0 (echo *.hdiff files not found. You must extract the ZIP files before proceeding. & goto Extract)

set "audio_lang=ZenlessZoneZero_Data\Persistent\audio_lang"
mkdir "ZenlessZoneZero_Data\Persistent" >nul 2>&1
> "!audio_lang!" (
    if exist "%path1%" echo Cn
    if exist "%path2%" echo En
    if exist "%path3%" echo Jp
    if exist "%path4%" echo Kr
)

set "FileMissing=False"

for /F "usebackq delims=" %%i in ("AudioPatch_Common_!oldVer!-!newVer!.txt") do (
    if not exist "%%i" (
        echo "%%i" is missing.
        set FileMissing=True
    )
    if not exist "%%i.hdiff" (
        echo "%%i.hdiff" is missing.
        set FileMissing=True
    )
)

for %%l in (Chinese English Japanese Korean) do (
    if %%l==English (
        set "verfile=Audio_English(US)_pkg_version"
    ) else (
        set "verfile=Audio_%%l_pkg_version"
    )

    if exist !verfile! (
        for %%f in (AudioPatch_%%l_!oldVer!-!newVer!.txt AudioPatch_Common_!oldVer!-!newVer!.txt hpatchz.exe) do (
            if not exist %%f (
                echo "%%f" is missing.
                set FileMissing=True
            )
        )

        for /F "usebackq delims=" %%j in ("AudioPatch_%%l_!oldVer!-!newVer!.txt") do (
            if not exist "%%j" (
                echo "%%j" is missing.
                set FileMissing=True
            )
            if not exist "%%j.hdiff" (
                echo "%%j.hdiff" is missing.
                set FileMissing=True
            )
        )
    )
)

if "!FileMissing!"=="True" goto End

choice /C YN /M "All files are valid. Apply patch now?"
if errorlevel 2 goto End

for %%A in (Audio Video) do (
    if exist "ZenlessZoneZero_Data\Persistent\%%A" (
        robocopy "ZenlessZoneZero_Data\Persistent\%%A" "ZenlessZoneZero_Data\StreamingAssets\%%A" /e /copy:DAT /move
    )
)

for %%l in (Chinese English Japanese Korean) do (
    if %%l==English (
        set "verfile=Audio_English(US)_pkg_version"
    ) else (
        set "verfile=Audio_%%l_pkg_version"
    )

    if exist !verfile! (
        for /F "usebackq delims=" %%j in ("AudioPatch_%%l_!oldVer!-!newVer!.txt") do (
            attrib -R "%%j"
            hpatchz.exe -f "%%j" "%%j.hdiff" "%%j" && del "%%j.hdiff"
        )
    )
)

for /F "usebackq delims=" %%i in ("AudioPatch_Common_!oldVer!-!newVer!.txt") do (
    attrib -R "%%i"
    hpatchz.exe -f "%%i" "%%i.hdiff" "%%i" && del "%%i.hdiff"
)

:Empty
set "E=0" & for /d /r "ZenlessZoneZero_Data" %%i in (*) do (rd "%%i" 2>nul & if not exist "%%i" set "E=1")
if !E! equ 1 goto Empty

set PatchFinished=True
echo. & echo Patch completed successfully^^!

:End
pause
if "!PatchFinished!"=="True" (
    (
        echo [General]
        echo channel=1
        echo cps=hyp_hoyoverse
        echo game_version=!newVer!
        echo sub_channel=0
    ) > "config.ini"

    del *.bat *.zip *.7z *.txt hpatchz.exe 7z.exe
)
