@echo off
title excel_ai
chcp 65001 >nul
set PYTHONIOENCODING=utf-8
set PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe
if not exist "%PY%" set PY=python
if "%~1"=="" (
  echo Drag a .xlsx or .csv onto this .bat. AI analyzes the data or answers your question about it.
  pause
  exit /b 1
)
"%PY%" "%~dp0scripts\excel_ai.py" "%~1"
echo.
pause
