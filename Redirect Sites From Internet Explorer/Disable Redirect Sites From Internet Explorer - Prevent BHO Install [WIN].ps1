<#
TITLE: Redirect Sites From Internet Explorer - Prevent BHO Install [WIN]
PURPOSE: Script will create a registry key to disable Redirect Sites From Internet Explorer
CREATOR: Dan Meddock
CREATED: 21MAR2023
LAST UPDATED: 21MAR2023
#>

# Registry Value
$regName = "RedirectSitesFromInternetExplorerPreventBHOInstall"
$regValue = "1"
$regPath = "HKLM:\Software\Policies\Microsoft\Edge"

Try{
	Write-Host "Applying registry key to Disable Redirect Sites From Internet Explorer."
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