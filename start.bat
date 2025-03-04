@echo off
echo Starting Ollama with OpenWebUI...

IF "%1"=="gpu" (
    echo Using GPU profile
    docker compose --profile gpu up -d
) ELSE (
    echo Using CPU profile
    docker compose up -d
)

echo.
echo Access the WebUI at http://localhost:3000
echo.

pause
