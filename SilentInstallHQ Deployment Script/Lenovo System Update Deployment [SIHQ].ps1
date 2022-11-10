<#
TITLE: Lenovo System Updates [WIN]
PURPOSE: Script to install or uninstall Lenovo System Updates (SilentUnstallHQ Template)
CREATOR: Dan Meddock
CREATED: 25AUG2022
LAST UPDATED: 25AUG2022
#>

# Declarations
$workingDir = "C:\KEworking"
$appZip = 'LenovoSU.zip'
$installPackage = "Deploy-LenovoSU.ps1"
$appName = "Lenovo System Update"

# Paths and Variable manipulation (dont change)
$appZipPath = join-path -path $workingDir -childpath $appZip
$appPath = $appZipPath -replace ".zip",""
$deploymentTool = join-path -path $appPath -childpath $installPackage

# Commands
$install = {Powershell.exe -ExecutionPolicy Bypass $deploymentTool -DeploymentType "Install" -DeployMode "NonInteractive"}
$uninstall = {Powershell.exe -ExecutionPolicy Bypass $deploymentTool -DeploymentType "Uninstall" -DeployMode "NonInteractive"}

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
		# Start Lenovo System Update install
		Write-Host "Starting install of $appName."
		& $install
		Exit 0
	}Else{
		# Start Lenovo System Update uninstall
		Write-Host "Starting uninstall of $appName."
		& $uninstall
		Exit 0
	}
}Catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message 
	Exit 1
}