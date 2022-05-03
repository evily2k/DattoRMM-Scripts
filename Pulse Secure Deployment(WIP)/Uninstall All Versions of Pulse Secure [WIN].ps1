<#
TITLE: Uninstall All Versions of Pulse Secure [WIN]
PURPOSE: Uninstall unwanted Pulse Secure versions and clean up program files
CREATOR: Dan Meddock
CREATED: 14APR2022
LAST UPDATED: 22APR2022
#>

# Declarations 
# Applications to search for
$tempFolder = "C:\Temp"
$application = @(
	'Pulse Secure'
	'Pulse Application'
)
# Registry paths
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Pulse Secure versions to keep (Uncomment this line if needed)
#$VersionsToKeep = @('')

# Main
Try{	
	# Creates the temp folder if it doesnt exist
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
	
	# Search for all aplications in the registry and force an uninstall
	foreach ($Path in $RegUninstallPaths) {
		if (Test-Path $Path) {
			foreach ($app in $application){
				$UninstallSearchFilter = {($_.GetValue('DisplayName') -match $app) -and ($VersionsToKeep -notcontains $_.GetValue('DisplayName'))}
				Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
				foreach { 
					$appName = $_.GetValue('DisplayName')
					$uninstallString = $_.GetValue('UninstallString')
					$appVersion = $_.GetValue('DisplayVersion')
					
					# Check if uninstall string uses MSIEXEC
					if($uninstallString -match "msiexec"){
						$appRemove = $uninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
						$appRemove = $appRemove.Trim()
						# Save reg key
						$regkey = $appRemove
						Write-Host "Uninstalling $appName $appVersion"
						start-process "msiexec.exe" -arg "/X $appRemove /qn" -Wait 
					}
					
					# Checks if uninstall string is an EXE
					if($uninstallString -match "uninstall*"){
						$appRemove = $uninstallString -Replace "`"",""
						$appRemove = $appRemove.Trim()
						$appRemove = '"{0}"' -f $appRemove
						Write-Host "Uninstalling $appName $appVersion"
						start-process $appRemove -arg "/S" -Wait
					}
				}
			}
		}
	}
	
	# Uninstalls Pulse Secure from AppData by scheduling a task
	# Task will execute the uninstaller as the currently logged on user
	$appDataPath = "C:\Users\*\AppData\Roaming\Pulse Secure\Setup Client"
	$installDir = (gci -path $appDataPath -filter "*uninstall*" -recurse).directoryname
	$pulseSetupProcess = Get-Process PulseSetupClient -ErrorAction SilentlyContinue
	
	# Checks for Pulse Secure Setup process and if running it will stop it.
	If($pulseSetupProcess){
		Write-Host "Stopping Pulse Secure Setup process..."
		$pulseSetupProcess | stop-process -force
	}
	
	# Finds a user account to run the scheduled removal task
	$currentUser = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -expand UserName)
	if(!($currentUser)){
		$localAdmin = (get-localuser | where-object {$_.Name -like "*ADMIN"}).name
		if($localAdmin.Count -gt 1){
			$currentUser = $localAdmin[0]
			$currentUser = $env:COMPUTERNAME + "\" + $currentUser
			Write-host "Using local admin account $currentUser to schedule removal task."
		}else{
			$currentUser = $localAdmin
			$currentUser = $env:COMPUTERNAME + "\" + $currentUser
			Write-host "Using local admin account $currentUser to schedule removal task."
		}
	}else{
		Write-Host "Using currently signed in user account $currentUser to schedule Pulse Secure removal task."
	}
	
	# Creates a scheduled task to run as the currently signed in user
	if($currentUser){
		foreach($appDataLoc in $installDir){
			$uninstaller = $appDataLoc + "\uninstall.exe"
			if(test-path $uninstaller){
				$action = New-ScheduledTaskAction -Execute $uninstaller -Argument "/S"
				$trigger = New-ScheduledTaskTrigger -Once -At (get-date).AddSeconds(5)
				$principal = New-ScheduledTaskPrincipal -UserId $currentUser
				$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
				Register-ScheduledTask PulseSecureDelete -InputObject $task
				Start-ScheduledTask -TaskName PulseSecureDelete
				Start-Sleep -Seconds 10
				Unregister-ScheduledTask -TaskName PulseSecureDelete -Confirm:$false
			}Else{
				Write-Host "No appdata uninstaller found."
			}
		}
	}Else{
		Write-Host "No users are currently signed into the computer."
	}
	
	# Find remaining regkeys
	foreach ($app in $application){
		$leftOverReg = $RegUninstallPaths | %{gci -path $_ |% {get-itemproperty $_.PsPath} | ? {$_.displayName -match $app}}
		$key = $leftOverReg.PSPath
		if ($key){
			$key = $key -replace "Microsoft.PowerShell.Core\\Registry::HKEY_LOCAL_MACHINE","HKLM"
			Write-Host "Backing up regkey that contains ""$app"""
			$time = Get-Date -f HH-mm-ss.fff
			$regBackup = "C:\temp\pulseSecure" + $time + ".reg"
			reg export $key $regBackup
			Write-Host "Deleting the following regkey that contains ""$app"":"
			$key = $key -replace "HKLM","HKLM:"
			Write-Host "$key"
			Remove-Item $key -Force -Recurse
		}else{
			write-host "No registry keys found containing ""$app"" to be deleted."
		}
	}	

	# Get Username, SID, and location of ntuser.dat for all users
	$PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$'
	$ProfileList = @()
	$ProfileList = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | Where-Object { $_.PSChildName -match $PatternSID } |
	Select  @{ name = "SID"; expression = { $_.PSChildName } },
	 @{ name = "UserHive"; expression = { "$($_.ProfileImagePath)\ntuser.dat" } },
	 @{ name = "Username"; expression = { $_.ProfileImagePath -replace '^(.*[\\\/])', '' } }

	# Finds and loads any user registry hive to delete the Pulse secure uninstall key from HKCU
	foreach($profile in $ProfileList){
		write-host "loading reg profile"
		reg load "HKU\$($profile.SID)" "$($Profile.UserHive)"
		$RegLocal = "Registry::HKEY_USERS\$($Profile.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\uninstall\Pulse_Setup_Client"
		$regBackup = "HKU\$($Profile.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\uninstall\Pulse_Setup_Client"
		if(test-path $RegLocal){
			$time = Get-Date -f HH-mm-ss.fff
			$regBackupDir = "C:\temp\pulseSecureHKCU" + $time + ".reg"
			Write-Host "Backing up registry key before deleting:"
			Write-Host $regBackup
			reg export $regBackup $regBackupDir
			Write-Host "Removing AppData program regkey:"
			Write-Host $RegLocal
			Remove-Item $RegLocal -Force
		}else{
			write-host "No HKCU regkey found."
		}
		[gc]::Collect()
		Write-host "Unloading registry key:"
		write-host ""HKU\$($Profile.SID)""
		reg unload "HKU\$($Profile.SID)"
	}
	Sleep 5
	
	# Delete Desktop Shortcut
	$scPath = "C:\Users\Public\Desktop\Pulse Secure.lnk"
	$smPath = "C:\Users\All Users\Start Menu\Pulse Secure.lnk"
	Write-Host "Deleting Desktop Icons."
	if($scPath){Remove-Item $scPath -force -ErrorAction SilentlyContinue}
	if($smPath){Remove-Item $smPath -force -ErrorAction SilentlyContinue}
	
	# Clean and delete left over folders and files in appdata locations
	$AppPath = "C:\Users\*\AppData\Roaming\"
	$instaDir = (gci -path $AppPath -filter "*Pulse*" -recurse).directoryname
	if ($instaDir){
		foreach($dir in $instaDir){
			&cmd.exe /c rd /s /q $dir 2>$nul 5>$nul
			if (!(test-path $dir)){
				Write-Host "Pulse Secure AppData folder found and deleted:"
				Write-Host "$dir"
			}else{
				Write-Host "Failed to delete Pulse Secure AppData folder."
				Write-Host "$dir"
			}
		}
	}else{
		write-host "No Pulse Secure AppData installation directory found."
	}
	Exit 0
}Catch{
	Write-Error $_.Exception.Message 
}