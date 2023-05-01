# Checks for known executable file extensions
# Confirm folder path and add extensions as required

$users = Get-ChildItem -Path "C:\Users\" -Directory
$profiles = "Public", "All Users", "Default", $users.Name

$foundExecutable = $false
$executableExtensions = ".exe", ".com", ".bat", ".cmd", ".scr", ".pif", ".msi", ".msp", ".vbs", ".js", ".ps1", ".psm1", ".wsf", ".wsh", ".lnk", ".au3", ".hlp", ".hta", ".jar", ".jnlp", ".docm", ".xlsm", ".pptm", ".asx", ".wax", ".wmx", ".wmv", ".wma", ".avi", ".mpg", ".mpeg"
$checkedFolders = @()

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
                Write-Host "  $($item.Name)"
                
                if ($executableExtensions -contains $item.Extension.ToLower()) {
                    Write-Host "    Executable file found: $($item.FullName)"
                    $foundExecutable = $true
                }
            }
        }
    }
}

Write-Host "Checked the following folders:"
foreach ($folder in $checkedFolders | Select-Object -Unique) {
    Write-Host "  $folder"
}

if (-not $foundExecutable) {
    Write-Host "No executable files found in any startup folder."
}
