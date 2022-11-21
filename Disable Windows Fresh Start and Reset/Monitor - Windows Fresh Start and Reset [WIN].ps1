<#
TITLE: Monitor: Disable Windows Fresh Start and Reset [WIN]
PURPOSE: Monitor to check if the registry key has been created to disable fresh start and reset
CREATOR: Dan Meddock
CREATED: 21NOV2022
LAST UPDATED: 21NOV2022
#>

# Declarations
$regFullPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\systemreset.exe"

# Main
if (test-path $regFullPath){
		write-host '<-Start Result->'
		write-host "Disabled"
		write-host '<-End Result->'
		Exit 0
}else{
		write-host '<-Start Result->'
		write-host "Enabled"
		write-host '<-End Result->'
		Exit 1
}
