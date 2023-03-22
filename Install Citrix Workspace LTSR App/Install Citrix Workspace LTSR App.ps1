<#
TITLE: Install Citrix Workspace LTSR App [WIN]
PURPOSE: Installs the Citrix Workspace App for Windows with install options; install now or after next reboot
CREATOR: Dan Meddock
CREATED: 08MAR2023
LAST UPDATED: 20MAR2023
#>

# Log Citrix Workspace install output to log file
Start-Transcript -Path "C:\temp\CitrixWorkspaceInstall.log"

# Declarations
$workingDir = "C:\Temp"
$application = "CitrixWorkspaceApp.exe"
$installScript = "C:\Temp\installCitrixWorkplace.ps1"
$runTypeCitrix = $env:RunType

# Main

Try {
# Check if Temp folder exists
If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force}
	
# Copy installer to device
Copy-Item $application -Destination $workingDir -force

# Run Citrix install now
if($runTypeCitrix -eq "1"){
	# Change location to working directory
	set-location $workingDir
	
	# Start Citrix Workspace install
	write-host "Installing Citrix Workplace now..."
	start-process $application -argumentlist "/silent /forceinstall /noreboot /AutoUpdateCheck=manual /AutoUpdateStream=LTSR"
	sleep 45
	write-host "Citrix Workspace App install completed."
}

# Run Citrix install at system startup
if($runTypeCitrix -eq "2"){	
$taskName = "CitrixWorkspaceInstall"
$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName }
if(!($taskExists)){
write-host "Scheduling Citrix Workplace app install for the next system reboot."
# Commands to install Citrix Workplace
$installCommand = @'
set-location "C:\temp"
start-process "CitrixWorkspaceApp.exe" -argumentlist "/silent /forceinstall /noreboot /AutoUpdateCheck=manual /AutoUpdateStream=LTSR"
Start-Sleep -Seconds 5
Unregister-ScheduledTask -TaskName "CitrixWorkspaceInstall" -Confirm:$false
'@

	# Output scriptblock to directory
	$installCommand | out-file $installScript

	# Create Scheduled task
	$taskname = "CitrixWorkspaceInstall"
	$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-executionpolicy bypass -noprofile -file $installScript"
	$trigger = New-ScheduledTaskTrigger -AtStartup -RandomDelay 00:00:30
	$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
	$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
	Register-ScheduledTask $taskname -InputObject $task
}else{
	write-host "Scheduled task already exists."
}
}

}Catch{
	Write-Host $($_.Exception.Message)
	Stop-Transcript
	Exit 1
}

# Stop transcript logging
Stop-Transcript
Exit 0