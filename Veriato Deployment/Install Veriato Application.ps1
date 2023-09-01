<#
TITLE: Install Veriato Application [WIN]
PURPOSE: Installs the Veriato Application agent
CREATOR: Dan Meddock
CREATED: 16AUG2023
LAST UPDATED: 28AUG2023
#>

# Declarations
$tempFolder = "C:\Temp"
$veriato = 'VisionInstaller.msi'
$appVeriato = "C:\Temp\VisionInstaller.msi"
	
# Main
Try{
	# Check if Temp folder exsists
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force | Out-Null}
		
	# Transfer installers to computer
	Write-Host "Transferring installer to device."
	Copy-Item $veriato -Destination $appVeriato -force
	$veriato = $veriato -replace '.msi',''
	
	# Start application install
	Write-Host "Starting install of $veriato."
	Start-process msiexec.exe -argumentlist "/I $appVeriato /qn /L*V C:\temp\VeriatoInstall.log"; sleep 30
	Get-Content -Path "C:\temp\VeriatoInstall.log"

	# Clean up files
	Remove-Item -Path $appVeriato -Force -ErrorAction SilentlyContinue
	Remove-Item -Path "C:\temp\VeriatoInstall.log" -Force -ErrorAction SilentlyContinue

}catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message
	Exit 1
}

# Exit with a success
Write-Host "Finished installing $appVeriato."
Exit 0