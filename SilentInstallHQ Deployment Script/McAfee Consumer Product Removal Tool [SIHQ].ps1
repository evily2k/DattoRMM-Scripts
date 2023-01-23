<#
TITLE: McAfee Consumer Product Removal Tool [WIN]
PURPOSE: Script to install McAfee Consumer Product Removal Tool (SilentUnstallHQ Template)
CREATOR: Dan Meddock
CREATED: 23JAN2023
LAST UPDATED: 23JAN2023
#>

# Declarations
$workingDir = "C:\KEworking"
$appZip = 'MCPR.zip'
$installPackage = "Run-MCPR.ps1"
$appName = "McAfee Consumer Product Removal Tool"

# Paths and Variable manipulation (dont change)
$appZipPath = join-path -path $workingDir -childpath $appZip
$appPath = $appZipPath -replace ".zip",""
$deploymentTool = join-path -path $appPath -childpath $installPackage

# Commands
$install = {Powershell.exe -ExecutionPolicy Bypass $deploymentTool -DeploymentType "Install" -DeployMode "NonInteractive"}

# Function to remove install files once the install/uninstall is complete
function removeInstaller {
	Write-Output "Removing installer files."
	Remove-Item -path $appZipPath -recurse -force
	Remove-Item -path $appPath -recurse -force
}

# Main
Try{
	# Check if working directory exists
	If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force}
	
	# Transfer installers to computer
	Write-Host "Transferring $appName deployment tool to device."
	Copy-Item $appZip -Destination $workingDir -force
	
	# Extracting zip file contents
	Write-Host "Extracting $appName deployment tool."
	Expand-Archive -LiteralPath $appZipPath -DestinationPath $workingDir -Force
	
	# Start McAfee Consumer Product Removal Tool
	Write-Host "Starting install of $appName."
	& $install
	removeInstaller
	Exit 0
		
	}Catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message 
	Exit 1
}