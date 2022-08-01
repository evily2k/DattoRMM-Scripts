<#
TITLE: Get-PSWindowsUpdates
PURPOSE: Using the PSWindowsUpdate Module to run Windows 10 updates
CREATOR: Dan Meddock
CREATED: 29MAR2022
LAST UPDATED: 09MAY2022
#>

# Log Windebloater output to log file
Start-Transcript -Path "C:\temp\PPKG-PSWindowsUpdates.log"

# Declarations
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted -Confirm:$False -Force

$DownloadDir = "C:\temp"

# Check if PowerCLI is installed; if not then install it
If(-not(Get-InstalledModule PSWindowsUpdate -ErrorAction silentlycontinue))
{
	Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Confirm:$False -Force
	Set-PSRepository PSGallery -InstallationPolicy Trusted
	Install-Module PSWindowsUpdate -Confirm:$False -Force
}

Try{
	#Reset Timeouts and Updates
	$updatetimeout = 0
	$updates = Get-wulist -verbose
	$updatenumber = ($updates.kb).count
	
	# Check if folders exis
	if (!(Test-Path $DownloadDir)){New-Item -ItemType Directory -Path $DownloadDir}

	#if there are available updates proceed with installing the updates and then reboot the remote machine
	if ($updates -ne $null){

		# Install windows updates, creates a scheduled task on computer -AutoReboot
		$script = ipmo PSWindowsUpdate; Install-WindowsUpdate -AcceptAll -IgnoreReboot | Out-File $DownloadDir\PSWindowsUpdate.log
		Invoke-WUjob -ComputerName localhost -Script $script -Confirm:$false -RunNow
		 
		#Show update status until the amount of installed updates equals the same as the amount of updates available
		sleep -Seconds 30

		do {$updatestatus = Get-Content $DownloadDir\PSWindowsUpdate.log
			Get-Content $DownloadDir\PSWindowsUpdate.log| select-object -last 1
			sleep -Seconds 10
			$ErrorActionPreference = 'SilentlyContinue'
			$installednumber = ([regex]::Matches($updatestatus, "Installed" )).count
			$Failednumber = ([regex]::Matches($updatestatus, "Failed" )).count
			$ErrorActionPreference = 'Continue'
			$updatetimeout++
			echo $installednumber
			echo $Failednumber

		}until ( ($installednumber + $Failednumber) -ge $updatenumber -or $updatetimeout -ge 60)
		
		# Writes log output for DattoRMM
		Get-Content $DownloadDir\PSWindowsUpdate.log

		#removes schedule task from computer
		Unregister-ScheduledTask -TaskName PSWindowsUpdate -Confirm:$false

		# rename update log
		$date = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
		Rename-Item $DownloadDir\PSWindowsUpdate.log -NewName "WindowsUpdate-$date.log"
		
		# Might make a prompt so the user selects to reboot and/or schedule the reboot or deny it completely.
		#Restart-Computer -Confirm:$false -Force
		#Exit 0
	}
}catch {
    Write-Error $_.Exception.Message
}

Stop-Transcript
