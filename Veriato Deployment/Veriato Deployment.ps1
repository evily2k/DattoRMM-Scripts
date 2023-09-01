<#
TITLE: Veriato Deployment [WIN]
PURPOSE: Installs or uninstalls the Veriato agent silently
CREATOR: Dan Meddock
CREATED: 30AUG2023
LAST UPDATED: 30AUG2023
#>

# Declarations
$tempFolder = "C:\Temp"
$uninstaller = 'uninstall64.exe'
$appUninstaller = "C:\Temp\uninstall64.exe"
$textFile = 'UninstallKey.txt'
$textFileDir = "C:\Temp\UninstallKey.txt"
$veriato = 'VisionInstaller.msi'
$appVeriato = "C:\Temp\VisionInstaller.msi"
$install = $env:install
	
Function installVeriato {
	Try{
		# Check if Temp folder exsists
		If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force | Out-Null}
			
		# Transfer installers to computer
		Write-Host "Transferring installer to device."
		Copy-Item $veriato -Destination $appVeriato -force
		$veriato = $veriato -replace '.msi',''
		
		# Start application install
		Write-Host "Starting install of $veriato."
		Start-process msiexec.exe -argumentlist "/I $appVeriato /qn /L*V C:\temp\VeriatoInstall.log"; sleep 45
		Get-Content -Path "C:\temp\VeriatoInstall.log"

		# Clean up files
		#Remove-Item -Path $appVeriato -Force -ErrorAction SilentlyContinue
		#Remove-Item -Path "C:\temp\VeriatoInstall.log" -Force -ErrorAction SilentlyContinue

	}catch{
		# Catch any errors thrown and exit with an error
		Write-Error $_.Exception.Message
		Exit 1
	}
}

Function removeVeriato {
	Try{
		# Check if Temp folder exsists
		If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force | Out-Null}
			
		# Transfer installers to computer
		Write-Host "Transferring installer to device."
		Copy-Item $uninstaller -Destination $appUninstaller -force
		Copy-Item $textFile -Destination $textFileDir -force
		
		# Start application install
		Write-Host "Starting uninstall of Veriato agent."
		start-process "C:\temp\uninstall64.exe" -argumentlist "/R"; sleep 45
		
		# Clean up files
		Remove-Item -Path $appUninstaller -Force -ErrorAction SilentlyContinue
		Remove-Item -Path $textFileDir -Force -ErrorAction SilentlyContinue
		
	}catch{
		# Catch any errors thrown and exit with an error
		Write-Error $_.Exception.Message
		Exit 1
	}
}

# Main

# Run the installer or the removal tool
if($install -eq "True"){
	Write-Host "Starting install for Veriato"
	installVeriato
	Write-Host "Finished installing $veriato."
}else{
	Write-Host "Starting removal tool for Veriato"
	removeVeriato
	Write-Host "Finished removing Veriato with the $uninstaller."
}

# Exit with a success
Exit 0