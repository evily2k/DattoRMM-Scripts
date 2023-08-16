<#
TITLE: RingCentral App Deployment [WIN]
PURPOSE: Script to install or uninstall the RingCentral App (SilentUnstallHQ Template)
CREATOR: Dan Meddock
CREATED: 19JUN2023
LAST UPDATED: 19JUN2023
#>

# Declarations
$workingDir = "C:\Temp"
$appZip = 'RingCentralApp2.zip'
$installPackage = "Deploy-RingCentralApp.ps1"
$appName = "RingCentral App"

# Paths and Variable manipulation (dont change)
$appZipPath = join-path -path $workingDir -childpath $appZip
$appPath = $appZipPath -replace ".zip",""
$deploymentTool = join-path -path $appPath -childpath $installPackage

# Commands
$install = {Powershell.exe -ExecutionPolicy Bypass $deploymentTool -DeploymentType "Install" -DeployMode "silent"}
$uninstall = {Powershell.exe -ExecutionPolicy Bypass $deploymentTool -DeploymentType "Uninstall" -DeployMode "silent"}

# Main

Try{
	# Check if working directory exists
	If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force | Out-Null}
	
	# Transfer installers to computer
	Write-Host "Transferring $appName deployment tool to device."
	Copy-Item $appZip -Destination $workingDir -force
	
	# Extracting zip file contents
	Write-Host "Extracting $appName deployment tool."
	Expand-Archive -LiteralPath $appZipPath -DestinationPath $workingDir -Force
	
	# Start the application install or uninstall process
	If($env:installApp -eq "True"){
		Write-Host "Starting install of $appName."
		& $install
	}
	If($env:installApp -eq "False"){
		Write-Host "Starting uninstall of $appName."
		& $uninstall
	}

	# Add firewall rules so users dont need admin rights to set the rules by theirself
	Write-Host "Adding firewall rules for Ring Central."
	New-NetFirewallRule -DisplayName "Allow RingCentral - All Networks" -Direction Inbound -Program "C:\Program Files\RingCentral\RingCentral.exe"  -Action Allow -Enabled True
	New-NetFirewallRule -DisplayName "Allow RingCentral - All Networks" -Direction Outbound -Program "C:\Program Files\RingCentral\RingCentral.exe"  -Action Allow -Enabled True
	
	# Clean up install files
	Write-Host "Cleaning up temporary files..."
	Sleep 10
	Remove-Item -Path $appZipPath -Recurse -Force
	Remove-Item -Path $appPath -Recurse -Force
	
}Catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message 
	Exit 1
}
Exit 0