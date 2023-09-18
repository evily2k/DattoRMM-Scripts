<#
TITLE: Uninstall Radmin [WIN]
PURPOSE: Uninstalls the Radmin silently
CREATOR: Dan Meddock
CREATED: 15SEP2023
LAST UPDATED: 15SEP2023
#>

try{
	$application = @(
		'Radmin',
		'teamviewer',
		'ultravnc'
	)
	# Registry paths
	$RegUninstallPaths = @(
	   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
		'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
	)
	foreach ($app in $application){
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
						if($uninstallString -match "uninstall*"){
							$appRemove = $uninstallString -Replace "`"",""
							$appRemove = $appRemove.Trim()
							$appRemove = '"{0}"' -f $appRemove
							Write-Host "Uninstalling $appName $appVersion"
							start-process $appRemove -arg "/S" -Wait
						}
					}
				}
			}
		}
	}
}catch{
    $err = $_.Exception.Message
    Write-Output $err | timestamp
}