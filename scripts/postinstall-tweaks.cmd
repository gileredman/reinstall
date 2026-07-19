@echo off
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0postinstall-tweaks.ps1"

echo.
echo Selesai. Disarankan restart Windows.
pause
