@echo off
setlocal
for %%I in ("%~dp0.") do set "ROOT=%%~fI"
if exist "%ROOT%\CORE\edualc_captain_windows.ps1" goto ROOT_READY
set "ROOT=D:\TRINITY\universal"
if exist "%ROOT%\CORE\edualc_captain_windows.ps1" goto ROOT_READY
set "ROOT=%ProgramData%\TRINITY\universal"
if exist "%ROOT%\CORE\edualc_captain_windows.ps1" goto ROOT_READY
set "ROOT=%LOCALAPPDATA%\TRINITY\universal"
if exist "%ROOT%\CORE\edualc_captain_windows.ps1" goto ROOT_READY
call "%~dp0INSTALL_TRINITY.cmd"
exit /b %errorlevel%

:ROOT_READY
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\CORE\edualc_captain_windows.ps1" -Root "%ROOT%" -Once
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\CORE\start_local_edualc_windows.ps1" -Root "%ROOT%"
if errorlevel 1 where python.exe >nul 2>nul && python.exe "%ROOT%\CORE\start_local_edualc.py" --root "%ROOT%"
start "" /min powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "%ROOT%\CORE\edualc_captain_windows.ps1" -Root "%ROOT%"
echo TRINITY STARTED. State: %ROOT%\STATE
exit /b 0
