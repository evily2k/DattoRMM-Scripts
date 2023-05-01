<#
TITLE: Restart DHCP server with 20 minute delay
PURPOSE: This script will restart the DHCP services after it reboots but it delays 20 minutes before executing
CREATOR: Dan Meddock
CREATED: 1MAY2023
LAST UPDATED: 1MAY2023
#>

# Declarations
$workDir = "C:\temp"
$taskScript = "C:\temp\restartDHCP.ps1"

# Main
write-host "Setting up scheduled task to restart the DHCP server and client when the server reboots."
if (!(test-path $workDir -PathType Leaf)){new-item $workDir -ItemType Directory -force | Out-Null}

# Commands to restart DHCP server with 20 minute delay
$taskCommand = @'
sleep 1200
Restart-Service -name DHCPServer -force
'@

# Output scriptblock to directory
$taskCommand | out-file $taskScript

# Create Scheduled task
$taskname = "RestartDHCPservice"
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-executionpolicy bypass -noprofile -file $taskScript"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
Register-ScheduledTask $taskname -InputObject $task