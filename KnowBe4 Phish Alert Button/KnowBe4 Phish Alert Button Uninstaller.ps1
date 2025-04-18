<#
TITLE: Uninstalls the KnowBe4 Phish Alert Button [WIN]
PURPOSE: A removal script to uninstall KnowBe4 Phish Alert Button
CREATOR: Dan Meddock
CREATED: 03NOV2023
LAST UPDATED: 03NOV2023
#>

# Declarations
$softwareN = "KnowBe4 Phish Alert Button"

# Main
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