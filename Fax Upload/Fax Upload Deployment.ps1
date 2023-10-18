<#
TITLE: Fax Upload Deployment [WIN]
PURPOSE: Installs or uninstalls the Fax Upload application silently
CREATOR: Dan Meddock
CREATED: 17OCT2023
LAST UPDATED: 17OCT2023
#>

# Declarations
$tempFolder = "C:\Temp"
$application = 'faxUploadSetup.exe'
$appInstaller = "C:\Temp\faxUploadSetup.exe"
$appSilentInstall = "C:\Temp\faxUploadSetup\_FaxUploadSetup.exe"
$appLink = "https://www1.sea.telecomsvc.com/download/faxUploadSetup.exe"
$7zip = "7z2301-x64.zip"
$7zipPath = $tempFolder + "\" + $7zip
$7zipEXE = ($7zipPath -replace '.zip','') + "\7z.exe"
$install = $env:install

# Main
Function installFaxUpload {
	Try{
		# Fax Upload install check
		$varString = "Fax Upload" 
		$installCheck = ("HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") | % {gci -Path $_ | % {get-itemproperty $_.pspath} | ? {$_.DisplayName -match "$varString"}} 
		
		if ($installCheck -eq $NULL){
			# Check if Temp folder exists.
			If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
			
			# Download the Fax Upload installer from the web to the temp folder.
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
			Write-Host "Downloading Fax Upload installer to computer."
			Invoke-WebRequest -OutFile $appInstaller -uri $appLink

			# Copy 7zip zip file to device and extract to folder.
			Copy-Item $7zip -Destination $7zipPath -force
			Copy-Item "SETUP.INI" -Destination "C:\Temp\SETUP.INI"
			Expand-Archive $7zipPath $tempFolder
			
			# Set directory to C:\temp and use 7zip to extract the EXE file's content.
			Set-Location $tempFolder
			Start-Process $7zipEXE -argumentlist "x $appInstaller -o*" -wait

			# Copy the config file to the device to set the fax number
			$configDir = $appInstaller -replace '.exe',''
			$configFile = $configDir + "\SETUP.INI"
			Remove-Item $configFile -Force
			Copy-Item "C:\temp\SETUP.INI" -Destination $configFile -force

			# Run the internal EXE file (that was extracted from the original EXE) silently.
			Write-Host "Starting Fax Upload install."
			Set-Location "C:\temp\faxUploadSetup"
			Start-Process $appSilentInstall -argumentlist "/s" -wait
			
			# Clean up files and folders that are no longer in use.
			Write-Host "Install completed. Cleaning up files and folders."	
			Remove-Item $appInstaller -Force
			$appInstaller = $appInstaller -replace '.exe',''
			Remove-Item $appInstaller -Force -Recurse
			Remove-Item $7zipPath -Force
			$7zipPath = $7zipPath -replace '.zip',''
			Remove-Item $7zipPath -Force -Recurse
			Remove-Item "C:\temp\SETUP.INI" -Force
			
		}else{
			Write-Host "Fax Upload is already installed. Exitting script."
		}
	}catch{
		# Catch any errors thrown and exit with an error
		Write-Error $_.Exception.Message
	}
}

Function removeFaxUpload {
	Try{
		# Transfer installers to computer
		Write-Host "Starting Fax Upload removal now."
		start-process "C:\Program Files\Fax Upload\_FaxUploadSetup.exe" -argumentlist "-s -UC:\Program Files\Fax Upload"
			
	}catch{
		# Catch any errors thrown and exit with an error
		Write-Error $_.Exception.Message
	}
}

# Run the installer or the removal tool
if($install -eq "True"){
	Write-Host "Starting install for Fax Upload"
	installFaxUpload
	Write-Host "Finished installing Fax Upload."
}else{
	Write-Host "Starting removal tool for Fax Upload"
	removeFaxUpload
	Write-Host "Finished removing Fax Upload."
}
# Exit with a success

Exit 0