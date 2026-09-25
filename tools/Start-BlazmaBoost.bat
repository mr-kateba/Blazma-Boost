@echo off
rem Blazma Boost launcher: runs winutil.ps1 from the same folder; WinUtil asks for administrator rights itself
if not exist "%~dp0winutil.ps1" (
    echo winutil.ps1 was not found next to this file.
    echo Extract the zip first: right click BlazmaBoost.zip, choose "Extract All", then run Start-BlazmaBoost.bat from the extracted folder.
    pause
    exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0winutil.ps1"
