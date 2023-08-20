<#
TITLE: Install Veriato Application [WIN]
PURPOSE: Installs the specified version of Pulse Secure Client
CREATOR: Dan Meddock
CREATED: 19APR2022
LAST UPDATED: 15MAY2022
#>

# Declarations
$tempFolder = "C:\Temp"
$application = 'VisionInstaller.msi'
$appInstaller = "C:\Temp\VisionInstaller.msi"
	
# Main
Try{
	# Check if Temp folder exsists
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force | Out-Null}
		
	# Transfer installers to computer
	Write-Host "Transferring installer to device."
	Copy-Item $application -Destination $appInstaller -force
	$application = $application -replace '.msi',''
	
	# Start application install
	Write-Host "Starting install of $application."
	Start-process msiexec.exe -argumentlist "/I $appInstaller /qn /L*V C:\temp\VeriatoInstall.log"; sleep 30
	Get-Content -Path "C:\temp\VeriatoInstall.log"

}catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message
	Exit 1
}

# Exit with a success
Write-Host "Finished installing $application."
Exit 0