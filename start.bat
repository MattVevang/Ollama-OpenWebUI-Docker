@echo off
echo Ollama with Open WebUI - Windows Podman Launcher
echo ==============================================

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
echo Choose launcher method:
echo 1. Simple launcher (recommended)
echo 2. Advanced patching launcher
echo 3. Direct podman-compose call
choice /c 123 /n /m "Enter your choice (1-3): "

if errorlevel 3 (
    echo Using direct podman-compose call...
    podman-compose %PROFILE% up
) else if errorlevel 2 (
    echo Using advanced patching launcher...
    python custom_podman_compose.py %PROFILE% up
) else (
    echo Using simple launcher...
    python simple_podman_compose.py %PROFILE% up
)

:end
pause
