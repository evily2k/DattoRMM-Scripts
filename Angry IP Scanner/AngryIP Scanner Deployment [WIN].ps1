<#
TITLE: Angry IP Scanner [WIN]
PURPOSE: Script to install or uninstall Angry IP Scanner using SilentUnstallHQ's PSAppDeployToolkit
Reference URL: https://silentinstallhq.com/angry-ip-scanner-install-and-uninstall-powershell/
CREATOR: Dan Meddock
CREATED: 25AUG2022
LAST UPDATED: 26MAY2023
#>

# Declarations
$workingDir = "C:\Temp"
$appZip = 'AngryIPScanner.zip'
$installPackage = "Deploy-AngryIPScanner.ps1"
$appName = "Angry IP Scanner"

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
	
	# Start the application install
	If($env:installApp -eq "True"){
		Write-Host "Starting install of $appName."
		& $install
	}
	# Start the application uninstall
	If($env:installApp -eq "False"){
		Write-Host "Starting uninstall of $appName."
		& $uninstall
	}
	
	# Clean up install files
    Write-Host "Cleaning up temporary files..."
    Remove-Item -Path $appZipPath -Recurse -Force
    Remove-Item -Path $appPath -Recurse -Force
    Exit 0
	
}Catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message 
	Exit 1
}