@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\postinstall-tweaks.ps1"
exit /b 0
