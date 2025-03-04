@echo off
echo Ollama with Open WebUI - Simple Windows Launcher
echo =============================================

REM Check if Python is installed
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Python is not installed or not in PATH.
    echo Please install Python and try again.
    goto :end
)

REM Check if podman-compose is installed
python -c "import podman_compose" 2>nul
if %errorlevel% neq 0 (
    echo podman-compose is not installed. Installing now...
    pip install podman-compose
    if %errorlevel% neq 0 (
        echo Failed to install podman-compose.
        echo Please install it manually with 'pip install podman-compose'.
        goto :end
    )
)

echo.
echo Choose profile:
echo 1. CPU (default)
echo 2. GPU (NVIDIA GPU required)
choice /c 12 /n /m "Enter your choice (1 or 2): "

set PROFILE=
if errorlevel 2 (
    echo Starting with GPU profile...
    set PROFILE=--profile gpu
) else (
    echo Starting with CPU profile...
)

echo.
echo Choose action:
echo 1. Start containers
echo 2. Stop containers
choice /c 12 /n /m "Enter your choice (1 or 2): "

if errorlevel 2 (
    echo Stopping containers...
    python windows_podman.py down %PROFILE%
) else (
    echo Starting containers...
    python windows_podman.py up %PROFILE%
)

:end
pause
