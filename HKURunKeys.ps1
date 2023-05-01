# Note this currently only checks the Run and RunOnce key for each user.

$users = Get-ChildItem "C:\Users" | Where-Object { $_.PSIsContainer }
$run_key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$runonce_key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"

foreach ($user in $users) {
    $ntuser_path = "C:\Users\$($user.Name)\NTUSER.DAT"
    if (Test-Path -Path $ntuser_path) {
        $reg_key = "HKU\$($user.Name)\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
        $reg_key_once = "HKU\$($user.Name)\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"

        if (Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Username -ErrorAction SilentlyContinue | Select-String -Pattern $user.Name -Quiet) {
            Write-Host "Checking live registry for $($user.Name)..." -ForegroundColor Green
            $reg_key = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
            $reg_key_once = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
        }
        else {
            Write-Host "Loading registry hive for $($user.Name)..." -ForegroundColor Green
            reg load "HKU\$($user.Name)" "$ntuser_path" | Out-Null
        }

        Write-Host "Run Key Values for $($user.Name):" -ForegroundColor Yellow
        Get-ItemProperty -Path $reg_key -ErrorAction SilentlyContinue | ForEach-Object {
            foreach ($prop in $_.PSObject.Properties) {
                Write-Host "    $($prop.Name): $($prop.Value)"
            }
        }

        Write-Host "Run Once Key Values for $($user.Name):" -ForegroundColor Yellow
        Get-ItemProperty -Path $reg_key_once -ErrorAction SilentlyContinue | ForEach-Object {
            foreach ($prop in $_.PSObject.Properties) {
                Write-Host "    $($prop.Name): $($prop.Value)"
            }
        }

        if ($reg_key -match 'HKU') {
            Write-Host "Unloading registry hive for $($user.Name)..." -ForegroundColor Green
            reg unload "HKU\$($user.Name)" | Out-Null
        }
    }
    else {
        Write-Host "Skipping $($user.Name) - NTUSER.DAT not found." -ForegroundColor Yellow
    }
}
