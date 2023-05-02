$svchosts = Get-Process svchost
$excludedArgs = @("/k", "netsvcs", "localservice", "networkservice", "system", "localsystemnetworkrestricted")
foreach ($svchost in $svchosts) {
    $svcArgs = (Get-CimInstance Win32_Process -Filter "ProcessId=$($svchost.Id)").CommandLine
    $excludeMatch = $false
    foreach ($arg in $excludedArgs) {
        if ($svcArgs -match "$arg") {
            $excludeMatch = $true
            break
        }
    }
    if ($excludeMatch) {
        continue
    }
    Write-Output "svchost.exe (PID: $($svchost.Id))"
    $svcGroup = ""
    $svcNames = @()
    $comDll = ""
    foreach ($arg in $svcArgs) {
        if ($arg -match "^-k\s+(\S+)") {
            $svcGroup = $Matches[1]
        }
        elseif ($arg -match "^-s\s+(\S+)") {
            $svcNames += $Matches[1]
        }
        elseif ($arg -match "^-p\s+""(.+?)""") {
            $comDll = $Matches[1]
        }
    }
    if ($svcGroup) {
        Write-Output "Service Group: $svcGroup"
    }
    if ($svcNames.Count -gt 0) {
        Write-Output "Services:"
        foreach ($svc in $svcNames) {
            Write-Output "  $svc"
        }
    }
    if ($comDll) {
        Write-Output "COM+ DLL: $comDll"
    }
    if (-not $svcGroup -and $svcNames.Count -eq 0 -and -not $comDll) {
        Write-Output "Arguments: None`n"
    }

    # Use tasklist /svc to get the list of services running under the current svchost process
    $svcInfo = (tasklist /fi "PID eq $($svchost.Id)" /svc /nh | Select-Object -Skip 1)
    if ($svcInfo) {
        Write-Output "Service Details:"
        foreach ($svcLine in $svcInfo) {
            $svcParts = $svcLine -split "\s+"
            $svcName = $svcParts[0]
            $svcDisplayName = $svcParts[1]
            $svcStatus = $svcParts[2]
            Write-Output "  $svcName ($svcDisplayName): $svcStatus"
        }
    }
    else {
        Write-Output "Service Details: None`n"
    }
}
