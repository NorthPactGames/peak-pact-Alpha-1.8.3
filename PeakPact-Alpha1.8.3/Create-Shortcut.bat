@echo off
chcp 65001 >nul
set "INSTALL=%LOCALAPPDATA%\PeakPact"
if not exist "%INSTALL%\PeakPact.vbs" (
  echo Run Install-PeakPact.bat first
  pause
  exit /b 1
)
if exist "%~dp0Create-Shortcut.vbs" (
  cscript //nologo "%~dp0Create-Shortcut.vbs"
) else if exist "%INSTALL%\Create-Shortcut.vbs" (
  cscript //nologo "%INSTALL%\Create-Shortcut.vbs"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=Join-Path $env:LOCALAPPDATA 'PeakPact\PeakPact.vbs'; $d=[Environment]::GetFolderPath('Desktop'); $s=(New-Object -ComObject WScript.Shell).CreateShortcut((Join-Path $d 'Peak Pact.lnk')); $s.TargetPath='wscript.exe'; $s.Arguments='//nologo \"'+$t+'\"'; $s.Save(); Write-Host OK"
)
pause
