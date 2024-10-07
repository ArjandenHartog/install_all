::version 1.2
:: Author: Arjan den Hartog 

@echo off
setlocal

:: Check if the script is being run with administrator rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Running with administrator rights...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~fnx0' -Verb RunAs"
    exit /b
)

echo Automatic installation begins...

:: Debugging: Show the script location
echo Script location: %~dp0

REM Get the drive letter of the USB stick
set USB_DRIVE=%~d0

REM Set the path to the desired folder on the USB stick
set TARGET_DIR=%USB_DRIVE%

:: Install Adobe Acrobat
echo Installing Adobe Acrobat...
start "" /B "%TARGET_DIR%\1. Pre-installatie\Reader_Install_Setup.exe" /sAll /v"/qn" || echo Failed to install Adobe Acrobat.

:: Install Bever Support
echo Installing Bever Support...
start "" /B "%TARGET_DIR%\1. Pre-installatie\Bever_Support.exe" /s /v"/qn" || echo Failed to install Bever Support.

:: Apply Themes
echo Applying theme 1...
control /name Microsoft.Personalization /page pageThemes || echo Failed to apply theme 1.
timeout /t 5 /nobreak >nul
start "" /B "%TARGET_DIR%\1. Pre-installatie\BeverThemeDonker.deskthemepack" || echo Failed to apply theme 1.

echo Applying theme 2...
control /name Microsoft.Personalization /page pageThemes || echo Failed to apply theme 2.
timeout /t 5 /nobreak >nul
start "" /B "%TARGET_DIR%\1. Pre-installatie\BeverThemeLicht.deskthemepack" || echo Failed to apply theme 2.

:: Install Google Chrome
echo Installing Google Chrome...
start "" /B "%TARGET_DIR%\1. Pre-installatie\ChromeSetup.exe" /silent /install || echo Failed to install Google Chrome.

:: Apply Registry Keys
echo Applying registry keys...
start "" /B regedit /s "%TARGET_DIR%\1. Pre-installatie\RegistryKeys.reg" || echo Failed to apply registry keys.

:: Verwijder Nederlands toetsenbord via PowerShell
powershell -Command "& { $Lang = Get-WinUserLanguageList; $Lang[0].InputMethods.Remove('0409:00000409'); Set-WinUserLanguageList $Lang -Force }"


:: Never turn off the display and never go to sleep
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0

:: Kopieer Bever Support naar het bureaublad
echo Kopiëren van Bever Support naar het bureaublad...
copy "D:\1. Pre-installatie\Bever_Support.exe" "%userprofile%\Desktop\Bever_Support.exe"
echo Bever Support gekopieerd naar het bureaublad.

echo Installation completed!
pause
