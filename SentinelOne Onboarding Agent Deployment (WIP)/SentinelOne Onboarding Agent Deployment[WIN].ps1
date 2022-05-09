# Declarations
$tempFolder = "C:\Temp"
$siteVar = $env:SentinelOneDeployment

# Main
Try{
	#Check if Temp folder exists
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
	If(!($siteVar)){
		write-host "No Sentinel One Token found. Exiting installation."
		Exit 1
	}
	# Copy installer to device
	Copy-Item 'SentinelInstaller_windows_64bit_v21_7_2_1038.msi' -Destination $tempFolder -force
	Start-Process msiexec.exe -Wait -ArgumentList "/I C:\Temp\SentinelInstaller_windows_64bit_v21_7_2_1038.msi /q /norestart UI=false SITE_TOKEN=$siteVar"
	Write-host "Installing Sentinel One using $CS_PROFILE_NAME Site Token."
	Write-host "$siteVar"
	Exit 0
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}