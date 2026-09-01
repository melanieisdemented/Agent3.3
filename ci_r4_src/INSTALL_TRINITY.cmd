@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0CORE\install_windows.ps1"
exit /b %errorlevel%
