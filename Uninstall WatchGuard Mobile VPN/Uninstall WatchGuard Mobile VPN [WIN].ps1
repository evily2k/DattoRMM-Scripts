<#
TITLE: Uninstall WatchGuard Mobile VPN
PURPOSE: Removes WatchGuard Mobile VPN and WatchGuard Authentication Client
CREATOR: Dan Meddock
CREATED: 25APR2023
LAST UPDATED: 25APR2023
#>

$application = @(
	'WatchGuard Mobile',
	'WatchGuard Authentication Client'
)
# Registry paths
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)

# Search for all aplications in the registry and force an uninstall
foreach ($Path in $RegUninstallPaths) {
	if (Test-Path $Path) {
		foreach ($app in $application){
			$UninstallSearchFilter = {($_.GetValue('DisplayName') -match $app) -and ($VersionsToKeep -notcontains $_.GetValue('DisplayName'))}
			Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
			foreach { 
				$appName = $_.GetValue('DisplayName')
				$uninstallString = $_.GetValue('UninstallString')
				$appVersion = $_.GetValue('DisplayVersion')
				
				# Check if uninstall string uses MSIEXEC
				if($uninstallString -match "msiexec"){
					$appRemove = $uninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
					$appRemove = $appRemove.Trim()
					# Save reg key
					$regkey = $appRemove
					Write-Host "Uninstalling $appName $appVersion"
					start-process "msiexec.exe" -arg "/X $appRemove /qn" -Wait 
				}
				
				# Checks if uninstall string is an EXE
				if($uninstallString -match "unins000*"){
					$appRemove = $uninstallString -Replace "`"",""
					$appRemove = $appRemove.Trim()
					$appRemove = '"{0}"' -f $appRemove
					Write-Host "Uninstalling $appName $appVersion"
					start-process $appRemove -arg "/SILENT" -Wait
				}
			}
		}
	}
}