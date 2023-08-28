<#
TITLE: Company Tool Removal [WIN]
PURPOSE: This script creates a scheduled task to check if Datto is installed; if it is, it uninstalls Huntress.
CREATOR: Dan Meddock
CREATED: 01JAN2023
LAST UPDATED: 20AUG2023
#>

# Declarations
$workingDir = "C:\KEworking"
$dattoMonitor = "checkDatto.ps1"
$monitorDir = $workingDir + "\" + $dattoMonitor

# Check if Temp folder exists
If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force | Out-Null}

# DattoRMM monitor script to uninstall Huntress when Datto is uninstalled
$monitorScript = @'
function checkDatto {
	$taskname = "Company Tool Removal"
	$eventType = "Information"
	[string]$eventLogOutput = "DattoRMM is missing from this device. Uninstalling Huntress."
	if (get-service cagservice -erroraction silentlycontinue){
		continue
	}else{
		start-process "C:\Program Files\Huntress\Uninstall.exe" -argumentlist "/S"
		Start-Sleep -Seconds 5
		Unregister-ScheduledTask -TaskName $taskname -Confirm:$false
		if (![System.Diagnostics.EventLog]::SourceExists($taskname)){New-Eventlog -LogName Application -Source $taskname}
		Write-EventLog -LogName Application -Source $taskname -EntryType $eventType -EventId 6910 -Message ($eventLogOutput | out-string)
	}
}
checkDatto
'@

# Output scriptblock to directory
$monitorScript | out-file $monitorDir

# Create scheduled task 
$taskname = "Datto Offboarding"
$taskdescription = "Removes additional tools when Datto is removed."
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-executionpolicy bypass -noprofile -file $monitorDir"
$trigger =  New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskname -Description $taskdescription -User "System"

Exit 0