<#
TITLE: Disable Internet Explorer Browser Extensions [WIN]
PURPOSE: Script will create a registry key to disable IE browser extensions
CREATOR: Dan Meddock
CREATED: 21MAR2023
LAST UPDATED: 21MAR2023
#>

# Registry Value
$regName = "Enable Browser Extensions"
$regValue = "no"
$regPath = "HKLM:\Software\Policies\Microsoft\Internet Explorer\Main"

Try{
  Write-Host "Applying registry key to disable Internet Explorer Browser Extensions."
  if(!(test-path $regpath)){
	  New-Item -Path $regPath -Force | Out-Null
	  New-ItemProperty $regPath -Name $regName -PropertyType string -value $regValue -Force
  }else{
	  New-ItemProperty $regPath -Name $regName -PropertyType string -value $regValue -Force
  }
  Get-ItemProperty -Path $regPath
  Exit 0
}Catch{
  Write-Error $_.Exception.Message
  Exit 1 
}