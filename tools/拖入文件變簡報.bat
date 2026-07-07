@echo off
title outline_to_pptx
chcp 65001 >nul
set PYTHONIOENCODING=utf-8
set PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe
if not exist "%PY%" set PY=python
if "%~1"=="" (
  echo Drag a .docx/.pdf/.txt/.md onto this .bat. AI builds a PowerPoint outline from it.
  pause
  exit /b 1
)
"%PY%" "%~dp0scripts\outline_to_pptx.py" "%~1"
echo.
pause
