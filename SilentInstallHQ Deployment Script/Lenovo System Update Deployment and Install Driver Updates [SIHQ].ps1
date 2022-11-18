<#
TITLE: Lenovo System Update Tool [WIN]
PURPOSE: Script to install/uninstall Lenovo System Update with options to check for updates and install them
CREATOR: Dan Meddock
CREATED: 11NOV2022
LAST UPDATED: 18NOV2022
#>

Function Get-SystemUpdates {
	# Set Lenovo System Update AdminCommandLine
	$RegKey = "HKLM:\SOFTWARE\Policies\Lenovo\System Update\UserSettings\General"
	$RegName = "AdminCommandLine"
	$RegValue = "/CM -search A -action INSTALL -includerebootpackages 3 -noicon -noreboot -exporttowmi"

	# Create Subkeys if they don't exist
	if (!(Test-Path $RegKey)) {
		New-Item -Path $RegKey -Force | Out-Null
		New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue | Out-Null
	}
	else {
		New-ItemProperty -Path $RegKey -Name $RegName -Value $RegValue -Force | Out-Null
	}

	# Configure Lenovo System Update interface
	$ui = "HKLM:\SOFTWARE\WOW6432Node\Lenovo\System Update\Preferences\UserSettings\General"
	$values = @{

		"AskBeforeClosing"     = "NO"

		"DisplayLicenseNotice" = "NO"

		"MetricsEnabled"       = "NO"
								 
		"DebugEnable"          = "YES"

	}

	if (Test-Path $ui) {
		foreach ($item in $values.GetEnumerator() ) {
			New-ItemProperty -Path $ui -Name $item.Key -Value $item.Value -Force
		}
	}

	 
	# Run SU and wait until the Tvsukernel process finishes.	
	$su = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath "Lenovo\System Update\tvsu.exe"
	&$su /CM | Out-Null
	Wait-Process -Name Tvsukernel

	# Disable the default System Update scheduled tasks
	Get-ScheduledTask -TaskPath "\TVT\" | Disable-ScheduledTask

	# This will prevent System Update from creating the default scheduled tasks when updating to future releases.
	$sa = "HKLM:\SOFTWARE\WOW6432Node\Lenovo\System Update\Preferences\UserSettings\Scheduler"
	Set-ItemProperty -Path $sa -Name "SchedulerAbility" -Value "NO"

	# Create a custom scheduled task for System Update
	$taskAction = New-ScheduledTaskAction -Execute $su -Argument '/CM'
	$taskTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 9am
	$taskUserPrincipal = New-ScheduledTaskPrincipal -UserId 'SYSTEM'
	$taskSettings = New-ScheduledTaskSettingsSet -Compatibility Win8
	$task = New-ScheduledTask -Action $taskAction -Principal $taskUserPrincipal -Trigger $taskTrigger -Settings $taskSettings
	Register-ScheduledTask -TaskName 'Run-TVSU' -InputObject $task -Force
}

# Declarations
$workingDir = "C:\KEworking"
$appZip = 'LenovoSU.zip'
$installPackage = "Deploy-LenovoSU.ps1"
$appName = "Lenovo System Update"

# Paths and Variable manipulation (dont change)
$appZipPath = join-path -path $workingDir -childpath $appZip
$appPath = $appZipPath -replace ".zip",""
$deploymentTool = join-path -path $appPath -childpath $installPackage

# Commands
$install = {Powershell.exe -ExecutionPolicy Bypass $deploymentTool -DeploymentType "Install" -DeployMode "silent"}
$uninstall = {Powershell.exe -ExecutionPolicy Bypass $deploymentTool -DeploymentType "Uninstall" -DeployMode "silent"}

# Main
Try{
	if($env:installApp -ne "None"){
		# Check if working directory exists
		If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force}
		
		# Transfer installers to computer
		Write-Host "Transferring $appName deployment tool to device."
		Copy-Item $appZip -Destination $workingDir -force
		
		# Extracting zip file contents
		Write-Host "Extracting $appName deployment tool."
		Expand-Archive -LiteralPath $appZipPath -DestinationPath $workingDir -Force
		
		# Check if variable is set to install or uninstall
		If($env:installApp -eq "Uninstall"){
			# Start Lenovo System Update uninstall
			Write-Host "Starting uninstall of $appName."
			& $uninstall
			Exit 0
		}
		If($env:installApp -eq "Install"){
			# Start Lenovo System Update install
			Write-Host "Starting install of $appName."
			& $install
			If($env:getUpdates -eq $true){
				Write-Host "Checking for system updates and installing any that are found."
				Get-SystemUpdates
				Exit 0
			}
		}
	}Else{
		If($env:getUpdates -eq $true){
			Write-Host "Checking for system updates and installing any that are found."
			Get-SystemUpdates
			Exit 0
		}
		Write-Host "No action was taken."
		Exit 0
	}
}Catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message 
	Exit 1
}