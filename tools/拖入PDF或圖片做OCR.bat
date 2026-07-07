@echo off
title OCR scanned PDF or image
chcp 65001 >nul
set PYTHONIOENCODING=utf-8
set PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe
if not exist "%PY%" set PY=python
if "%~1"=="" (
  echo Drag a scanned PDF or an image file onto this .bat to extract its text.
  echo Supported: .pdf .png .jpg .jpeg .tif .tiff .bmp
  pause
  exit /b 1
)
"%PY%" "%~dp0scripts\ocr_pdf.py" "%~1"
echo.
pause
