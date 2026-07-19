@echo off
:: Template SetupComplete.cmd
:: Letakkan file ini di: C:\Windows\Setup\Scripts\SetupComplete.cmd
:: Pastikan script PowerShell tersedia di: C:\Scripts\postinstall-tweaks.ps1

powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\postinstall-tweaks.ps1"
exit /b 0
