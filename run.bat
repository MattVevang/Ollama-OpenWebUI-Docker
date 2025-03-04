@echo off
setlocal enabledelayedexpansion

echo Checking for container engines...

REM Check for Docker
set "DOCKER_INSTALLED=false"
where docker >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set "DOCKER_INSTALLED=true"
    echo Docker detected.
)

REM Check for Podman
set "PODMAN_INSTALLED=false"
set "PODMAN_RUNNING=false"
where podman >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set "PODMAN_INSTALLED=true"
    echo Podman detected.
    
    REM Check if Podman is running
    podman info >nul 2>nul
    if !ERRORLEVEL! EQU 0 (
        set "PODMAN_RUNNING=true"
        echo Podman is running.
    ) else (
        echo Podman is installed but not running.
    )
)

REM Check if neither is installed
if "!DOCKER_INSTALLED!"=="false" if "!PODMAN_INSTALLED!"=="false" (
    echo Error: Neither Docker nor Podman is installed or in PATH.
    echo Please install Docker or Podman and try again.
    goto :end
)

REM If both are installed, ask user which one to use
set "ENGINE="
if "!DOCKER_INSTALLED!"=="true" if "!PODMAN_INSTALLED!"=="true" (
    echo.
    echo Both Docker and Podman are installed.
    echo Choose engine:
    echo 1. Docker
    echo 2. Podman
    choice /c 12 /n /m "Enter your choice (1 or 2): "
    
    if !errorlevel! EQU 2 (
        set "ENGINE=podman"
        echo Using Podman as container engine.
        if "!PODMAN_RUNNING!"=="false" goto :start_podman
        goto :continue_script
    ) else (
        set "ENGINE=docker"
        echo Using Docker as container engine.
        goto :check_docker
    )
) else if "!DOCKER_INSTALLED!"=="true" (
    set "ENGINE=docker"
    echo Using Docker as container engine.
    goto :check_docker
) else if "!PODMAN_INSTALLED!"=="true" (
    set "ENGINE=podman"
    echo Using Podman as container engine.
    if "!PODMAN_RUNNING!"=="false" goto :start_podman
    goto :continue_script
)

:check_docker
REM Check Docker status immediately after selection
docker info >nul 2>nul
if !errorlevel! NEQ 0 (
    echo.
    echo Docker is not running. Do you want to start Docker now?
    choice /c YN /n /m "Start Docker? (Y/N): "
    if !errorlevel! EQU 2 (
        echo Docker must be running to continue. Exiting...
        goto :end
    ) else (
        echo Starting Docker service...
        start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        echo Waiting for Docker to start (this may take a moment^)...
        
        set /a attempts=0
        set /a max_attempts=30
        
        :docker_check_loop
        timeout /t 3 >nul
        set /a attempts+=1
        echo Checking if Docker is responsive (attempt !attempts! of !max_attempts!^)...
        
        docker info >nul 2>nul
        if !errorlevel! EQU 0 (
            echo Docker started successfully.
            goto :docker_ready
        )
        
        if !attempts! LSS !max_attempts! (
            goto :docker_check_loop
        ) else (
            echo Docker did not start in the expected time. Please start Docker manually and try again.
            goto :end
        )
    )
)
goto :continue_script

:start_podman
echo.
echo Podman is not running. Do you want to start Podman now?
choice /c YN /n /m "Start Podman? (Y/N): "
if !errorlevel! EQU 2 (
    echo Podman must be running to continue. Exiting...
    goto :end
)

echo Starting Podman service...

REM Get current user's profile path and start Podman Desktop
for /f "tokens=*" %%i in ('echo %USERPROFILE%') do set "USER_PROFILE=%%i"
start "" "!USER_PROFILE!\AppData\Local\Programs\podman-desktop\Podman Desktop.exe"

REM Initialize and start Podman machine with proper checks
echo Checking Podman machine status...
podman machine list >nul 2>nul
if !errorlevel! NEQ 0 (
    echo Initializing new Podman machine...
    podman machine init
    if !errorlevel! NEQ 0 (
        echo Failed to initialize Podman machine. Please check Podman installation.
        goto :end
    )
)

echo Starting Podman machine...
podman machine start
if !errorlevel! NEQ 0 (
    echo Failed to start Podman machine. Please check Podman installation.
    goto :end
)

echo Waiting for Podman to start (this may take a moment^)...
set /a attempts=0
set /a max_attempts=30

:podman_check_loop
timeout /t 3 >nul
set /a attempts+=1
echo Checking if Podman is responsive (attempt !attempts! of !max_attempts!^)...

REM More comprehensive Podman checks
podman machine list | findstr /C:"Currently running" >nul
if !errorlevel! EQU 0 (
    podman ps >nul 2>nul
    if !errorlevel! EQU 0 (
        echo Podman started successfully.
        goto :continue_script
    )
)

if !attempts! LSS !max_attempts! (
    goto :podman_check_loop
) else (
    echo Podman did not start in the expected time. Please start Podman manually and try again.
    goto :end
)

:docker_ready
:continue_script
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
    python container_manager.py logs %ENGINE% %PROFILE%
    set EXIT_CODE=!ERRORLEVEL!
    if !EXIT_CODE! NEQ 0 (
        echo Failed to get container logs.
        echo Make sure the containers are running with: %ENGINE% compose ps
    )
) else if errorlevel 2 (
    echo Stopping containers...
    python container_manager.py down %ENGINE% %PROFILE%
    set EXIT_CODE=!ERRORLEVEL!
    if !EXIT_CODE! NEQ 0 (
        echo Failed to stop containers.
    ) else (
        echo Containers successfully stopped.
    )
) else (
    echo Starting containers...
    python container_manager.py up %ENGINE% %PROFILE%
    set EXIT_CODE=!ERRORLEVEL!
    if !EXIT_CODE! NEQ 0 (
        echo Failed to start containers.
        echo Check if ports 3000 and 11434 are already in use.
    ) else (
        echo Containers successfully started.
    )
)

:end
pause
