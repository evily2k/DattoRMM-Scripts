<#
TITLE: M-Files Complete Uninstall [WIN]
PURPOSE: Script to uninstall the M-Files application
CREATOR: Dan Meddock
CREATED: 14MAR2022
LAST UPDATED: 28MAR2022
#>

$softwareN = "M-Files"

try{
	$uninstall = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\,
	HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ | 
		 Get-ItemProperty |         
			Where-Object {$_.DisplayName -match $softwareN } |
				Select-Object -Property DisplayName, UninstallString, DisplayVersion

	Foreach ($app in $uninstall){
		if ($app) {
		$appName = $app.DisplayName
		$appVersion = $app.DisplayVersion
		$app = $app.UninstallString -Replace "msiexec.exe","" -Replace "/I","" -Replace "/X",""
		$app = $app.Trim()
		Write-Host "Uninstalling $appName $appVersion"
		start-process "msiexec.exe" -arg "/X $app /qn" -Wait
		}else{
			Write-Host "No uninstall strings found."
			Exit 1
		}
	}
	Exit 0
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}