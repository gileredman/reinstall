@echo off
mode con cp select=437 >nul
set "TASK_NAME=install-chrome-on-startup"
set "INSTALL_LOG=%SystemRoot%\Temp\chrome-install.log"
set "CHROME_MSI_URL=https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi"
set "CHROME_MSI=%TEMP%\chrome_installer.msi"
set "CHROME_MSI_INSTALL_LOG=%SystemRoot%\Temp\chrome-install-msi.log"
set "CHROME_WINGET_INSTALL_LOG=%SystemRoot%\Temp\chrome-install-winget.log"

call :log Chrome startup install task started.

if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" goto :success
if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" goto :success

call :log Waiting for network before Chrome install...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ready=$false; 1..24 | ForEach-Object { try { Invoke-WebRequest -Uri 'https://dl.google.com/generate_204' -UseBasicParsing -TimeoutSec 10 | Out-Null; $ready=$true; break } catch { Start-Sleep -Seconds 5 } }; if (-not $ready) { exit 1 }"
if errorlevel 1 (
    set "NET_READY_EXIT_CODE=%ERRORLEVEL%"
    call :log ERROR: Network not ready before install (exit code %NET_READY_EXIT_CODE%), will retry on next startup.
    exit /b 1
)

call :log Downloading Chrome MSI...
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '%CHROME_MSI_URL%' -OutFile '%CHROME_MSI%' -UseBasicParsing } catch { exit 1 }"
if exist "%CHROME_MSI%" (
    call :log Installing Chrome via MSI...
    msiexec /i "%CHROME_MSI%" /qn /norestart /log "%CHROME_MSI_INSTALL_LOG%"
    set "MSI_INSTALL_EXIT_CODE=%ERRORLEVEL%"
    if not "%MSI_INSTALL_EXIT_CODE%"=="0" call :log ERROR: MSI install command exited with code %MSI_INSTALL_EXIT_CODE%.
) else (
    set "MSI_DOWNLOAD_EXIT_CODE=%ERRORLEVEL%"
    call :log ERROR: Failed to download Chrome MSI (exit code %MSI_DOWNLOAD_EXIT_CODE%).
)

if not exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" if not exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" (
    call :log MSI unavailable/failed, falling back to winget...
    where winget >nul 2>&1
    if errorlevel 1 (
        call :log ERROR: winget is not available in PATH, cannot perform fallback installation.
    ) else (
        winget install --id Google.Chrome --exact --silent --scope machine --accept-source-agreements --accept-package-agreements --disable-interactivity >>"%CHROME_WINGET_INSTALL_LOG%" 2>&1
        set "WINGET_INSTALL_EXIT_CODE=%ERRORLEVEL%"
        if not "%WINGET_INSTALL_EXIT_CODE%"=="0" call :log ERROR: winget install exited with code %WINGET_INSTALL_EXIT_CODE%.
    )
)

if exist "%ProgramFiles%\Google\Chrome\Application\chrome.exe" goto :success
if exist "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe" goto :success

call :log ERROR: Chrome install failed, will retry on next startup.
del /f /q "%CHROME_MSI%" >nul 2>&1
exit /b 1

:success
call :log Chrome install succeeded or already present.
del /f /q "%CHROME_MSI%" >nul 2>&1
schtasks /Change /TN "%TASK_NAME%" /DISABLE >nul 2>&1
exit /b 0

:log
echo [%DATE% %TIME%] %*>>"%INSTALL_LOG%"
exit /b 0
