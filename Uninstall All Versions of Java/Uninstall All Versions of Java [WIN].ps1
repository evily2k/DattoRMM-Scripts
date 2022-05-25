<#
TITLE: Uninstall All Versions of Java [WIN]
PURPOSE: Uninstall unwanted Java versions and clean up program files
CREATOR: Dan Meddock
CREATED: 14MAR2022
LAST UPDATED: 28MAR2022
#>

# Declarations 
# Registry paths
$RegUninstallPaths = @(
   'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
)
$ClassesRootPath = "HKCR:\Installer\Products"
$JavaSoftPath = 'HKLM:\SOFTWARE\JavaSoft'

# Search for Java in the registry and Force an Uninstall
$UninstallSearchFilter = {($_.GetValue('DisplayName') -like '*Java*') -and (($_.GetValue('Publisher') -eq 'Oracle Corporation')) -and ($VersionsToKeep -notcontains $_.GetValue('DisplayName'))}

# Java version to keep (Uncomment line to enable)
#$VersionsToKeep = @('Java 8 Update 261')

# Main
Try{
	# Find and stop all running processes
	Get-CimInstance -ClassName 'Win32_Process' | Where-Object {$_.ExecutablePath -like '*Program Files\Java*'} | Select-Object @{n='Name';e={$_.Name.Split('.')[0]}} | Stop-Process -Force 
	Get-process -Name *iexplore* | Stop-Process -Force -ErrorAction SilentlyContinue
	
	# Uninstalls all versions of Java that were found
	foreach ($Path in $RegUninstallPaths) {
		if (Test-Path $Path) {
			Get-ChildItem $Path | Where-Object $UninstallSearchFilter | 
		   foreach { 
				$appName = $_.GetValue('DisplayName')
				write-host "Uninstalling $appName"
				Start-Process 'C:\Windows\System32\msiexec.exe' "/X$($_.PSChildName) /qn" -Wait    
			}
		}
	}
	# Remove Java remnants
	New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
	Get-ChildItem $ClassesRootPath | 
		Where-Object { ($_.GetValue('ProductName') -like '*Java*')} | Foreach {
		Remove-Item $_.PsPath -Force -Recurse
		write-host "Detected registry key $_.PsPath and removing key."
		$appName = $_.GetValue('DisplayName')
		write-host "Removing remnant registry keys for $appName"
	}
	# Remove Java remnants
	if (Test-Path $JavaSoftPath) {
		Remove-Item $JavaSoftPath -Force -Recurse
		write-host "Detected registry key $_.PsPath and removing key."
		$appName = $_.GetValue('DisplayName')
		write-host "Removing remnant registry keys for $appName"
	}
	Exit 0
}Catch{
	Write-Error $_.Exception.Message 
	Exit 1
}