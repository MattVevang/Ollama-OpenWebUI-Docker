@echo off
echo Ollama with Open WebUI - Log Viewer
echo =================================

echo.
echo Choose profile:
echo 1. CPU (default)
echo 2. GPU
choice /c 12 /n /m "Enter your choice (1 or 2): "

if errorlevel 2 (
    echo Viewing GPU mode logs...
    python simple_log_follow.py --profile gpu
) else (
    echo Viewing CPU mode logs...
    python simple_log_follow.py
)

pause
