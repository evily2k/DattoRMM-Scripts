$installScript = "C:\Temp\updateElevateUC.ps1"
$updateCommand = @'
$users = Get-ChildItem C:\Users 
foreach ($user in $users){
	$elevateDir = "$($user.fullname)\AppData\Local\Programs\Elevate UC\"
    if(test-path $elevateDir){
		Write-Host "Found appdata install for $user."
		Write-Host "Checking for outlook addon updates and installing them, if available."
		Start-Process "$elevateDir\OfficeIntegrationServer\ElevateOfficeIntegration.exe" -argumentlist "-silentinstall"
	}
}
'@

# Output scriptblock to directory
$installCommand | out-file $installScript

# Create Scheduled task
$taskname = "ElevateUCupdate"
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-executionpolicy bypass -noprofile -file $installScript"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
Register-ScheduledTask $taskname -InputObject $task