<#
TITLE: Disable IE AutoFill Form [WIN]
PURPOSE: Script to disable the autofill feature in IE
CREATOR: Dan Meddock
CREATED: 14MAR2022
LAST UPDATED: 27APR2022
#>

# Registry Value
$regName = "Use FormSuggest"
$regValue = "no"
$regPath = "HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main"

Try{
	Write-Host "Applying registry key to disable autoFormComplete in IE."
	New-ItemProperty $regPath -Name $regName -PropertyType string -value $regValue -Force
	Get-ItemProperty -Path $regPath
	Exit 0
}Catch{
	Write-Error $_.Exception.Message 
	Exit 1
}