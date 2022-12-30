<#
TITLE: Thunderbird [WIN]
PURPOSE: Script to install or uninstall Thunderbird (SilentUnstallHQ Template)
CREATOR: Dan Meddock
CREATED: 30DEC2022
LAST UPDATED: 30DEC2022
#>

# Declarations
$workingDir = "C:\KEworking"
$appZip = 'Thunderbird.zip'
$installPackage = "Deploy-Thunderbird.ps1"
$appName = "Thunderbird"

# Paths and Variable manipulation (dont change)
$appZipPath = join-path -path $workingDir -childpath $appZip
$appPath = $appZipPath -replace ".zip",""
$deploymentTool = join-path -path $appPath -childpath $installPackage

# Commands
$install = {Powershell.exe -ExecutionPolicy Bypass $deploymentTool -DeploymentType "Install" -DeployMode "silent"}
$uninstall = {Powershell.exe -ExecutionPolicy Bypass $deploymentTool -DeploymentType "Uninstall" -DeployMode "silent"}

# Function to remove instal files once the install/uninstall is complete
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
	
	# Check if variable is set to install or uninstall
	If($env:installApp -eq "True"){
		# Start Lenovo System Update install
		Write-Host "Starting install of $appName."
		& $install
		removeInstaller
		Exit 0
	}Else{
		# Start Lenovo System Update uninstall
		Write-Host "Starting uninstall of $appName."
		& $uninstall
		removeInstaller
		Exit 0
	}
}Catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message 
	Exit 1
}