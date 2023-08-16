<#
TITLE: Find Shutdown Events [WIN]
PURPOSE: Find all related shutdown events in the event log for the past 30 days
CREATOR: Dan Meddock
CREATED: 25JUl2023
LAST UPDATED: 25JUl2023
#>

$eventIDs = @(41, 1074, 6006, 6005, 6008)
$logName = "System"

# Calculate the date range
$startDate = (Get-Date).AddMonths(-1)
$endDate = Get-Date

# Get the Event Log entries within the date range
$events = Get-WinEvent -FilterHashtable @{
    LogName = $logName
    ID = $eventIDs
    StartTime = $startDate
    EndTime = $endDate
} -ErrorAction SilentlyContinue

if ($events) {
    foreach ($event in $events) {
        $eventID = $event.Id
        $eventTime = $event.TimeCreated
        $eventMessage = $event.Message

        $eventData = @{
            "Event ID" = $eventID
            "Time" = $eventTime
            "Message" = $eventMessage
        }

        $eventObject = New-Object -TypeName PSObject -Property $eventData
        $eventObject | Format-Table -AutoSize
    }
} else {
    Write-Host "No system events found for the specified event IDs within the past month."
}
