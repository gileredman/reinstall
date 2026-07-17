@echo off
mode con cp select=437 >nul
set "TASK_NAME=install-chrome-on-startup"
set "TASK_LOG=%SystemRoot%\Temp\chrome-startup-task.log"

echo [%DATE% %TIME%] Registering startup task for Chrome install...>>"%TASK_LOG%"
schtasks /Create /TN "%TASK_NAME%" /SC ONSTART /RU "SYSTEM" /RL HIGHEST /TR "%SystemDrive%\windows-install-chrome.bat" /F >>"%TASK_LOG%" 2>&1
if errorlevel 1 (
    echo [%DATE% %TIME%] Failed to register startup task.>>"%TASK_LOG%"
    echo [%DATE% %TIME%] Running Chrome install directly as fallback...>>"%TASK_LOG%"
    call "%SystemDrive%\windows-install-chrome.bat" >>"%TASK_LOG%" 2>&1
) else (
    echo [%DATE% %TIME%] Running startup task immediately...>>"%TASK_LOG%"
    schtasks /Run /TN "%TASK_NAME%" >>"%TASK_LOG%" 2>&1
    if errorlevel 1 (
        echo [%DATE% %TIME%] Failed to run startup task immediately, running direct fallback...>>"%TASK_LOG%"
        call "%SystemDrive%\windows-install-chrome.bat" >>"%TASK_LOG%" 2>&1
    )
)

del "%~f0"
