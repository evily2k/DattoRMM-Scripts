<#
TITLE: Angry IP Scanner [WIN]
PURPOSE: Script to install or uninstall Angry IP Scanner (SilentUnstallHQ Template)
CREATOR: Dan Meddock
CREATED: 10NOV2022
LAST UPDATED: 10NOV2022
#>

# Declarations
$workingDir = "C:\KEworking"
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

# Check if working directory exists
If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force}

# Main
Try{
	# Transfer installers to computer
	Write-Host "Transferring $appName deployment tool to device."
	Copy-Item $appZip -Destination $workingDir -force
	
	# Extracting zip file contents
	Write-Host "Extracting $appName deployment tool."
	Expand-Archive -LiteralPath $appZipPath -DestinationPath $workingDir -Force
	
	# Check if variable is set to install or uninstall
	If($env:installApp -eq "True"){
		# Start application install
		Write-Host "Starting install of $appName."
		& $install
		Exit 0
	}Else{
		# Start application uninstall
		Write-Host "Starting uninstall of $appName."
		& $uninstall
		Exit 0
	}
}Catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message 
	Exit 1
}