<#
TITLE: Install-ElevateUC [WIN]
PURPOSE: This script will kill all Elevate UC processes. Uninstalls Elevate if it's installed in AppData. Then it downloads the latest Elevate UC application. Once downloaded it will start the Elevate UC install silently. After the install it adds a shortcut to the desktop and start menu.
CREATOR: Dan Meddock
CREATED: 05APR2023
LAST UPDATED: 02JUL2023
#>

# Declarations
$workingDir = "C:\Temp"
$downloadURL = "https://cp.serverdata.net/voice/pbx/softphonereleases/default/latest-win/elevate-uc-x64.msi"
$elevateInstaller = "C:\temp\elevate-uc-x64.msi"

# Main
try{
	
	# Kill all Elevate UC processes before starting update/install process
	taskkill /IM "Elevate UC.exe" /F
	
	# Clean up old install files
	If (test-path $elevateInstaller){Remove-Item -Path $elevateInstaller -Force}
	
	# Check for Elevate UC installed in User AppData and uninstall if found.
	$users = Get-ChildItem C:\Users 
	foreach ($user in $users){
		$appDataDir = "$($user.fullname)\AppData\Local\Programs\Elevate UC\"
		$programFilesDir = "C:\Program Files\Elevate UC\Uninstall Elevate UC.exe"
		if(test-path $appDataDir){
			# Attempts to uninstall Elevate from the appdata directory
			Write-Host "Found appdata install for $user."
			Write-Host "Attempting to uninstall Elevate UC from user directory."
			Start-Process "$appDataDir\Uninstall Elevate UC.exe" -argumentlist "/S" -wait
		}
		if(test-path $programFilesDir){
			# Attempts to uninstall Elevate from the Program Files directory
			Write-Host "Found Program Files install for $user."
			Write-Host "Attempting to uninstall Elevate UC from Program Files directory."
			Start-Process $programFilesDir -argumentlist "/allusers /S" -wait
		}
	}
	
	# Check if Temp folder exists; if not create it
	If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force | Out-Null}

	# Download the Elevate UC latest MSI installer
	Invoke-WebRequest -OutFile $elevateInstaller -uri $downloadURL
	
	# Start Elevate UC application install silently
	Write-Host "Updating/Installing latest version of Elevate UC."
	Start-Process msiexec -argumentlist "/I $elevateInstaller /qn" -wait
	
	# Set shortcut path, path to application, start menu path
	Write-Host "Creating Desktop shortcut and Start Menu shortcut."
	$appPath = '"C:\Program Files\Elevate UC\Elevate UC.exe"'
	$scPath = "C:\Users\Public\Desktop\Elevate UC.lnk"
	$smPath = "C:\Users\All Users\Start Menu\Elevate UC.lnk"

	# Create Shortcut for application on Desktop and Start Menu
	$WshShell = New-Object -comObject WScript.Shell
	$Shortcut = $WshShell.CreateShortcut($scPath)
	$Shortcut.TargetPath = $appPath
	$Shortcut.Arguments = "-show"
	$Shortcut.Save()
	
}catch{
	# Output any errors that are generated
	Write-Error $_.Exception.Message
}
# Exit with a success
Exit 0