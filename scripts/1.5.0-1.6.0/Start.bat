@echo off
SetLocal EnableDelayedExpansion
chcp 65001 >nul
title ZZZ Hdiff Patcher © 2025 GesthosNetwork

set oldVer=1.5.0
set newVer=1.6.0

set PatchFinished=False

set audio=ZenlessZoneZero_Data\StreamingAssets\Audio\Windows
set path1=%audio%\Full\En
set path2=%audio%\Full\Jp
set path3=%audio%\Full\Cn
set path4=%audio%\Full\Kr

for %%f in (AudioPatch_!oldVer!-!newVer!.txt Cleanup_!oldVer!-!newVer!.txt hpatchz.exe 7z.exe) do if not exist %%f (
    echo %%f is missing. & goto End
)

for /F "usebackq delims=" %%i in (Cleanup_!oldVer!-!newVer!.txt) do (
    if exist %%i (echo Deleting %%i & attrib -R %%i & del %%i)
)

rd /s /q ZenlessZoneZero_Data\SDKCaches ZenlessZoneZero_Data\webCaches 2>nul
del *.dmp *.bak *.log 2>nul

for %%f in (*.zip *.7z) do (
    7z.exe x %%f -o"." -y && del %%f
)

set hdiff=0
for %%i in (!path1!, !path2!, !path3!, !path4!) do if exist "%%i\*.hdiff" set hdiff=1
if %hdiff%==0 for %%i in (!path1!, !path2!, !path3!, !path4!) do if not exist "%%i\*.hdiff" rd /s /q %%i 2>nul

if not exist %path1% del /f /q Audio_English(US)_pkg_version 2>nul
if not exist %path2% del /f /q Audio_Japanese_pkg_version 2>nul
if not exist %path3% del /f /q Audio_Chinese_pkg_version 2>nul
if not exist %path4% del /f /q Audio_Korean_pkg_version 2>nul

set audio_lang=ZenlessZoneZero_Data\Persistent\audio_lang
set "used_language="
md ZenlessZoneZero_Data\Persistent > nul 2>&1 & type nul > !audio_lang!

if exist !path1! (
    set /p=En <nul >> !audio_lang!
    set used_language=En
)
if exist !path2! (
    if defined used_language echo. >> !audio_lang!
    set /p=Jp <nul >> !audio_lang!
    set used_language=Jp
)
if exist !path3! (
    if defined used_language echo. >> !audio_lang!
    set /p=Kr <nul >> !audio_lang!
    set used_language=Kr
)
if exist !path4! (
    if defined used_language echo. >> !audio_lang!
    set /p=Cn <nul >> !audio_lang!
    set used_language=Cn
)

for /F "usebackq delims=" %%i in (AudioPatch_!oldVer!-!newVer!.txt) do (
    hpatchz.exe -f %%i %%i.hdiff %%i && del %%i.hdiff
)

set PatchFinished=True

:Empty
set E=0 & for /d /r ZenlessZoneZero_Data %%i in (*) do (rd %%i 2>nul & if not exist %%i set E=1)
if !E! equ 1 goto Empty

if !PatchFinished!==True (
    (
        echo [General]
        echo channel=1
        echo cps=hyp_hoyoverse
        echo game_version=!newVer!
        echo sub_channel=0
    ) > config.ini

    del *.bat *.txt hpatchz.exe 7z.exe
)

:End
pause