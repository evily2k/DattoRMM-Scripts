<#
TITLE: Disable Chrome Notifications [WIN]
PURPOSE: Applies a registry key to disable Chrome notifications in Windows
CREATOR: Dan Meddock
CREATED: 17DEC2021
LAST UPDATED: 28MAR2022
#>
# Main
Try{
# Disable Chrome Notifications
  if ((Test-Path -LiteralPath "Registry::\HKEY_CURRENT_USER\Software\Policies\Google\Chrome") -ne $true) {
  New-Item "Registry::\HKEY_CURRENT_USER\Software\Policies\Google\Chrome" -force -ea SilentlyContinue
  };
  New-ItemProperty -LiteralPath 'Registry::\HKEY_CURRENT_USER\Software\Policies\Google\Chrome' -Name 'DefaultNotificationsSetting' -Value '2' -PropertyType DWord
}Catch{
  Write-Host $($_.Exception.Message)
}