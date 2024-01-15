# FileSync
Sync files from one location to another (including a network share).

Let's break down the PowerShell script step by step:

1. **Setting Source and Destination Folders**:
   ```powershell
   $sourceFolder = "C:\Path\To\Source\Folder"
   $destinationFolder = "C:\Path\To\Destination\Folder"
   ```
   - These lines set the source and destination folders. Replace the paths with the actual source and destination folders you want to use.

2. **Creating the Destination Folder**:
   ```powershell
   if (-not (Test-Path $destinationFolder)) {
       New-Item -ItemType Directory -Path $destinationFolder | Out-Null
   }
   ```
   - This section checks if the destination folder exists. If not, it creates the folder using `New-Item` and sets its type to Directory. `Out-Null` suppresses any output that `New-Item` might generate.

3. **Initial Copy of Files**:
   ```powershell
   Get-ChildItem $sourceFolder -Recurse | ForEach-Object {
       $destinationPath = Join-Path $destinationFolder $_.FullName.Substring($sourceFolder.Length + 1)
       Copy-Item $_.FullName -Destination $destinationPath -Force
   }
   ```
   - This section does an initial copy of all files from the source to the destination. It uses `Get-ChildItem` to retrieve all files and directories in the source folder and its subdirectories. `ForEach-Object` processes each item.
   - `Join-Path` combines the destination folder path with the relative path of the current item within the source folder.
   - `Copy-Item` copies the current item to the destination, and `-Force` overwrites existing files if they have the same name.

4. **Setting up FileSystemWatcher**:
   ```powershell
   $watcher = New-Object System.IO.FileSystemWatcher
   $watcher.Path = $sourceFolder
   $watcher.IncludeSubdirectories = $true
   $watcher.EnableRaisingEvents = $true
   ```
   - This section creates a `FileSystemWatcher` object named `$watcher` to monitor the source folder.
   - It sets the path to the source folder, includes subdirectories, and enables event notifications.

5. **Defining Events to Watch**:
   ```powershell
   $watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName, [System.IO.NotifyFilters]::DirectoryName, [System.IO.NotifyFilters]::LastWrite
   ```
   - This line sets which events the watcher should notify on. In this case, it's watching for changes in file names, directory names, and last write times.

6. **Defining Action on Change**:
   ```powershell
   $action = {
       # ...
   }
   ```
   - This section defines an action to take when a change is detected. The action is currently empty and will be filled in later.

7. **Registering Event Handlers**:
   ```powershell
   Register-ObjectEvent $watcher "Created" -Action $action
   Register-ObjectEvent $watcher "Changed" -Action $action
   ```
   - This registers event handlers for when new files are created (`"Created"`) and existing files are modified (`"Changed"`). The action to take is defined by the `$action` script block.

8. **Continuous Monitoring Loop**:
   ```powershell
   while ($true) {
       Wait-Event -Timeout 5
   }
   ```
   - This loop keeps the script running indefinitely. It uses `Wait-Event` with a timeout of 5 seconds. This allows the script to continuously monitor for events without consuming too much system resources.

9. **Displaying Monitoring Message**:
   ```powershell
   Write-Host "Monitoring for changes..."
   ```
   - This line prints a message indicating that the script is now monitoring for changes.

That's a detailed explanation of each section of the PowerShell script. When you run this script, it will perform an initial copy of all files from the source to the destination, then continuously monitor for changes and copy them over to the destination folder.
