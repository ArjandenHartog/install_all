@echo off
setlocal EnableDelayedExpansion

:: Version 1.5
:: Author: Arjan den Hartog 

:: Check if the script is being run with administrator rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Running with administrator rights...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~fnx0' -Verb RunAs" -WindowStyle Hidden
    exit /b
)

echo Automatic installation begins...
echo This window will stay open to show progress...

:: Get the drive letter where the script is located
set "SCRIPT_PATH=%~dp0"
set "INSTALL_PATH=%SCRIPT_PATH%1. Pre-installaties"

:: Create log directory
md "%SCRIPT_PATH%logs" 2>nul
set "LOG_FILE=%SCRIPT_PATH%logs\install_%date:~-4,4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%.log"
set "LOG_FILE=%LOG_FILE: =0%"

:: Start logging
echo Installation started at %date% %time% > "%LOG_FILE%"

:: Wait for network
echo Waiting for network connection...
:checkNetwork
ping -n 1 8.8.8.8 >nul 2>&1
if %errorlevel% neq 0 (
    echo Network not ready, waiting...
    timeout /t 5 /nobreak >nul
    goto checkNetwork
)
echo Network connection established >> "%LOG_FILE%"

:: Install Windows Updates first
echo Installing Windows Updates (this may take a while)...
echo Installing Windows Updates... >> "%LOG_FILE%"
powershell -ExecutionPolicy Bypass -Command "& {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
    
    # Install NuGet if needed
    if (!(Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    }
    
    # Install and import PSWindowsUpdate module
    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module PSWindowsUpdate -Force -Confirm:$false
    }
    Import-Module PSWindowsUpdate
    
    # Download and install updates with retry logic
    $maxAttempts = 3
    $attempt = 1
    do {
        try {
            Write-Output 'Checking for Windows updates...'
            Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot | Out-File '$env:TEMP\WindowsUpdate.log' -Append
            $success = $true
        } catch {
            Write-Output "Attempt $attempt failed: $_"
            $success = $false
            $attempt++
            Start-Sleep -Seconds 30
        }
    } while (!$success -and $attempt -le $maxAttempts)
}" >> "%LOG_FILE%" 2>&1

if %errorlevel% equ 0 (
    echo Windows Updates installed successfully >> "%LOG_FILE%"
) else (
    echo WARNING: Windows Updates may not have installed completely >> "%LOG_FILE%"
)

:: Verify installation files exist
if not exist "%INSTALL_PATH%\Bever_Support.exe" (
    echo ERROR: Required installation files not found in: %INSTALL_PATH%
    echo ERROR: Required installation files not found >> "%LOG_FILE%"
    pause
    exit /b 1
)

:: Install Bever Support silently
echo Installing Bever Support...
start /wait "" "%INSTALL_PATH%\Bever_Support.exe" /s /v"/qn"
if %errorlevel% equ 0 (
    echo Bever Support installed successfully >> "%LOG_FILE%"
) else (
    echo ERROR: Bever Support installation failed >> "%LOG_FILE%"
    echo ERROR: Bever Support installation failed
    pause
)

:: Apply Themes silently
echo Applying themes...
if exist "%INSTALL_PATH%\BeverThemeDonker.deskthemepack" start /wait "" "%INSTALL_PATH%\BeverThemeDonker.deskthemepack"
if exist "%INSTALL_PATH%\BeverThemeLicht.deskthemepack" start /wait "" "%INSTALL_PATH%\BeverThemeLicht.deskthemepack"
echo Themes applied >> "%LOG_FILE%"

:: Install Google Chrome silently
echo Installing Google Chrome...
if exist "%INSTALL_PATH%\ChromeSetup.exe" (
    start /wait "" "%INSTALL_PATH%\ChromeSetup.exe" /silent /install
    if %errorlevel% equ 0 (
        echo Chrome installed successfully >> "%LOG_FILE%"
    ) else (
        echo ERROR: Chrome installation failed >> "%LOG_FILE%"
        echo ERROR: Chrome installation failed
        pause
    )
)

:: Apply Registry Keys
echo Applying registry keys...
if exist "%INSTALL_PATH%\RegistryKeys.reg" (
    reg import "%INSTALL_PATH%\RegistryKeys.reg" >> "%LOG_FILE%" 2>&1
)

:: Configure power settings
echo Configuring power settings...
powercfg /change monitor-timeout-ac 0
powercfg /change monitor-timeout-dc 0
powercfg /change disk-timeout-ac 0
powercfg /change disk-timeout-dc 0
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0
echo Power settings configured >> "%LOG_FILE%"

:: Configure Windows Update for automatic updates
echo Configuring automatic Windows Updates...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoUpdate /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 4 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v ScheduledInstallDay /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v ScheduledInstallTime /t REG_DWORD /d 3 /f
echo Windows Update configured for automatic updates >> "%LOG_FILE%"

:: Copy Bever Support to desktop
echo Copying Bever Support to desktop...
if exist "%INSTALL_PATH%\Bever_Support.exe" (
    copy /y "%INSTALL_PATH%\Bever_Support.exe" "%userprofile%\Desktop\Bever_Support.exe" >> "%LOG_FILE%" 2>&1
)

:: Remove auto-logon
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 0 /f

:: Create a marker file to indicate successful installation
echo Installation completed at %date% %time% >> "%LOG_FILE%"
echo Installation completed successfully!
echo Check the log file at %LOG_FILE% for details.

echo.
echo Press any key to close this window...
pause >nul
exit /b 0
