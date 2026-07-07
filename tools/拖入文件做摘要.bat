@echo off
title AI summarize
chcp 65001 >nul
set PYTHONIOENCODING=utf-8
set PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe
if not exist "%PY%" set PY=python
if "%~1"=="" (
  echo Drag a file OR a whole folder onto this .bat to summarize it.
  echo Supported: .pdf .docx .txt .md
  pause
  exit /b 1
)
"%PY%" "%~dp0scripts\summarize.py" "%~1"
echo.
pause
