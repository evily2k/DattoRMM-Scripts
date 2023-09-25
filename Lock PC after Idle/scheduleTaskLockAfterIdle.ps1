<#
TITLE: Schedule Task to Lock after Idle for 20 Minutes [WIN]
PURPOSE: Creates a scheduled task to run the logoff.ps1 script
CREATOR: Dan Meddock
CREATED: 25SEP2023
LAST UPDATED: 25SEP2023
#>

# Declarations
$workingDir = "C:\temp"
$installScript = "C:\temp\logoff.ps1"
$logoffScript = "logoff.ps1"

# Check if the working directory exists
If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force | Out-Null}

# Transfer logoff script to computer
Copy-Item $logoffScript -Destination $installScript -force

# Create Scheduled task
$taskname = "logoffAfterIdle"
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-windowstyle hidden -executionpolicy Unrestricted -noprofile -file $installScript"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -expand UserName)
$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
Register-ScheduledTask $taskname -InputObject $task
Start-ScheduledTask -TaskName $taskname