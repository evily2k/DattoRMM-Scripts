<#
TITLE: Install Pulse Secure client [WIN]
PURPOSE: Installs the specified version of Pulse Secure Client
CREATOR: Dan Meddock
CREATED: 19APR2022
LAST UPDATED: 03MAY2022
#>

# Declarations
$tempFolder = "C:\Temp"
$application = 'Pulse_Secure.msi'
$pulseInstaller = "C:\Temp\Pulse_Secure.msi"
$clientName = $env:clientName
$installVPN = $env:installVPN
$installCheck = test-path -path "C:\Program Files (x86)\Pulse Secure\Pulse\PulseHelper.exe"
$JamCommand = "C:\Program Files (x86)\Common Files\Pulse Secure\JamUI\jamCommand.exe"

	
# Sets the Pulse Secure connection settings via switch
Function SetVPNSettings {
	param([Parameter (Mandatory=$true)] [int32] $clientName)	
	
	switch ($clientName){
		1{	
		$location = "Chicago"
		$locationReg = 'Chicago.pulsepreconfig'
		}
	    #2{
		#$client = ""
		#$clientReg = ''
		#}
	}
	# Copy over the Pulse secure config file
	$pulseReg = Join-Path -Path $tempFolder $locationReg
	write-host "Copying site preconfig file to $pulseReg."
	Copy-Item $locationReg -Destination $pulseReg -force
	
	# Verify jamCommand exists and then start the preconfig import
	if(test-path $jamCommand){
		write-host " Applying config for $location with $pulseReg."
		Sleep 10
		start-process -filepath $jamCommand -argumentlist "-importfile $pulseReg"
	}Else{
		write-host "No JamCommand file found to import config file with."
	}
}

# Main
Try{
	#Check if Temp folder exsists
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
	
	# Installs Pulse Secure client
	  If($installVPN -eq "True"){
		# Check if Pulse Secure is already installed		
		if($installCheck){
			Write-Host "Pulse Secure Client is already installed."
			Exit 1
		}
		# Transfer installers to computer
		Write-Host "Transferring installer to device."
		Copy-Item $application -Destination $pulseInstaller -force

		# Start installation of both applications
		Write-Host "Starting install of Pulse Secure Client."
		start-process -filepath $pulseInstaller -argumentlist "/qn"; sleep 30
		
		# Set shortcut path, path to application, start menu path
		$appPath = '"C:\Program Files (x86)\Common Files\Pulse Secure\JamUI\Pulse.exe"'
		$scPath = "C:\Users\Public\Desktop\Pulse Secure.lnk"
		$smPath = "C:\Users\All Users\Start Menu\Pulse Secure.lnk"

		# Create Shortcut for application
		$WshShell = New-Object -comObject WScript.Shell
		$Shortcut = $WshShell.CreateShortcut($scPath)
		$Shortcut.TargetPath = $appPath
		$Shortcut.Arguments = "-show"
		$Shortcut.Save()
		
	}Else{Write-Host "Pulse Secure Client install is set to ""No""."}
	
	# Transfer and install connection profile
	If($clientName){
		SetVPNSettings -clientName $clientName
		Write-host "Applying connection profile for Pulse Secure."
	}Else{Write-Host "No client VPN settings specified."}
	Exit 0
	# Catch any errors thrown
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}