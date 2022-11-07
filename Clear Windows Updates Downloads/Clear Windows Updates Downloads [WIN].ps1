<#
TITLE: Clear Windows Updates Downloads [WIN]
PURPOSE: Deletes all contents in the Windows Updates Download directory.
CREATOR: Dan Meddock
CREATED: 07NOV2022
LAST UPDATED: 07NOV2022
#>

# Declarations
$winDownloads = "C:\Windows\SoftwareDistribution\Download\*"

# Main
Try{
	stop-service wuauserv
	Remove-Item $winDownloads -Force -Recurse
	start-service wuauserv
	Exit 0
	
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}