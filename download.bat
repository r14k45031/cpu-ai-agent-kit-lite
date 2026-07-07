@echo off
title Download offline kit files (LITE, ~5 GB)
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0download.ps1"
echo.
pause
