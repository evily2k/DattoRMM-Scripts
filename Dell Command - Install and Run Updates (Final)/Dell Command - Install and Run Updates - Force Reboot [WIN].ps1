<#
TITLE: Dell Command - Install and Ran Updates - Force Reboot[WIN]
PURPOSE: Installs Dell Command, runs scan for updates, installs updates, if a reboot is required it will reboot after the installation completes, suspends bitlocker
CREATOR: Dan Meddock
CREATED: 10DEC2021
LAST UPDATED: 25APR2022
#>

# Function to output log results to Datto's activity log
Function writeDattoActivity(){
	$getLog = @(get-content -path $LogFilePath)
	foreach ($message in $getLog){write-host $message}
}

# Main
If ((Get-ComputerInfo).CsManufacturer -match "Dell"){
	try {
		# Declarations
		$DownloadURL = "https://downloads.dell.com/FOLDER07820512M/1/Dell-Command-Update-Application_8DGG4_WIN_4.4.0_A00.EXE"
		$DownloadLocation = "C:\Temp\Dell"
		$LogFilePath = "$($DownloadLocation)\dellUpdate.log"
		$druLocation64 = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
		$druLocation32 = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
		
		# Check if dell command exists; if not then download and install
		$TestDownloadLocation = Test-Path $DownloadLocation
		if (!$TestDownloadLocation) { new-item $DownloadLocation -ItemType Directory -force }
		$TestDownloadLocationZip = Test-Path "$($DownloadLocation)\DellCommandUpdate.exe"
		if (!$TestDownloadLocationZip) { 
			(New-Object System.Net.WebClient).DownloadFile($DownloadURL, "$($DownloadLocation)\DellCommandUpdate.exe")
			Start-Process -FilePath "$($DownloadLocation)\DellCommandUpdate.exe" -ArgumentList '/s' -Verbose -Wait
			set-service -name 'DellClientManagementService' -StartupType Manual
		} 
	}
	catch {
		write-host "The download and installation of DCUCli failed. Error: $($_.Exception.Message)"
	}
	# Run Dell Command and update
	try {	
		if (test-path -path $druLocation32 -pathtype leaf){$druDir = $druLocation32}else{$druDir = $druLocation64}	
		write-host "Starting Dell Command update."
		start-process -NoNewWindow -FilePath $druDir -ArgumentList "/applyUpdates -silent -reboot=enable -autoSuspendBitLocker=enable -outputLog=$($DownloadLocation)\dellUpdate.log" -Wait
	}catch{
		write-host $_.Exception.Message
		# Write log file output to console to display in Datto logging
		writeDattoActivity
		Exit 1
	}
}

# Write log file output to console to display in Datto logging
writeDattoActivity
exit 0
