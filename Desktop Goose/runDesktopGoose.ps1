# Declarations
$workingDir = "C:\Temp"
$gooseZip = "DesktopGoose-v0.31.zip"
$gooseExe = "GooseDesktop.exe"

# Path and variable manipulations
$gooseFolder = $gooseZip -replace ".zip",""
$gooseFolderPath = $workingDir,$gooseFolder -join "\"
$gooseZipPath = $workingDir,$gooseZip -join "\"
$gooseApp = $gooseFolderPath + "\" + $gooseExe

# Scheduled task properties
$taskname = "DesktopGoose"
$action = New-ScheduledTaskAction -Execute $gooseApp
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -expand UserName)
$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal

# Main
Try{
	#Check if Temp folder exists
	If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force}	
	# Copy installer to device
	Copy-Item $gooseZip -Destination $workingDir -force
	# Extract zip folder contents
	Expand-Archive -literalpath $gooseZipPath -DestinationPath $gooseFolderPath
	# Create the scheduled task	
	Register-ScheduledTask $taskname -InputObject $task
	# Start the scheduled task and sleep 5 seconds
	Start-ScheduledTask -TaskName $taskname; Start-Sleep -Seconds 5
	# Remove the scheduled task to stop it from running again
	Unregister-ScheduledTask -TaskName $taskname -Confirm:$false	
	Exit 0
}catch{
	Write-Error $_.Exception.Message 
}