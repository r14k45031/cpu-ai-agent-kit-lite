@echo off
title Quick model test
set OLLAMA=%LOCALAPPDATA%\Programs\Ollama\ollama.exe
if not exist "%OLLAMA%" (
  echo Ollama not found. Run install.bat first.
  pause
  exit /b 1
)
echo Testing model qwen3-4b (first load takes a while on CPU)...
"%OLLAMA%" run qwen3-4b "請用繁體中文以一句話介紹你自己"
echo.
pause
