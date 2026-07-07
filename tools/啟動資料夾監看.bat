@echo off
title AI folder watcher
chcp 65001 >nul
set PYTHONIOENCODING=utf-8
set PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe
if not exist "%PY%" set PY=python
"%PY%" "%~dp0scripts\watch_folder.py"
pause
