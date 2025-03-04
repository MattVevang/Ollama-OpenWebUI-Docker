Write-Host "Stopping all containers..."

# Function to safely stop and remove a container
function Stop-AndRemoveContainer {
    param($containerName)
    
    Write-Host "Stopping $containerName..."
    podman stop -t 5 $containerName 2>$null
    Write-Host "Removing $containerName..."
    podman rm -f $containerName 2>$null
}

# Get all containers (both running and stopped) and stop/remove them
$containers = podman ps -a --format "{{.Names}}"
if ($containers) {
    Write-Host "Found containers: $containers"
    foreach ($container in $containers) {
        Stop-AndRemoveContainer $container
    }
} else {
    Write-Host "No containers found."
}

# Optionally stop the Podman machine to free resources
Write-Host "`nPodman machine options:"
Write-Host "- Enter 'y' to completely shutdown the Podman virtual machine (frees resources, slower next startup)"
Write-Host "- Enter 'n' or press Enter to keep it running (faster next startup, keeps using resources)"
$response = Read-Host "Do you want to stop the Podman machine? (y/N)"
if ($response -eq 'y') {
    Write-Host "Stopping Podman machine..."
    podman machine stop
    Write-Host "Podman machine stopped. You'll need to wait for it to start next time you run containers."
}
