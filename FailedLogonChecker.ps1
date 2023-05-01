# Prompt the user for a time range
$validInput = $false
while (!$validInput) {
    $input = Read-Host 'Enter a time range (e.g. 30m, 2h, 3d, 1M):'
    if ($input -match '(\d+)([mhdM])') {
        $value = [int]$Matches[1]
        $unit = $Matches[2].ToLower()
        switch ($unit) {
            'm' { $timeSpan = New-TimeSpan -Minutes $value; $validInput = $true }
            'h' { $timeSpan = New-TimeSpan -Hours $value; $validInput = $true }
            'd' { $timeSpan = New-TimeSpan -Days $value; $validInput = $true }
            'M' { $now = Get-Date; $timeSpan = $now.AddMonths(-$value); $validInput = $true }
        }
    }
    if (!$validInput) {
        Write-Host 'Invalid input. Please enter a time range in the format "number unit" (e.g. 30m, 2h, 3d, 1M).'
    }
}

# Get the current date and time
$now = Get-Date

# Set the event log source and ID for failed logon events
$logSource = 'Security'
$logId = 4625

# Get the events from the event log within the time range and with the specified source and ID
$events = Get-EventLog -LogName $logSource -InstanceId $logId -After ($now.Add(-$timeSpan))

# If there are no events, output a message
if ($events.Count -eq 0) {
    Write-Output 'No failed logon events in the specified time range.'
} else {
    # If there are events, output the details of each event
    foreach ($event in $events) {
        Write-Output "Failed logon event at $($event.TimeGenerated) from $($event.ReplacementStrings[5]) with username $($event.ReplacementStrings[0])."
    }
}
