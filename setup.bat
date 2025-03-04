@echo off
echo Starting Ollama with Open WebUI...

REM Check if Python is installed
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python is not installed or not in PATH. Please install Python and try again.
    goto :end
)

REM Check if podman-compose is installed
python -c "import podman_compose" 2>nul
if %errorlevel% neq 0 (
    echo podman-compose is not installed. Installing now...
    pip install podman-compose
    if %errorlevel% neq 0 (
        echo Failed to install podman-compose. Please install it manually with 'pip install podman-compose'.
        goto :end
    )
)

REM Check if CPU or GPU profile should be used
echo Choose profile:
echo 1. CPU (default)
echo 2. GPU (requires NVIDIA GPU)
choice /c 12 /n /m "Enter your choice (1 or 2): "

if errorlevel 2 (
    echo Starting with GPU profile...
    python custom_podman_compose.py --profile gpu up
) else (
    echo Starting with CPU profile...
    python custom_podman_compose.py up
)

:end
pause
