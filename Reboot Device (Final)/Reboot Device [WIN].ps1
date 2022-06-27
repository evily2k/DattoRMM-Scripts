<#
TITLE: Reboot Device [WIN]
PURPOSE: Perform a reboot operation on a Windows device with a configurable time. BitLocker can optionally be suspended. Reboot at Midnight option.
CREATOR: Dan Meddock
CREATED: 11MAR2022
LAST UPDATED: 11MAR2022
#>

# Main
Try{
	#suspend bitlocker?
	if ($env:usrSuspendBitlocker -match 'true') {
		if ($((get-host).Version.Major) -lt 3) {
			write-host "! ERROR: Device has been instructed to suspend BitLocker, but"
			write-host "  the PowerShell version installed is too low to permit this action."
			write-host "  Please upgrade to at least PowerShell version 3.0 to enable"
			write-host "  the ability to suspend BitLocker before performing power tasks."
			write-host "  The shutdown or reboot will proceed as normal without this option."
		} else {
			$arrBitLockerVolumes=@()
			Get-BitLockerVolume | ? {$_.ProtectionStatus -eq 1} | % {
				$arrBitLockerVolumes+=$_.MountPoint
			}

			foreach ($mount in $arrBitLockerVolumes) {
				write-host "- Suspending BitLocker for drive $mount..."
				Suspend-BitLocker -mountPoint $mount | select MountPoint,EncryptionMethod,ProtectionStatus | Out-String
			}
		}
	}
	# Check that reboot time and reboot at midnight arent both set
	If (($env:usrRebootTime) -and ($env:usrRebootMidnight -match 'true')){
		Write-Host "You can't set both reboot at midnight and reboot time and run the script."
		Exit 1
	}
	# Check if time is a future time
	If ((([int]([datetime]"$env:usrRebootTime"-(Get-Date)).TotalSeconds)) -lt 0){
		Write-Host "Time entered is behind the current time. Please entry a valid time."
		Exit 1
	}
	# Test the entered time is a valid time
	If($env:usrRebootTime -match '\b((1[0-2]|0?[1-9]):([0-5][0-9])\s*([AaPp][Mm]))'){
		Write-Host "Restarting computer at $env:usrRebootTime"
		shutdown -r -t $([int]([datetime]"$env:usrRebootTime"-(Get-Date)).TotalSeconds)
		Exit 0
	}Else{
		Write-Host "The time entered does not match the correct format. Please rerun the script with a valid time entry."
		Exit 1
	}
	If($env:usrRebootMidnight -match 'true') {
		Write-Host "Restarting computer at Midnight tonight"
		shutdown -r -t $([int]([datetime]"11:59PM"-(Get-Date)).TotalSeconds)
		Exit 0
	}
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}