@echo off
title Markdown to Word (pandoc)
chcp 65001 >nul
set PANDOC=%LOCALAPPDATA%\Pandoc\pandoc.exe
if not exist "%PANDOC%" set PANDOC=pandoc
if "%~1"=="" (
  echo Drag a .md or .txt file onto this .bat to convert it to .docx
  pause
  exit /b 1
)
"%PANDOC%" -f gfm -o "%~dpn1.docx" "%~1"
if errorlevel 1 (
  echo Conversion failed. Is pandoc installed? Run install.bat first.
) else (
  echo Created: %~dpn1.docx
)
echo.
pause
