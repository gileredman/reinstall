@echo off
mode con cp select=437 >nul
set "TASK_NAME=install-chrome-on-startup"
set "INSTALL_LOG=%SystemRoot%\Temp\chrome-install.log"
set "CHROME_MSI_URL=https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"
set "CHROME_EXE_URL=https://dl.google.com/chrome/install/latest/chrome_installer.exe"
set "CHROME_MSI=%TEMP%\chrome_installer.msi"
set "CHROME_EXE=%TEMP%\chrome_installer.exe"
set "CHROME_MSI_INSTALL_LOG=%SystemRoot%\Temp\chrome-install-msi.log"
set "CHROME_EXE_INSTALL_LOG=%SystemRoot%\Temp\chrome-install-exe.log"

echo [%DATE% %TIME%] Chrome startup install task started.>>"%INSTALL_LOG%"

if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" goto :success
if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" goto :success

echo [%DATE% %TIME%] Waiting for network before Chrome install...>>"%INSTALL_LOG%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ready=$false; 1..24 | ForEach-Object { try { Invoke-WebRequest -Uri 'https://dl.google.com/generate_204' -UseBasicParsing -TimeoutSec 10 | Out-Null; $ready=$true; break } catch { Start-Sleep -Seconds 5 } }; if (-not $ready) { exit 1 }"
if errorlevel 1 (
    echo [%DATE% %TIME%] Network not ready, will retry on next startup.>>"%INSTALL_LOG%"
    exit /b 1
)

echo [%DATE% %TIME%] Downloading Chrome MSI...>>"%INSTALL_LOG%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%CHROME_MSI_URL%' -OutFile '%CHROME_MSI%' -UseBasicParsing } catch { exit 1 }"
if exist "%CHROME_MSI%" (
    echo [%DATE% %TIME%] Installing Chrome via MSI...>>"%INSTALL_LOG%"
    msiexec /i "%CHROME_MSI%" /qn /norestart /log "%CHROME_MSI_INSTALL_LOG%"
)

if not exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" if not exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
    echo [%DATE% %TIME%] MSI unavailable/failed, falling back to EXE...>>"%INSTALL_LOG%"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%CHROME_EXE_URL%' -OutFile '%CHROME_EXE%' -UseBasicParsing } catch { exit 1 }"
    if exist "%CHROME_EXE%" (
        "%CHROME_EXE%" /silent /install >>"%CHROME_EXE_INSTALL_LOG%" 2>&1
    )
)

if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" goto :success
if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" goto :success

echo [%DATE% %TIME%] Chrome install failed, will retry on next startup.>>"%INSTALL_LOG%"
del /f /q "%CHROME_MSI%" "%CHROME_EXE%" >nul 2>&1
exit /b 1

:success
echo [%DATE% %TIME%] Chrome install succeeded or already present.>>"%INSTALL_LOG%"
del /f /q "%CHROME_MSI%" "%CHROME_EXE%" >nul 2>&1
schtasks /Change /TN "%TASK_NAME%" /DISABLE >nul 2>&1
exit /b 0
