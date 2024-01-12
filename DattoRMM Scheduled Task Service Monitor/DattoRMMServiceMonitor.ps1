<#
TITLE: DattoRMM Service Monitor [WIN]
PURPOSE: DattoRMM service monitor and will attempt to start the service if stopped and checks every hour
CREATOR: Dan Meddock
CREATED: 05JAN2024
LAST UPDATED: 05JAN2024
#>

# Declarations
$workingDir = "C:\KEworking"
$dattoMonitor = "checkDatto.ps1"
$monitorDir = $workingDir + "\" + $dattoMonitor

# Check if Temp folder exists
If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force | Out-Null}

# DattoRMM service monitor and will attempt to start if stopped
$monitorScript = @'
function checkDatto {
	$ServiceName = 'cagservice'
	$arrService = Get-Service -Name $ServiceName
	$taskname = "Datto Offboarding"
	while ($arrService.Status -ne 'Running'){
		Start-Service $ServiceName
		Start-Sleep -seconds 60
		$arrService.Refresh()
		if ($arrService.Status -eq 'Running'){
			Exit 0
		}
	}
}
checkDatto
'@

# Output scriptblock to directory
$monitorScript | out-file $monitorDir

# Create scheduled task 
$taskname = "Datto Service Monitor"
$taskdescription = "Removes additional tools when Datto is removed."
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-executionpolicy bypass -noprofile -file $monitorDir"
$Trigger = New-ScheduledTaskTrigger -Daily -DaysInterval 1 -RandomDelay "00:30" -At "08:00"
$Trigger.Repetition = $(New-ScheduledTaskTrigger -Once -RandomDelay "00:30" -At "08:00" -RepetitionDuration "12:00" -RepetitionInterval "01:00").Repetition
Register-ScheduledTask -Action $action -Trigger $Trigger -TaskName $taskname -Description $taskdescription -User "System"

Exit 0