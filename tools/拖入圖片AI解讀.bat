@echo off
title AI image understanding
chcp 65001 >nul
set PYTHONIOENCODING=utf-8
set PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe
if not exist "%PY%" set PY=python
if "%~1"=="" (
  echo Drag an image (.png .jpg .tif .bmp) onto this .bat.
  echo The AI vision model will describe it or answer your question about it.
  pause
  exit /b 1
)
"%PY%" "%~dp0scripts\describe_image.py" "%~1"
echo.
pause
