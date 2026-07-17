@echo off
setlocal

set "TEMPDIR=%TEMP%"
set "INSTALLER=%TEMPDIR%\ChromeInstaller.exe"

curl -L -o "%INSTALLER%" "https://dl.google.com/chrome/install/latest/chrome_installer.exe"

start /wait "" "%INSTALLER%" /silent /install

del /f /q "%INSTALLER%" >nul 2>&1

exit
