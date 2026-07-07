@echo off
title AI process Excel rows
chcp 65001 >nul
set PYTHONIOENCODING=utf-8
set PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe
if not exist "%PY%" set PY=python
if "%~1"=="" (
  echo Drag a .xlsx or .csv onto this .bat.
  echo AI processes every row and writes results into a new column.
  pause
  exit /b 1
)
"%PY%" "%~dp0scripts\excel_process.py" "%~1"
echo.
pause
