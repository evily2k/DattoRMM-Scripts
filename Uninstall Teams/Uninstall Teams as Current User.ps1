<#
TITLE: Uninstall Teams as Current User [WIN]
PURPOSE: Uninstalls Teams as the currently signed in user
CREATOR: Dan Meddock
CREATED: 28JUL2023
LAST UPDATED: 03AUG2023
#>

# Function to schedule uninstallTeams
function scheduleTeamsUninstall {
	# powershell script used in scheduled task
	$installScript = "C:\Temp\uninstallTeams.ps1"
	
# Commands to run the Teams uninstall
$installCommand = @'
$taskname = "uninstallTeams"
# Get the current username
$username = $env:USERNAME
$UserInstallPath = "C:\Users\$username\AppData\Local\Microsoft\Teams\Update.exe"
$params = "--uninstall -s" 

# Uninstall Teams if it's installed
if (Test-Path $UserInstallPath) {
    Start-Process -FilePath $UserInstallPath -ArgumentList $params -Wait
} 

# Remove registry key
$regKey = "HKCU:\SOFTWARE\Microsoft\Office\Teams"
$regValue = "PreventInstallationFromMsi" 

if (Test-Path $regKey) {
    Remove-ItemProperty -Path $regKey -Name $regValue -ErrorAction SilentlyContinue
}

# Remove Teams folders
$teamsLocalAppData = "C:\Users\$username\AppData\Local\Microsoft\Teams"
$teamsRoamingAppData = "C:\Users\$username\AppData\Roaming\Microsoft\Teams"

if (Test-Path $teamsLocalAppData) {
    Remove-Item -Path $teamsLocalAppData -Recurse -Force
}
if (Test-Path $teamsRoamingAppData) {
    Remove-Item -Path $teamsRoamingAppData -Recurse -Force
}
Unregister-ScheduledTask -TaskName $taskname -Confirm:$false

# Log off
shutdown.exe /l
'@

	# Output scriptblock to directory
	$installCommand | out-file $installScript

	# Create Scheduled task
	$taskname = "uninstallTeams"
	$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-executionpolicy bypass -noprofile -file $installScript"
	$trigger = New-ScheduledTaskTrigger -AtLogOn
	$principal = New-ScheduledTaskPrincipal -UserId (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -expand UserName)
	$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
	Register-ScheduledTask $taskname -InputObject $task
	Start-ScheduledTask -TaskName $taskname
}

scheduleTeamsUninstall

Exit 0