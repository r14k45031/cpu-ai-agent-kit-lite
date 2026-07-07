@echo off
title OCR scanned PDF
chcp 65001 >nul
set PYTHONIOENCODING=utf-8
set PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe
if not exist "%PY%" set PY=python
if "%~1"=="" (
  echo Drag a scanned PDF onto this .bat to extract its text.
  pause
  exit /b 1
)
"%PY%" "%~dp0scripts\ocr_pdf.py" "%~1"
echo.
pause
