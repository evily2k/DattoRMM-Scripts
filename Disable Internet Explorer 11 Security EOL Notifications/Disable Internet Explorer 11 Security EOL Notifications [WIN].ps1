<#
TITLE: Disable Internet Explorer 11 Security EOL Notifications [WIN]
PURPOSE: Script will create a registry key to disable Internet Explorer 11 Security EOL Notifications
CREATOR: Dan Meddock
CREATED: 21MAR2023
LAST UPDATED: 21MAR2023
#>

# Registry Value
$regName = "iexplore.exe"
$regValue = "1"
$regPath = "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_IE11_SECURITY_EOL_NOTIFICATION"

Try{
	Write-Host "Applying registry key to Redirect Sites From Internet Explorer."
	if(!(test-path $regpath)){
		New-Item -Path $regPath -Force | Out-Null
		New-ItemProperty $regPath -Name $regName -PropertyType dword -value $regValue -Force
	}else{
		New-ItemProperty $regPath -Name $regName -PropertyType dword -value $regValue -Force
	}
	Get-ItemProperty -Path $regPath
	Exit 0
}Catch{
	Write-Error $_.Exception.Message 
	Exit 1
}