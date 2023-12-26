<#
TITLE: DW Spectrum Deployment [WIN]
PURPOSE: Installs or uninstalls the DW Spectrum client and/or server silently
CREATOR: Dan Meddock
CREATED: 17OCT2023
LAST UPDATED: 17OCT2023
#>

# Declarations
$tempFolder = "C:\Temp"
$clientInstaller = 'dwspectrum-client.exe'
$serverInstaller = 'DWClientAndServer.exe'
$dwClient = $tempFolder + "\" + $clientInstaller
$dwServer = $tempFolder + "\" + $serverInstaller
$install = $env:install

# Main
Function installDWclient{
	Try{
		#Check if Temp folder exsists
		If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
		# Copy insstaller to device
		Copy-Item $clientInstaller -Destination $tempFolder -force
		# Start Install process
		start-process -filepath $dwClient -argumentlist "/S"

	}catch{
		Write-Error $_.Exception.Message 
	}
}

Function installDWclientServer{
	Try{
		#Check if Temp folder exsists
		If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
		# Copy insstaller to device
		Copy-Item $serverInstaller -Destination $tempFolder -force
		# Start Install process
		start-process -filepath $dwServer -argumentlist "/S"

	}catch{
		Write-Error $_.Exception.Message 
	}
}

Function uninstallDW{
		# Need to look intoremoval process
}

# Main

# Run the installer or the removal tool
if($install -eq "True"){
	if($dwClientInstall -eq "1"){
		Write-Host "Starting install for DW Spectrum Client."
		installDWclient
		Write-Host "Finished installing DW Spectrum Client."
	}
	if($dwClientServerInstall -eq "2"){
		Write-Host "Starting install for DW Spectrum Client and Server."
		installDWclientServer
		Write-Host "Finished installing DW Spectrum Client and Server."
	}
}else{
	Write-Host "Starting uninstall for DW Spectrum"
	uninstallDW
	Write-Host "Finished uninstalling DW Spectrum."
}

# Exit with a success
Exit 0