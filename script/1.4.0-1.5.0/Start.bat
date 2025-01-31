@echo off
SetLocal EnableDelayedExpansion
chcp 65001 >nul
set "oldVer=1.4.0"
set "newVer=1.5.0"
Title ZZZ Hdiff Patcher © 2025 GesthosNetwork

choice /C YN /M "Do you want to start extracting all ZIP files?"
if errorlevel 2 echo Extraction skipped. & goto Check
if not exist 7z.exe echo 7z.exe not found. & goto End

for %%f in (*.zip *.7z) do (
    echo Extracting "%%f"... Please wait, do not close the console^^!
    "7z.exe" x "%%f" -o"." -y & echo Done extracting "%%f" & echo.
)

:Check
echo Checking if all necessary files to update the game from Patch !oldVer! to !newVer! are present...
timeout /nobreak /t 3 >nul

set "path1=ZenlessZoneZero_Data\StreamingAssets\Audio\Windows\Full\Cn"
set "path2=ZenlessZoneZero_Data\StreamingAssets\Audio\Windows\Full\En"
set "path3=ZenlessZoneZero_Data\StreamingAssets\Audio\Windows\Full\Jp"
set "path4=ZenlessZoneZero_Data\StreamingAssets\Audio\Windows\Full\Kr"

if not exist "Audio_Chinese_pkg_version" rd /s /q !path1! 2>nul
if not exist "Audio_English(US)_pkg_version" rd /s /q !path2! 2>nul
if not exist "Audio_Japanese_pkg_version" rd /s /q !path3! 2>nul
if not exist "Audio_Korean_pkg_version" rd /s /q !path4! 2>nul

set "audio_lang=ZenlessZoneZero_Data\Persistent\audio_lang"
set "used_language="
mkdir "ZenlessZoneZero_Data\Persistent" > nul 2>&1 & type nul > "!audio_lang!"

if exist !path1! (
    set /p="Cn" <nul >> "%audio_lang%"
    set "used_language=Cn"
)
if exist !path2! (
    if defined used_language echo. >> "%audio_lang%"
    set /p="En" <nul >> "%audio_lang%"
    set "used_language=En"
)
if exist !path3! (
    if defined used_language echo. >> "%audio_lang%"
    set /p="Jp" <nul >> "%audio_lang%"
    set "used_language=Jp"
)
if exist !path4! (
    if defined used_language echo. >> "%audio_lang%"
    set /p="Kr" <nul >> "%audio_lang%"
    set "used_language=Kr"
)

set PatchFinished=False
set FileMissing=False

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

for %%l in (Chinese,English,Japanese,Korean) do (
    if %%l==Chinese set checkFile="Audio_Chinese_pkg_version"
    if %%l==English set checkFile="Audio_English(US)_pkg_version"
    if %%l==Japanese set checkFile="Audio_Japanese_pkg_version"
    if %%l==Korean set checkFile="Audio_Korean_pkg_version"
    if exist !checkFile! (
        for %%f in (AudioPatch_%%l_!oldVer!-!newVer!.txt AudioPatch_Common_!oldVer!-!newVer!.txt hpatchz.exe) do (
            if NOT exist %%~f (
                echo "%%~f is missing."
                set FileMissing=True
            )
        )
        for /F "usebackq delims=" %%j in ("AudioPatch_%%l_!oldVer!-!newVer!.txt") do (
            if NOT exist "%%j" (
                echo "%%j is missing."
                set FileMissing=True
            )
            if NOT exist "%%j.hdiff" (
                echo "%%j.hdiff is missing."
                set FileMissing=True
            )
        )
    )
)

if "%FileMissing%"=="True" goto End

choice /C YN /M "All necessary files are present. Apply patch now?"
if errorlevel 2 goto End

if exist "ZenlessZoneZero_Data\Persistent\Audio" robocopy "ZenlessZoneZero_Data\Persistent\Audio" "ZenlessZoneZero_Data\StreamingAssets\Audio" /e /copy:DAT /move

for %%l in (Chinese,English,Japanese,Korean) do (
    set "N=Audio_%%l_pkg_version"
    if "%%l"=="English" set "N=Audio_English(US)_pkg_version"
    if exist "!N!" (
        for /F "usebackq delims=" %%j in ("AudioPatch_%%l_!oldVer!-!newVer!.txt") do (
            attrib -R "%%j" && hpatchz.exe -f "%%j" "%%j.hdiff" "%%j"
        )
    )
)

for /F "usebackq delims=" %%i in ("AudioPatch_Common_!oldVer!-!newVer!.txt") do (
    attrib -R "%%i" && "hpatchz.exe" -f "%%i" "%%i.hdiff" "%%i"
)

for %%l in (Chinese,English,Japanese,Korean) do (
    for /F "usebackq delims=" %%i in ("AudioPatch_%%l_!oldVer!-!newVer!.txt") do (
			if exist "%%i.hdiff" echo Deleting "%%i.hdiff" && del "%%i.hdiff"
		)
)

for /F "usebackq delims=" %%i in ("AudioPatch_Common_!oldVer!-!newVer!.txt") do (
    if exist "%%i.hdiff" echo Deleting "%%i.hdiff" && del "%%i.hdiff"
)

for /F "usebackq delims=" %%i in ("Cleanup_!oldVer!-!newVer!.txt") do (
    if exist "%%i" echo Deleting "%%i" & attrib -R "%%i" && del "%%i"
)

:Empty
set "E=0" & for /d /r "ZenlessZoneZero_Data" %%i in (*) do (rd "%%i" 2>nul & if not exist "%%i" set "E=1")
if !E! equ 1 goto Empty

set PatchFinished=True
echo. & echo Patch completed^^!

:End
pause
if "%PatchFinished%"=="True" (
  (
    echo [General]
    echo channel=1
    echo cps=mihoyo
    echo game_version=!newVer!
    echo sub_channel=0
  ) > "config.ini"
  
  rd /s /q "ZenlessZoneZero_Data\SDKCaches" "ZenlessZoneZero_Data\webCaches" 2>nul
  del *.bat *.zip *.7z hpatchz.exe 7z.exe *.dmp *.bak *.txt *.log
)
