@echo off
title AI rewrite / polish
chcp 65001 >nul
set PYTHONIOENCODING=utf-8
set PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe
if not exist "%PY%" set PY=python
if "%~1"=="" (
  echo Drag a .docx / .txt / .md file onto this .bat to rewrite it.
  pause
  exit /b 1
)
"%PY%" "%~dp0scripts\polish_docx.py" "%~1"
echo.
pause
