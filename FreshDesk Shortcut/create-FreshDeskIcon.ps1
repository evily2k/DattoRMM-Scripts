<#
TITLE: create-FreshDeskIcon
Datto Component: Creates a shortcut on Pulic Desktop for FreshDesk
PURPOSE: Adds a desktop shortcut to the FreshDesk URL
CREATOR: Dan Meddock
CREATED: 15FEB2023
LAST UPDATED: 15FEB2023
#>

# Log create-FreshDeskIcon output to log file
Start-Transcript -Path "C:\temp\createFreshDeskIcon.log"

# Declarations

# Set shortcut icon, shortcut path, path to application, start menu path variables
$appIcon = "C:\Temp\favicon.ico"
$appPath = "https://luminate.feshdesk.com"
$scPath = "C:\Users\Public\Desktop\FreshDesk.lnk"
$smPath = "C:\Users\All Users\Start Menu\FreshDesk.lnk"

# Main
Try{
	# Create Shortcut for application
	$WshShell = New-Object -comObject WScript.Shell
	$Shortcut = $WshShell.CreateShortcut($scPath)
	$Shortcut.TargetPath = $appPath
	$Shortcut.IconLocation = $appIcon
	$Shortcut.Save()

	# Make shortcut run as admin
	$bytes = [System.IO.File]::ReadAllBytes($scPath)
	$bytes[0x15] = $bytes[0x15] -bor 0x20
	[System.IO.File]::WriteAllBytes($scPath, $bytes)

	# Makes Start menu entry
	cp $scPath $smPath

	# Create Shortcut for application - oneliner
	$Wsh = New-Object -comObject WScript.Shell;$sc = $Wsh.CreateShortcut($scPath);$sc.TargetPath = $appPath;$sc.Save()
	
}Catch{
	# Catch any powershell errors and output the error message
	Write-Error $_.Exception.Message	
	# Stop transcript logging
	Stop-Transcript
	Exit 1
}
# Stop transcript logging
Stop-Transcript
Exit 0