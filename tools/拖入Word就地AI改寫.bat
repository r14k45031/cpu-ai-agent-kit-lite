@echo off
title edit_docx_inplace
chcp 65001 >nul
set PYTHONIOENCODING=utf-8
set PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe
if not exist "%PY%" set PY=python
if "%~1"=="" (
  echo Drag a .docx onto this .bat. AI rewrites each paragraph IN PLACE - styles, tables and images are preserved.
  pause
  exit /b 1
)
"%PY%" "%~dp0scripts\edit_docx_inplace.py" "%~1"
echo.
pause
