<#
TITLE: Enabling Microsoft Defender [WIN]
PURPOSE: Attempts to enable MS Defender
CREATOR: Dan Meddock
CREATED: 31AUG2022
LAST UPDATED: 31AUG2022
#>

# Main
Try{
	Set-MpPreference -DisableRealtimeMonitoring $false
	Set-MpPreference -DisableIOAVProtection $false
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "Real-Time Protection" -Force
	New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableBehaviorMonitoring" -Value 0 -PropertyType DWORD -Force
	New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableOnAccessProtection" -Value 0 -PropertyType DWORD -Force
	New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableScanOnRealtimeEnable" -Value 0 -PropertyType DWORD -Force
	New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 0 -PropertyType DWORD -Force
	start-service WinDefend
	start-service WdNisSvc

	Exit 0
	
# Catch any errors thrown and exit with an error
}catch{
	Write-Error $_.Exception.Message 
}