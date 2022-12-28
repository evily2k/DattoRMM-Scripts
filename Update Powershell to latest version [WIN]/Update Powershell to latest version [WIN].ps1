<#
TITLE: Update Powershell to latest version [WIN]
PURPOSE: Uses Chocolatey to update powershell to the latest version (5.1). Installs and updates Chocolatey; Creates scheduled task to update chocolatey packages.
CREATOR: Dan Meddock
CREATED: 02MAR2022
LAST UPDATED: 28MAR2022
#>

#Install Chocolatey
try {
	[Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)
} catch [system.exception] {
	write-host "- ERROR: Could not implement TLS 1.2 Support."
	write-host "  This can occur on Windows 7 devices lacking Service Pack 1."
	write-host "  Please install that before proceeding."
	exit 1
}

try {
	write-host "Setting up Chocolatey software package manager"
	New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT

	Get-PackageProvider -Name chocolatey -Force

	write-host "Setting up Full Chocolatey Install"
	Install-Package -Name Chocolatey -Force -ProviderName chocolatey
	$chocopath = (Get-Package chocolatey | 
				?{$_.Name -eq "chocolatey"} | 
					Select @{N="Source";E={((($a=($_.Source -split "\\"))[0..($a.length - 2)]) -join "\"),"Tools\chocolateyInstall" -join "\"}} | 
						Select -ExpandProperty Source)
	& $chocopath "upgrade all -y"
	choco install chocolatey-core.extension --force

	write-host "Creating daily task to automatically upgrade Chocolatey packages"
	# adapted from https://blogs.technet.microsoft.com/heyscriptingguy/2013/11/23/using-scheduled-tasks-and-scheduled-jobs-in-powershell/
	$ScheduledJob = @{
		Name = "Chocolatey Daily Upgrade"
		ScriptBlock = {choco upgrade all -y}
		Trigger = New-JobTrigger -Daily -at 2am
		ScheduledJobOption = New-ScheduledJobOption -RunElevated -MultipleInstancePolicy StopExisting -RequireNetwork
	}
	Register-ScheduledJob @ScheduledJob
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}

#Update Powershell
try{
	$ErrorActionPreference = "silentlycontinue"

	$PSVersionTable.PSVersion
	write-host "Attempting to update Powershell version now."
	choco install powershell -y
	choco upgrade powershell -y

	$ErrorActionPreference = "continue"
	Exit 0
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}