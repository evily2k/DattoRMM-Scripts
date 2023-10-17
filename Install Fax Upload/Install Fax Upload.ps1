<#
TITLE: Install Fax Upload Client [WIN]
PURPOSE: Installs the Fax Upload Software for Windows
CREATOR: Dan Meddock
CREATED: 16OCT2023
LAST UPDATED: 16OCT2023
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

# Main

Try {
	# Check if Temp folder exists
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
	
	# Download the Fax Upload installer from the web to the temp folder
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Write-Host "Downloading Fax Upload installer to computer."
	Invoke-WebRequest -OutFile $appInstaller -uri $appLink

	# Copy 7zip zip file to device and extract to folder
	Copy-Item $7zip -Destination $7zipPath -force
	Expand-Archive $7zipPath $tempFolder
	
	# Set directory to C:\temp and use 7zip to extract the EXE file's content
	Set-Location $tempFolder
	Start-Process $7zipEXE -argumentlist "x $appInstaller -o*" -wait -nonewwindow
		
	# Run the extracted EXE file silent to install Fax Upload
	Write-Host "Starting Fax Upload install."
	start-process $appSilentInstall -argumentlist "/s" -wait -nonewwindow
	
	# Clean up files and folders that are no longer in use
	Write-Host "Install completed. Cleaning up files and folders."	
	Remove-Item $appInstaller -Force
	$appInstaller = $appInstaller -replace '.exe',''
	Remove-Item $appInstaller -Force -Recurse
	Remove-Item $7zipPath -Force
	$7zipPath = $7zipPath -replace '.zip',''
	Remove-Item $7zipPath -Force -Recurse

}Catch{
	Write-Host $($_.Exception.Message)
	Exit 1
}

Exit 0