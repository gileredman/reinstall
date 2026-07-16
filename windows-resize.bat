@echo off
mode con cp select=437 >nul
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
$LocalTempDir = $env:TEMP; $ChromeInstaller = "ChromeInstaller.exe"; (new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); & "$LocalTempDir\$ChromeInstaller" /silent /install; $Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)

set C=%SystemDrive:~0,1%
for /f "tokens=2" %%a in ('echo list vol ^| diskpart ^| findstr "\<installer\>"') do (echo select vol %%a & echo delete partition) | diskpart
for /f "tokens=2" %%a in ('echo list vol ^| diskpart ^| findstr "\<%C%\>"') do (echo select vol %%a & echo extend) | diskpart
del "%~f0"




