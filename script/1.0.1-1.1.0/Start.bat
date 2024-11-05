@echo off
SetLocal EnableDelayedExpansion
chcp 65001 >nul
set "oldVer=1.0.1"
set "newVer=1.1.0"
Title ZZZ Hdiff Patcher © 2024 GesthosNetwork
echo Checking if all necessary files to update the game from Patch !oldVer! to !newVer! are present...
timeout /nobreak /t 10 >nul

set "path1=ZenlessZoneZero_Data\StreamingAssets\Audio\Windows\Full\Cn"
set "path2=ZenlessZoneZero_Data\StreamingAssets\Audio\Windows\Full\En"
set "path4=ZenlessZoneZero_Data\StreamingAssets\Audio\Windows\Full\Jp"
set "path3=ZenlessZoneZero_Data\StreamingAssets\Audio\Windows\Full\Kr"

if not exist "Audio_Chinese_pkg_version" rd /s /q !path1! 2>nul
if not exist "Audio_English(US)_pkg_version" rd /s /q !path2! 2>nul
if not exist "Audio_Japanese_pkg_version" rd /s /q !path3! 2>nul
if not exist "Audio_Korean_pkg_version" rd /s /q !path4! 2>nul

set "audio_lang=ZenlessZoneZero_Data\Persistent\audio_lang"
set "used_language="

type nul > "%audio_lang%"

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
set ChineseInstalled=False
set EnglishInstalled=False
set JapaneseInstalled=False
set KoreanInstalled=False
set CurrentLanguage=None
set LangCheck=None

for /F "usebackq delims=" %%i in ("!audio_lang!") do (
	if "%%i"=="Cn" (
		set ChineseInstalled=True
		set CurrentLanguage=Chinese
	)
	if "%%i"=="En" (
		set EnglishInstalled=True
		set CurrentLanguage=English
	)
	if "%%i"=="Jp" (
		set JapaneseInstalled=True
		set CurrentLanguage=Japanese
	)
	if "%%i"=="Kr" (
		set KoreanInstalled=True
		set CurrentLanguage=Korean
	)
	
	if NOT exist "AudioPatch_!CurrentLanguage!_!oldVer!-!newVer!.txt" (
		echo "AudioPatch_!CurrentLanguage!_!oldVer!-!newVer!.txt" is missing.
		set FileMissing=True
		set CurrentLanguage=None
	)
)
if NOT exist "AudioPatch_Common_!oldVer!-!newVer!.txt" (
	echo "AudioPatch_Common_!oldVer!-!newVer!.txt" is missing.
	set FileMissing=True
)

if "%FileMissing%"=="True" (
  goto Retry
) else goto MoveLang

:MoveLang
if exist "ZenlessZoneZero_Data\Persistent\Audio" robocopy "ZenlessZoneZero_Data\Persistent\Audio" "ZenlessZoneZero_Data\StreamingAssets\Audio" /e /copy:DAT /dcopy:DAT /move

for /L %%i in (1,1,4) do (
	if "%%i"=="1" (
		if "%ChineseInstalled%"=="True" (
			set CurrentLanguage=Chinese
		) else set CurrentLanguage=None
	)
	if "%%i"=="2" (
		if "%EnglishInstalled%"=="True" (
			set CurrentLanguage=English
		) else set CurrentLanguage=None
	)
	if "%%i"=="3" (
		if "%JapaneseInstalled%"=="True" (
			set CurrentLanguage=Japanese
		) else set CurrentLanguage=None
	)
	if "%%i"=="4" (
		if "%KoreanInstalled%"=="True" (
			set CurrentLanguage=Korean
		) else set CurrentLanguage=None
	)
	if NOT "!CurrentLanguage!"=="None" (
		if "!CurrentLanguage!"=="English" (
			set "LangCheck=En"
		) else set LangCheck=!CurrentLanguage!
		for /F "usebackq delims=" %%j in ("AudioPatch_!CurrentLanguage!_!oldVer!-!newVer!.txt") do (
			if NOT exist "%%j" (
				echo "%%j" is missing.
				set FileMissing=True
			)
			if NOT exist "%%j.hdiff" (
				echo "%%j.hdiff" is missing.
				set FileMissing=True
			)
		)
	)
)

