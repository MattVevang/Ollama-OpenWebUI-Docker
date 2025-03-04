@echo off
setlocal

echo Ollama with Open WebUI - Windows Launcher
echo =========================================

echo.
echo Choose profile:
echo 1. CPU (default)
echo 2. GPU (NVIDIA GPU required)
choice /c 12 /n /m "Enter your choice (1 or 2): "

set PROFILE=
if errorlevel 2 (
    echo Starting with GPU profile...
    set "PROFILE=gpu"
) else (
    echo Starting with CPU profile...
)

echo.
echo Choose action:
echo 1. Start containers
echo 2. Stop containers
echo 3. Show logs
choice /c 123 /n /m "Enter your choice (1, 2, or 3): "

if errorlevel 3 (
    echo Showing logs...
    if "%PROFILE%"=="gpu" (
        docker logs ollama-gpu
        echo.
        echo ===== WebUI Logs =====
        echo.
        docker logs open-webui
    ) else (
        docker logs ollama-cpu
        echo.
        echo ===== WebUI Logs =====
        echo.
        docker logs open-webui
    )
) else if errorlevel 2 (
    call stop.bat
) else (
    if "%PROFILE%"=="gpu" (
        call start.bat gpu
    ) else (
        call start.bat
    )
)

echo.
pause
