@echo off
title Convert documents to Markdown
chcp 65001 >nul
set PYTHONIOENCODING=utf-8
set PY=%LOCALAPPDATA%\Programs\Python\Python313\python.exe
if not exist "%PY%" set PY=python
if "%~1"=="" (
  echo Drag a file OR a whole folder onto this .bat to convert to Markdown.
  echo Supported: .docx .pdf .pptx .xlsx .csv .txt and images
  pause
  exit /b 1
)
"%PY%" "%~dp0scripts\convert_to_md.py" "%~1"
echo.
pause
