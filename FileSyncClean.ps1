# Define the source and destination folders
$sourceFolder = "C:\Users\thiesena\OneDrive - Florida Department of Health"
$destinationFolder = "\\chd44sxen01\d$\Thiesen - Documentation"

# Create the destination folder if it doesn't exist
if (-not (Test-Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

# Initial copy of all files from source to destination
Get-ChildItem $sourceFolder -Recurse | ForEach-Object {
    $destinationPath = Join-Path $destinationFolder $_.FullName.Substring($sourceFolder.Length + 1)
    Copy-Item $_.FullName -Destination $destinationPath -Force
}

# Start monitoring for changes
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $sourceFolder
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Define events to watch
$watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName, [System.IO.NotifyFilters]::DirectoryName, [System.IO.NotifyFilters]::LastWrite

# Define the action to take on change
$action = {
    $path = $Event.SourceEventArgs.FullPath
    $changeType = $Event.SourceEventArgs.ChangeType

    # Define the destination path for the copied file
    $destinationPath = Join-Path $destinationFolder $path.Substring($sourceFolder.Length + 1)

    # Check if it's a file and if it exists in the destination folder
    if ((Test-Path $path) -and ($changeType -eq "Created" -or $changeType -eq "Changed") -and (Test-Path $destinationPath)) {
        # Copy the file
        Copy-Item $path -Destination $destinationPath -Force
        Write-Host "Copied $path to $destinationPath"
    }
}

# Register the event handler
Register-ObjectEvent $watcher "Created" -Action $action
Register-ObjectEvent $watcher "Changed" -Action $action

# Keep the script running
Write-Host "Monitoring for changes..."
while ($true) {
    Wait-Event -Timeout 5
}
