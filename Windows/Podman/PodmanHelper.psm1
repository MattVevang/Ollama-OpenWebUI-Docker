function ConvertTo-Hashtable {
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    process {
        if ($null -eq $InputObject) { return $null }
        if ($InputObject -is [System.Collections.Hashtable]) { return $InputObject }
        if ($InputObject -is [System.Array]) {
            return $InputObject # Return arrays as-is
        }
        
        $hash = @{}
        $InputObject.PSObject.Properties | ForEach-Object {
            $value = if ($_.Value -is [PSCustomObject]) {
                ConvertTo-Hashtable $_.Value
            } else {
                $_.Value
            }
            $hash[$_.Name] = $value
        }
        return $hash
    }
}

function Get-PodmanConfig {
    param([string]$FilePath)
    $json = Get-Content -Path $FilePath -Raw
    $config = ConvertFrom-Json $json
    return ConvertTo-Hashtable $config
}

function Start-PodmanContainer {
    param (
        [hashtable]$ServiceConfig,
        [string]$ServiceName
    )

    $command = "podman run -d"
    $command += " --name `"$ServiceName`""
    
    # Add network parameters
    if ($ServiceConfig.networks) {
        foreach ($network in $ServiceConfig.networks.GetEnumerator()) {
            $command += " --network `"$($network.Key)`""
            if ($network.Value.aliases) {
                foreach ($alias in $network.Value.aliases) {
                    $command += " --network-alias `"$alias`""
                }
            }
        }
    }

    # Add port mappings
    if ($ServiceConfig.ports) {
        foreach ($port in $ServiceConfig.ports) {
            $command += " -p `"$port`""
        }
    }

    # Add volumes
    if ($ServiceConfig.volumes) {
        foreach ($volume in $ServiceConfig.volumes) {
            $command += " -v `"$volume`""
        }
    }

    # Add environment variables
    if ($ServiceConfig.environment) {
        if ($ServiceConfig.environment -is [System.Array]) {
            foreach ($env in $ServiceConfig.environment) {
                $command += " -e `"$env`""
            }
        } else {
            foreach ($env in $ServiceConfig.environment.GetEnumerator()) {
                $command += " -e `"$($env.Key)=$($env.Value)`""
            }
        }
    }

    # Add device mappings
    if ($ServiceConfig.device) {
        foreach ($dev in $ServiceConfig.device) {
            $command += " --device `"$dev`""
        }
    }

    # Add entrypoint if specified
    if ($ServiceConfig.entrypoint) {
        if ($ServiceConfig.entrypoint -is [System.Array]) {
            $entrypoint = $ServiceConfig.entrypoint -join " "
            $command += " --entrypoint `"$entrypoint`""
        } else {
            $command += " --entrypoint `"$($ServiceConfig.entrypoint)`""
        }
    }

    # Add image
    $command += " $($ServiceConfig.image)"

    Write-Host "Starting $ServiceName with command:"
    Write-Host $command
    Invoke-Expression $command
}

Export-ModuleMember -Function Get-PodmanConfig, Start-PodmanContainer
