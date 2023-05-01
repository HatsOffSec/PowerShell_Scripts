# Set the log name and the event ID to search for
$logName = "System"
$eventID = 7034

# Get the number of events to search through from the user
$numEvents = Read-Host "Enter the number of events to search through (or enter 'all' to search through all events):"

# If the user entered "all", set the number of events to a large number to retrieve all events
if ($numEvents -eq "all") {
    $numEvents = 100000
}

# Initialize a variable to track the number of events checked
$numEventsChecked = 0

# Get the events from the log
$events = Get-EventLog -LogName $logName -InstanceID $eventID -Newest $numEvents -ErrorAction SilentlyContinue

# Check if there are any events
if ($events.Count -eq 0) {
    # No events found with the specified event ID
    Write-Output "No events found with an event ID of $eventID."
}
else {
    # Loop through the events and output the relevant information
    foreach ($event in $events) {
        $serviceName = $event.ReplacementStrings[0]
        $eventTime = $event.TimeGenerated
        $message = $event.Message

        Write-Output "Service $serviceName crashed at $eventTime with message: $message"

        # Increment the number of events checked
        $numEventsChecked++
    }

    # Output the number of events checked in the "Script completed" message
    Write-Output "Script completed. Checked $numEventsChecked events."
}
