param([switch]$GPU)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module "$scriptPath\PodmanHelper.psm1" -Force

# Ensure podman machine exists and is running
if (-not (podman machine list | Select-String -Pattern "podman-machine-default")) {
    Write-Host "Creating new Podman machine..."
    podman machine init
}

if (-not (podman machine list | Select-String -Pattern "Currently running")) {
    Write-Host "Starting Podman machine..."
    podman machine start
}

# Create network if it doesn't exist
podman network exists ollama-network
if (-not $?) {
    podman network create ollama-network
}

# Load configuration from JSON
$config = Get-PodmanConfig "./podman-compose.json"

# Determine which Ollama service to use
$ollamaService = if ($GPU) { "ollama-gpu" } else { "ollama-cpu" }

# Stop and remove existing containers if they exist
podman ps -a --format "{{.Names}}" | Where-Object { $_ -in @($ollamaService, "open-webui") } | ForEach-Object {
    Write-Host "Removing existing container $_..."
    podman rm -f $_ 2>$null
}

# Start Ollama
Write-Host "Starting $ollamaService..."
Start-PodmanContainer -ServiceConfig $config.services.$ollamaService -ServiceName $ollamaService

# Wait for Ollama to be ready
Write-Host "Waiting for Ollama to be ready..."
Start-Sleep -Seconds 5

# Start Open WebUI
Write-Host "Starting Open WebUI..."
Start-PodmanContainer -ServiceConfig $config.services."open-webui" -ServiceName "open-webui"

Write-Host "Open WebUI will be available at http://localhost:3000"
