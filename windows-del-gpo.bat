@echo off
mode con cp select=437 >nul
setlocal enabledelayedexpansion
set USERNAME=Administrator

REM Jalankan perintah PowerShell untuk AD (jika user ada di AD)
powershell -NoProfile -Command "Import-Module ActiveDirectory; Set-ADUser -Identity '%USERNAME%' -ChangePasswordAtLogon $true"

REM Jalankan perintah untuk user lokal
net user %USERNAME% /logonpasswordchg:yes

set "files[1]=%windir%\System32\GroupPolicy\gpt.ini"
set "files[2]=%windir%\System32\GroupPolicy\Machine\Scripts\scripts.ini"

for %%i in (1 2) do (
    set "ini=!files[%%i]!"
    if exist "!ini!.orig" (
        move /y "!ini!.orig" "!ini!"
    ) else (
        del "!ini!"
    )
)

del "%~f0"





