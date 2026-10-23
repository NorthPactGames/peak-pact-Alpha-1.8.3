@echo off
chcp 65001 >nul
title Peak Pact Setup
setlocal EnableExtensions

set "INSTALL=%LOCALAPPDATA%\PeakPact"
set "SRC=%~dp0"

echo.
echo  ========================================
echo   PEAK PACT — установка
echo   Без Node.js
echo  ========================================
echo.

if not exist "%SRC%game\peak-pact.html" if not exist "%SRC%peak-pact.html" (
  echo [ERROR] peak-pact.html not found
  pause
  exit /b 1
)

mkdir "%INSTALL%" 2>nul
mkdir "%INSTALL%\game" 2>nul

echo [1/3] Copy files...
if exist "%SRC%game\peak-pact.html" (
  xcopy /E /Y /Q "%SRC%game\*" "%INSTALL%\game\" >nul
) else (
  copy /Y "%SRC%peak-pact.html" "%INSTALL%\game\" >nul
)

copy /Y "%SRC%PeakPact.vbs" "%INSTALL%\PeakPact.vbs" >nul
if exist "%SRC%PeakPact.bat" copy /Y "%SRC%PeakPact.bat" "%INSTALL%\" >nul
if exist "%SRC%Create-Shortcut.vbs" copy /Y "%SRC%Create-Shortcut.vbs" "%INSTALL%\" >nul
if exist "%SRC%peak-pact.ico" copy /Y "%SRC%peak-pact.ico" "%INSTALL%\" >nul
if exist "%INSTALL%\game\peak-pact.ico" copy /Y "%INSTALL%\game\peak-pact.ico" "%INSTALL%\" >nul

echo [2/3] Desktop shortcut...
cscript //nologo "%INSTALL%\Create-Shortcut.vbs"
if errorlevel 1 (
  echo Fallback PowerShell shortcut...
  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$t=Join-Path $env:LOCALAPPDATA 'PeakPact\PeakPact.vbs'; $d=[Environment]::GetFolderPath('Desktop'); if(-not $d){$d=Join-Path $env:USERPROFILE 'Desktop'}; $s=(New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path $d 'Peak Pact.lnk')); $s.TargetPath='wscript.exe'; $s.Arguments='//nologo \"'+$t+'\"'; $s.WorkingDirectory=(Join-Path $env:LOCALAPPDATA 'PeakPact'); $ico=Join-Path $env:LOCALAPPDATA 'PeakPact\peak-pact.ico'; if(Test-Path $ico){$s.IconLocation=$ico}; $s.Save(); Write-Host OK"
)

echo [3/3] Done.
echo.
echo  Install folder: %INSTALL%
echo  Shortcut name:  Peak Pact
echo  If no icon on desktop, run:
echo    %INSTALL%\Create-Shortcut.vbs
echo  Or start game:
echo    %INSTALL%\PeakPact.vbs
echo.
choice /C YN /M "Start Peak Pact now"
if errorlevel 2 goto end
if errorlevel 1 wscript //nologo "%INSTALL%\PeakPact.vbs"
:end
pause
