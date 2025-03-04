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
where podman >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set "PODMAN_INSTALLED=true"
    echo Podman detected.
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
    ) else (
        set "ENGINE=docker"
        echo Using Docker as container engine.
        
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
    )
) else if "!DOCKER_INSTALLED!"=="true" (
    set "ENGINE=docker"
    echo Using Docker as container engine.
    
    REM Check Docker status for single-engine case
    docker info >nul 2>nul
    if !errorlevel! NEQ 0 (
        echo.
        echo Docker is not running. Do you want to start Docker now?
        choice /c YN /n /m "Start Docker? (Y/N): "
        if !errorlevel! EQU 2 (
            echo Docker must be running to continue. Exiting...
            goto :end
        )
        
        echo Starting Docker service...
        start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        echo Waiting for Docker to start (this may take a moment^)...
        
        set /a attempts=0
        set /a max_attempts=30
        
        :docker_check_loop_single
        timeout /t 3 >nul
        set /a attempts+=1
        echo Checking if Docker is responsive (attempt !attempts! of !max_attempts!^)...
        
        docker info >nul 2>nul
        if !errorlevel! EQU 0 (
            echo Docker started successfully.
            goto :docker_ready
        )
        
        if !attempts! LSS !max_attempts! (
            goto :docker_check_loop_single
        ) else (
            echo Docker did not start in the expected time. Please start Docker manually and try again.
            goto :end
        )
    )
) else if "!PODMAN_INSTALLED!"=="true" (
    set "ENGINE=podman"
    echo Using Podman as container engine.
)

:docker_ready
REM Same check for Podman if needed (simplified version)
if "%ENGINE%"=="podman" (
    podman ps >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo Podman does not seem to be running properly.
        echo Please ensure Podman is properly configured before continuing.
        choice /c YN /n /m "Continue anyway? (Y/N): "
        if errorlevel 2 (
            goto :end
        )
    )
)

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
