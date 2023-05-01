$foundExecutable = $false
$executableExtensions = ".exe", ".com", ".bat", ".cmd", ".scr", ".pif", ".msi", ".msp", ".vbs", ".js", ".ps1", ".psm1", ".wsf", ".wsh", ".lnk", ".au3", ".hlp", ".hta", ".jar", ".jnlp", ".docm", ".xlsm", ".pptm", ".asx", ".wax", ".wmx", ".wmv", ".wma", ".avi", ".mpg", ".mpeg"
$checkedFolders = @()

# Get all users
$users = Get-ChildItem -Path "C:\Users\" -Directory | Select-Object -ExpandProperty Name

# Add built-in profiles to the list of profiles to check
$profiles = "Public", "Default", "All Users"

# Add all user profiles to the list of profiles to check
$profiles += $users

# Check the startup folders for each profile
foreach ($profile in $profiles) {
    $startupFolder = "C:\Users\$($profile)\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
    $checkedFolders += $startupFolder

    if (Test-Path $startupFolder) {
        $items = Get-ChildItem $startupFolder

        if ($items.Count -eq 0) {
            Write-Host "No items found in $($profile)'s startup folder: $($startupFolder)"
        }
        else {
            Write-Host "Contents of $($profile)'s startup folder ($($startupFolder)):"

            foreach ($item in $items) {
                if ($executableExtensions -contains $item.Extension.ToLower()) {
                    $hash = Get-FileHash $item.FullName -Algorithm SHA256
                    Write-Host "  $($item.Name) ($($hash.Hash))"
                    $foundExecutable = $true
                }
            }
        }
    }
}

# Output the list of checked folders
Write-Host "Checked the following folders:"
foreach ($folder in $checkedFolders | Select-Object -Unique) {
    Write-Host "  $folder"
}

# Output a message if no executable files were found
if (-not $foundExecutable) {
    Write-Host "No executable files found in any startup folder."
}
