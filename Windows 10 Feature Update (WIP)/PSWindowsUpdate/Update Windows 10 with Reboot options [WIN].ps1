<#
TITLE: Update Windows 10 with Reboot options [WIN]
PURPOSE: Used with PPKG file to force device to update all Dell drivers and software and then runs Windows updates
CREATOR: Dan Meddock
CREATED: 27MAY2022
LAST UPDATED: 27MAY2022
#>

# Function to check for all available Windows updates and instal them
Function updateWindows {
	
	Try{
		# Check if PowerCLI is installed; if not then install it
		If(!(Get-InstalledModule PSWindowsUpdate -ErrorAction silentlycontinue)){
			Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Confirm:$False -Force
			Set-PSRepository PSGallery -InstallationPolicy Trusted
			Install-Module PSWindowsUpdate -Confirm:$False -Force
		}
		# Download and log file direcotry and update variables
		$DownloadDir = "C:\temp"
		$logFile ="$DownloadDir\PSWindowsUpdate.log"
		$updatetimeout = 0
		$updates = Get-wulist -verbose
		$updatenumber = ($updates.kb).count
		
		# Check if folders exis
		if (!(Test-Path $DownloadDir)){New-Item -ItemType Directory -Path $DownloadDir}
		
		# If there are available updates proceed with installing the updates and then reboot the remote machine
		if ($updates -ne $null){
				
			# Check if rebootOption is checked to autoReboot or ignoreReboot
			if($env:rebootComputer -eq "true"){$rebootOption = '-AutoReboot'}else{$rebootOption = '-IgnoreReboot'}
			$params = @{$rebootOption = $true}
			
			# Install windows updates, creates a scheduled task on computer
			$script = ipmo PSWindowsUpdate; Install-WindowsUpdate -AcceptAll @params -Verbose | Out-File $logFile
			
			# Start the Windows update
			Invoke-WUjob -ComputerName localhost -Script $script -Confirm:$false -RunNow -Verbose
			 
			#Show update status until the amount of installed updates equals the same as the amount of updates available
			sleep -Seconds 30
			
			# Monitor update log until all updates have been installed
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
				
			# End loop once all updates complete or timeout limit is hit
			}until( ($installednumber + $Failednumber) -ge $updatenumber -or $updatetimeout -ge 60)
			
			# Writes log output for DattoRMM
			Get-Content $DownloadDir\PSWindowsUpdate.log
			
			#removes schedule task from computer
			Unregister-ScheduledTask -TaskName PSWindowsUpdate -Confirm:$false

			# rename update log
			$date = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
			Rename-Item $DownloadDir\PSWindowsUpdate.log -NewName "WindowsUpdate-$date.log"
		}
	}catch {
		# Catch any powershell errors and output the error message
		Write-Error $_.Exception.Message
	}
}

# Run Windows updates
updateWindows