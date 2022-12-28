<#
TITLE: Splashtop Audio Settings [WIN]
PURPOSE: Script to output sound both over the remote connection and on this PC in splashtop on the remote computer
CREATOR: Dan Meddock
CREATED: 14MAR2022
LAST UPDATED: 28MAR2022
#>

# Splashtop Registry Value
$splashtop = "0"

# Registry key paths for Splashtop 32 and 64 bit
$RegPaths = @(
   'HKLM:\SOFTWARE\WOW6432Node\Splashtop Inc.\Splashtop Remote Server',
    'HKLM:\SOFTWARE\Splashtop Inc.\Splashtop Remote Server'
)
Try{
	# Checks 32 and 64 bits paths applies value for detected paths
	foreach ($Path in $RegPaths) {
		if (Test-Path $Path) {
			Set-ItemProperty -Path $Path -Name "AutoMute" -Value $splashtop
			Get-ItemProperty -Path $Path
		}
	}

	(net stop SplashtopRemoteService) -and (net start SplashtopRemoteService)
	Exit 0
}Catch{
	Write-Error $_.Exception.Message 
	Exit 1
}