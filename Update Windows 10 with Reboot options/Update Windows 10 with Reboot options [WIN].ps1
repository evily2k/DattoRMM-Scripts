<#
TITLE: Update Windows 10 with Reboot options [WIN]
Datto Component: Run Windows Updates and prompts reboot options
PURPOSE: Using the PSWindowsUpdate Module to run Windows 10 updates with options to reboot or not.
CREATOR: Dan Meddock
CREATED: 01APR2022
LAST UPDATED: 07NOV2022
#>

# Log Windows Updates output to log file
Start-Transcript -Path "C:\temp\Windows-Update.log"

# Declarations

# Uncomment this line if you are running this script manually through powershell
#Set-Executionpolicy -Scope CurrentUser -ExecutionPolicy UnRestricted -Confirm:$False -Force
Set-ExecutionPolicy Bypass -Scope Process -Force

Try{
	# Set TLS settings
	[Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)
}Catch [system.exception] {
	# Catch TLS errors and exit script with a error
	write-host "- ERROR: Could not implement TLS 1.2 Support."
	write-host "  This can occur on Windows 7 devices lacking Service Pack 1."
	write-host "  Please install that before proceeding."
	exit 1
}

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
			
			# Install windows updates, creates a scheduled task on computer -AutoReboot
			$script = ipmo PSWindowsUpdate; Install-WindowsUpdate -AcceptAll @params -Verbose | Out-File $logFile
			
			# Start the Windows update
			Invoke-WUjob -ComputerName localhost -Script $script -Confirm:$false -RunNow -Verbose
			 
			# Show update status until the amount of installed updates equals the same as the amount of updates available
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
				Write-Host "Number of installed updates: $installednumber"
				Write-Host "Number of failed updates: $Failednumber"
				
			# End loop once all updates complete or timeout limit is hit
			}until( ($installednumber + $Failednumber) -ge $updatenumber -or $updatetimeout -ge 60)

			# Removes schedule task from computer
			Unregister-ScheduledTask -TaskName PSWindowsUpdate -Confirm:$false

			# Display Windows Update log file contents in stdout in DattoRMM
			$winUpdateLog = get-content $logFile
			if ($winUpdateLog){
				foreach ($log in $winUpdateLog){
					Write-Host $log
				}
			}else{Write-Host "No Windows Update log found."}

			# Rename update log
			$date = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
			Rename-Item $DownloadDir\PSWindowsUpdate.log -NewName "WindowsUpdate-$date.log"
			
			# Write time that script completed at
			$scriptEnd = Get-Date
			Write-Host "Windows Updates finished at"$scriptEnd
		}
	}catch{
		# Catch any powershell errors and output the error message
		Write-Error $_.Exception.Message
	}
}

# Main
# Run Windows updates
updateWindows

# Stop transcript logging
Stop-Transcript