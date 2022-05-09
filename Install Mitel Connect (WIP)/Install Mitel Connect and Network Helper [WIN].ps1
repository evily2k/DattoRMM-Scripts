<#
TITLE: Install Mitel Connect and Helper [WIN]
PURPOSE: Script to install Mitel Connect and Network Helper with client settings
CREATOR: Dan Meddock
CREATED: 14MAR2022
LAST UPDATED: 09MAY2022
#>

# Declarations
$tempFolder = "C:\Temp"
$ClientName = $env:ClientName
$mitelHelper = "C:\Temp\network-helper-latest.msi"

# Main
Try{
	If ($ClientName -eq "Client1"){
		$mitelZip = 'Client1MitelConnect.zip'
		Write-Host "Using Client1 Mitel Installer"
	}
	If ($ClientName -eq "Client2"){
		$mitelZip = 'Client2MitelConnect.zip'
		Write-Host "Using Client2 Mitel Installer"
	}
	$mitelFolder = $mitelZip -replace ".zip",""
	$mitelInstaller = $mitelZip -replace ".zip",".msi"
	$mitelCheck = test-path "C:\Temp\MitelConnect\$mitelFolder"
	
	#Check if Temp folder exsists
	If(!($mitelCheck)){
		If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
		# Transfer installers to computer
		Write-Host "Transferring Mitel Network Helper installer to device..."
		Copy-Item -Path 'network-helper-latest.msi' -Destination $mitelHelper -force
		
		# Copy insstaller to device
		Write-Host "Transferring $ClientName Mitel installer to device..."
		Copy-Item $mitelZip -Destination $tempFolder -force
		
		# Extract zip folder contents
		Expand-Archive -literalpath C:\Temp\$mitelZip -DestinationPath C:\Temp\MitelConnect
		
		# Start Install process
		Write-Host "Starting $ClientName Mitel install..."
		msiexec /i "C:\Temp\MitelConnect\$mitelFolder\$mitelInstaller" /qn
		
		# Start installation of both applications
		Write-Host "Starting install of applications."
		msiexec /i $mitelHelper /qn
		Sleep 15
		
		# Add firewall rules so users dont need admin rights to set the rules by theirself
		Write-Host "Adding firewall rules for Mitel Connect."
		New-NetFirewallRule -DisplayName "Mitel Connect" -Direction Inbound -Program "C:\Program Files (x86)\mitel\connect\mitel.exe" -Action Allow
		New-NetFirewallRule -DisplayName "Mitel Connect" -Direction Outbound -Program "C:\Program Files (x86)\mitel\connect\mitel.exe" -Action Allow
	}Else{
		msiexec /i "C:\Temp\MitelConnect\$mitelFolder\$mitelInstaller" /qn
	}
	
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}