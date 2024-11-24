function Copy-Prerequisites {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,

        [Parameter(Mandatory=$true)]
        [string[]]$Path,

        [Parameter(Mandatory=$true)]
        [string]$Destination,

        [Parameter(Mandatory=$false)]
        [PSCredential]$Credential 
    )

    # Format the remote destination path using UNC
    $destinationPath = "\\$ComputerName\C$\$Destination"

    # Ensure the source paths exist on the local machine
    foreach ($sourcePath in $Path) {
        Write-Host $sourcePath
        if (-not (Test-Path -Path $sourcePath)) {
            Write-Host "Source path $sourcePath does not exist on the local machine."
            return
        }
    }

    # If credentials are not provided, prompt the user for credentials
    if (-not $Credential) {
        $Credential = Get-Credential
    }

    # Attempt to map the remote drive with provided credentials
    try {
        Write-Host "Connecting to remote computer using credentials..."
        New-PSDrive -Name "RemoteShare" -PSProvider FileSystem -Root "\\$ComputerName\C$" -Credential $Credential -Persist
        Write-Host "Connection established."

        # Check if the destination directory exists on the remote machine
        if (-not (Test-Path -Path $destinationPath)) {
            Write-Host "Destination path does not exist. Creating directory..."
            New-Item -ItemType Directory -Force -Path $destinationPath
        }

        # Iterate through each path in the $Path array and copy the files
        foreach ($sourcePath in $Path) {
            Write-Host "Copying files from $sourcePath to $destinationPath"

            try {
                # Use Copy-Item to copy the files to the remote machine
                Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force
                Write-Host "Files copied successfully!"
            } catch {
                Write-Host "Error copying files: $_"
            }
        }
    } catch {
        Write-Host "Failed to connect to the remote computer. Error: $_"
    }
}



function New-BuildDockerImage {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Dockerfile,

        [Parameter(Mandatory=$true)]
        [string]$Tag,

        [Parameter(Mandatory=$true)]
        [string]$Context,

        [Parameter(Mandatory=$false)]
        [string]$ComputerName
    )

    $buildCommand = "docker build -f `"$Dockerfile`" -t `"$Tag`" `"$Context`""
    Write-Host $buildCommand

    if ($ComputerName) {
        $Credential = Get-Credential 
        $session = New-PSSession -ComputerName $ComputerName -Credential $Credential
        try {
            Invoke-Command -Session $session -ScriptBlock {
                param($buildCommand)
                Write-Host "Running Docker build on remote host..."
                Invoke-Expression $buildCommand
            } -ArgumentList $buildCommand
        } catch {
            Write-Host "Error executing the command remotely: $_"
        }
    } else {
        Write-Host "Running Docker build locally..."
        Invoke-Expression $buildCommand
    }
}


# Run-DockerContainer
function Start-RunDockerContainer {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ImageName,

        [string]$ComputerName,

        [string[]]$DockerParams,

        [int]$n,

        [Parameter(Mandatory=$true)]
        [string]$tag
    )

    $dockerArgs = @("run", "--name", "$ImageName", "-e", "n=$n")
    Write-Host $dockerArgs

    if ($DockerParams) {
        $dockerArgs += $DockerParams
        Write-Host "Docker params added: $($DockerParams -join ' ')"
        Write-Host $dockerArgs
    }
    $dockerArgs += "$tag"

    Write-Host "Final Docker command: $($dockerArgs -join ' ')"


    if ($ComputerName) {
        # Run container on remote host
        $containerName = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            docker $args
            Write-Host "Running Docker command on remote machine..."
        } -ArgumentList $dockerArgs
    } else {
        # Run container locally
        $containerName = docker $dockerArgs
    }

    return $containerName

}







