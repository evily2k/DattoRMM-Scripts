<#
TITLE: Genesys Deployment [WIN]
PURPOSE: Installs or uninstalls the Genesys agent silently
CREATOR: Dan Meddock
CREATED: 08SEP2023
LAST UPDATED: 08SEP2023
#>

# Declarations
$tempFolder = "C:\Temp"
$installer = 'genesys-cloud-background-assistant-windows-1.0.179.exe'
$appInstaller = "C:\Temp\genesys-cloud-background-assistant-windows-1.0.179.exe"
$install = $env:install
	
Function installGenesys {
	Try{
		# Check if Temp folder exsists
		If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force | Out-Null}
			
		# Transfer installers to computer
		Write-Host "Transferring installer to device."
		Copy-Item $installer -Destination $appInstaller -force
		$installer = $installer -replace '.exe',''
		
		# Start application install
		Write-Host "Starting install of $installer."
		Start-process $appInstaller -argumentlist "-install /quiet"; sleep 45
		
	}catch{
		# Catch any errors thrown and exit with an error
		Write-Error $_.Exception.Message
		Exit 1
	}
}

Function removeGenesys {
	Try{
		# Check if Temp folder exsists
		If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force | Out-Null}
			
		# Transfer installers to computer
		Write-Host "Transferring installer to device."
		Copy-Item $installer -Destination $appInstaller -force
		$installer = $installer -replace '.exe',''
		
		# Start application install
		Write-Host "Starting install of $installer."
		Start-process $appInstaller -argumentlist "-uninstall /quiet"; sleep 45
		
	}catch{
		# Catch any errors thrown and exit with an error
		Write-Error $_.Exception.Message
		Exit 1
	}
}

# Run the installer or the uninstall
if($install -eq "True"){
	Write-Host "Starting install for Genesys"
	installGenesys
	Write-Host "Finished installing $installer."
}else{
	Write-Host "Starting removal tool for Genesys"
	removeGenesys
	Write-Host "Finished removing Genesys with the $installer."
}

# Exit with a success
Exit 0