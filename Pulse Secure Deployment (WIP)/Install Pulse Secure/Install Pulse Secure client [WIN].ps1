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
		$location = "Chi-Ash"
		$preconfig = 'Chi-AshCC.pulsepreconfig'
		}
	   #2{
		#$client = ""
		#$clientReg = ''
		#}
	}
	
	# Copy over the Pulse secure config file
	$pulseReg = Join-Path -Path $tempFolder $preconfig
	write-host "Copying site preconfig file to $pulseReg."
	Copy-Item $preconfig -Destination $pulseReg -force
	
	# Verify jamCommand exists and then start the preconfig import
	try{
		if(test-path $jamCommand){
			Sleep 10
			start-process -filepath $jamCommand -argumentlist "-importfile $pulseReg"
			write-host "Preconfig file has been applied for $location with $pulseReg."
		}Else{
			write-host "No JamCommand file found to import config file with."
			Exit 1
		}
	}catch{
		Write-Host "An error occured. Please check the preconfig file is valid."
		Write-Error $_.Exception.Message
		Exit 1
	}
}

# Main
Try{
	# Check if Temp folder exsists
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

		# Start Pulse Secure application install
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
	
	# Transfer and install Pulse Secure connection profiles
	If($clientName){
		Write-host "Applying connection profile for Pulse Secure."
		SetVPNSettings -clientName $clientName		
	}Else{Write-Host "No client VPN settings specified."}	
	Exit 0
	
# Catch any errors thrown and exit with an error
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}