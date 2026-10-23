@echo off
chcp 65001 >nul
set "INSTALL=%LOCALAPPDATA%\PeakPact"
echo Удалить Peak Pact?
pause
rmdir /S /Q "%INSTALL%" 2>nul
del "%USERPROFILE%\Desktop\Peak Pact.lnk" 2>nul
del "%USERPROFILE%\OneDrive\Desktop\Peak Pact.lnk" 2>nul
del "%USERPROFILE%\OneDrive\Рабочий стол\Peak Pact.lnk" 2>nul
del "%PUBLIC%\Desktop\Peak Pact.lnk" 2>nul
echo Готово.
pause
