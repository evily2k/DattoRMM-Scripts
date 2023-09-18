$appCount = 0
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

# Search for all aplications in the registry and force an uninstall
foreach ($Path in $RegUninstallPaths) {
	if (Test-Path $Path) {
		foreach ($app in $application){
			$UninstallSearchFilter = {($_.GetValue('DisplayName') -match $app) -and ($VersionsToKeep -notcontains $_.GetValue('DisplayName'))}
			$test = Get-ChildItem $Path | Where-Object $UninstallSearchFilter
			if($test -ne $NULL){
				$appCount++
			}
		}
	}
}			
			
if ($appCount -eq 0){
	write-host '<-Start Result->'
	write-host "STATUS=Undetected"
	write-host '<-End Result->'
	#exit 0
}else{
	write-host '<-Start Result->'
	write-host "STATUS=Detected"
	write-host '<-End Result->'			
	#exit 1
}