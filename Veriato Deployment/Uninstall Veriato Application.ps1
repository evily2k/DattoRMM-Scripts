<#
TITLE: Uninstall Veriato Application [WIN]
PURPOSE: Uninstalls the Veriato Application agent
CREATOR: Dan Meddock
CREATED: 16AUG2023
LAST UPDATED: 28AUG2023
#>

# Declarations
$tempFolder = "C:\Temp"
$application = 'uninstall64.exe'
$appUninstaller = "C:\Temp\uninstall64.exe"
$textFile = 'UninstallKey.txt'
$textFileDir = "C:\Temp\UninstallKey.txt"
	
# Main
Try{
	# Check if Temp folder exsists
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force | Out-Null}
		
	# Transfer installers to computer
	Write-Host "Transferring installer to device."
	Copy-Item $application -Destination $appUninstaller -force
	Copy-Item $textFile -Destination $textFileDir -force
	
	# Start application install
	Write-Host "Starting uninstall of Veriato agent."
	start-process "C:\temp\uninstall64.exe" -argumentlist "/R"; sleep 30
	
	# Clean up files
	Remove-Item -Path $appUninstaller -Force -ErrorAction SilentlyContinue
	Remove-Item -Path $textFileDir -Force -ErrorAction SilentlyContinue
	
}catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message
	Exit 1
}

# Exit with a success
Write-Host "Finished uninstall of the Veriato agent."
Exit 0