for /F "usebackq delims=" %%i in ("AudioPatch_Common_!oldVer!-!newVer!.txt") do (
	if NOT exist "%%i" (
		echo "%%i" is missing.
		set FileMissing=True
	)
	if NOT exist "%%i.hdiff" (
		echo "%%i.hdiff" is missing.
		set FileMissing=True
	)
)

if NOT exist "hpatchz.exe" (
	echo "hpatchz.exe" is missing.
	set FileMissing=True
)

if "%FileMissing%"=="True" (
  goto Retry
) else goto Query

:Retry
echo.
echo At least one file is missing. Please extract/download the necessary files listed above and try again.
goto End

:Abort
echo Aborted patch application. Exiting after next button press.
goto End

:Query
choice /C YN /M "All necessary files are present. Apply patch now?"
if errorlevel 2 goto Abort
if errorlevel 1 goto ApplyPatch

:ApplyPatch
for /L %%i in (1,1,4) do (
	if "%%i"=="1" (
		if "%ChineseInstalled%"=="True" (
			set CurrentLanguage=Chinese
		) else set CurrentLanguage=None
	)
	if "%%i"=="2" (
		if "%EnglishInstalled%"=="True" (
			set CurrentLanguage=English
		) else set CurrentLanguage=None
	)
	if "%%i"=="3" (
		if "%JapaneseInstalled%"=="True" (
			set CurrentLanguage=Japanese
		) else set CurrentLanguage=None
	)
	if "%%i"=="4" (
		if "%KoreanInstalled%"=="True" (
			set CurrentLanguage=Korean
		) else set CurrentLanguage=None
	)
	if NOT "!CurrentLanguage!"=="None" (
		for /F "usebackq delims=" %%j in ("AudioPatch_!CurrentLanguage!_!oldVer!-!newVer!.txt") do (
			attrib -R "%%j" && "hpatchz.exe" -f "%%j" "%%j.hdiff" "%%j"
		)
	)
)
for /F "usebackq delims=" %%i in ("AudioPatch_Common_!oldVer!-!newVer!.txt") do (
	attrib -R "%%i" && "hpatchz.exe" -f "%%i" "%%i.hdiff" "%%i"
)

set PatchFinished=True

for /L %%i in (1,1,4) do (
	if "%%i"=="1" (
		if "%ChineseInstalled%"=="True" (
			set CurrentLanguage=Chinese
		) else set CurrentLanguage=None
	)
	if "%%i"=="2" (
		if "%EnglishInstalled%"=="True" (
			set CurrentLanguage=English
		) else set CurrentLanguage=None
	)
	if "%%i"=="3" (
		if "%JapaneseInstalled%"=="True" (
			set CurrentLanguage=Japanese
		) else set CurrentLanguage=None
	)
	if "%%i"=="4" (
		if "%KoreanInstalled%"=="True" (
			set CurrentLanguage=Korean
		) else set CurrentLanguage=None
	)
	if NOT "!CurrentLanguage!"=="None" (
		for /F "usebackq delims=" %%k in ("AudioPatch_!CurrentLanguage!_!oldVer!-!newVer!.txt") do (
			if exist "%%k.hdiff" del "%%k.hdiff"
		)
	)
)

for /F "usebackq delims=" %%i in ("Cleanup_!oldVer!-!newVer!.txt") do (
	if exist "%%i" attrib -R "%%i" && del "%%i"
)

for /F "usebackq delims=" %%i in ("AudioPatch_Common_!oldVer!-!newVer!.txt") do (
	if exist "%%i.hdiff" del "%%i.hdiff"
)

del hpatchz.exe hdiffz.exe *.dmp *.bak *.txt *.log
rd /s /q "ZenlessZoneZero_Data\SDKCaches" "ZenlessZoneZero_Data\webCaches" 2>nul 
echo.
echo Patch completed^^!
echo.
goto End

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
  
  if exist "Start.bat" del "Start.bat"
)