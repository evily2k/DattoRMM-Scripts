<#
TITLE: Disable Windows Fresh Start and Reset [WIN]
PURPOSE: The script will create a new registry key to disable Windows Fresh Start and Reset button
CREATOR: Dan Meddock
CREATED: 16NOV2022
LAST UPDATED: 21NOV2022
#>

# Declarations
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
$regBackup = "C:\temp\disableFreshStart.reg"
$regFullPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\systemreset.exe"

# Main
Try{
	# Removes option to "Reset this PC" from Advanced Startup
	Write-Host "Disabling Microsoft Windows Recovery Agent."
	reagentc.exe /disable
	
	# Disable Chrome Notifications
	if ((test-path $regFullPath) -ne $true) {
		Write-Host "Creating new Registry entry to disable the system reset."
		New-Item $regFullPath -force -ea SilentlyContinue
	}
	
	# Set the value of Debugger to some arbitrary value so the "Get Started" option does nothing when clicked
	Write-Host "Adding Registry value to disable Windows Fresh Start and Reset."
	New-ItemProperty -LiteralPath $regFullPath -Name 'Debugger' -PropertyType String -Value "c:\Durp\AWCOSaysNo.durp"
	Write-Host "Windows Fresh Start and Reset option has been disabled."
	Exit 0
}Catch{
  Write-Host $($_.Exception.Message)
  Exit 1
}