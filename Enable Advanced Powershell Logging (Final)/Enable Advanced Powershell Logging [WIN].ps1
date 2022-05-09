<#
TITLE: Enable Advanced Powershell Logging [WIN]
PURPOSE: Enables Powershell module logging, script block logging, and transcript logging.
CREATOR: Dan Meddock
CREATED: 14FEB2022
LAST UPDATED: 09MAY2022
#>

# Declarations
# PS Enable module logging function
function Enable-PSScriptModuleLogging
{
    $basePath = 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging',
	'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames'

	foreach ($regPath in $basePath){
		if(-not (Test-Path $regPath))
		{
			$null = New-Item $regPath -Force
		}
	}
	Set-ItemProperty $basePath[0] -Name EnableModuleLogging -Value "1"
	Set-ItemProperty $basePath[1] -Name * -Value "*"
}

# PS Enable Script block logging function
function Enable-PSScriptBlockLogging
{
    $basePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging',
	'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'

	foreach ($regPath in $basePath){
		if(-not (Test-Path $regPath))
		{
			$null = New-Item $regPath -Force
		}
		Set-ItemProperty $regPath -Name EnableScriptBlockLogging -Value "1"
	}    
}

# PS Enable transcript logging function
function Enable-PSScriptTranscriptionLogging
{
    $basePath = 'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription',
	'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription',
	'HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\Transcription'

	foreach ($regPath in $basePath){
		if(-not (Test-Path $regPath))
		{
			$null = New-Item $regPath -Force
		}		
	}
	Set-ItemProperty $basePath[0] -Name EnableTranscripting -Value "1"
	Set-ItemProperty $basePath[1] -Name EnableInvocationHeader -Value "1"
	Set-ItemProperty $basePath[2] -Name OutputDirectory -Value "C:\temp\PSlogging"
}

# PS Enable PS Script Logging Cleanup function
function Enable-PSscriptLoggingCleanup
{
	# Path for the PS logging files
	$PSLoggingFolder = "C:\temp\PSLogging"

	# Check if Temp folder exsists and copy wallpaper to device
	If(!(test-path $PSLoggingFolder -PathType Leaf)){new-item $PSLoggingFolder -ItemType Directory -force}

	#Creates a scheduled task to delete log files older than 30 days from C:\temp\PSLogging
	$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& {Get-ChildItem C:\Temp\PSlogging -Directory -force -ea 0 | ? {($_.LastWriteTime -lt (Get-Date).AddDays(-30)) -and ($_.Name -match ''^[0-9]+$'') -and ($_.Name -match ''\d{8}'')} | ForEach-Object { $_ | del -Force -Recurse; $_.FullName | Out-File C:\Temp\PSlogging\deletedlog.txt -Append}}"'

	# Register and run scheduled task every day at 9AM
	$trigger =  New-ScheduledTaskTrigger -Daily -At 9am
	Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PSLogCleanup" -Description "Cleans up old Powershell Advanced logging files." -User "System"
}

# Check for existing task and delete if exists
function Get-PSAdvLoggingScheduledTask
{
	if (Get-ScheduledTask -TaskName "PSLogCleanup"){Unregister-ScheduledTask -TaskName "PSLogCleanup" -Confirm:$false}
}

# Main
Try{

	Write-Host "Checking for PS Logging scheduled task and deleting it if found."
	Get-PSAdvLoggingScheduledTask

	Write-Host "Creating Log file directory and autocleanup scheduled task."
	Enable-PSscriptLoggingCleanup

	Write-Host "Enabling Powershell module logging."
	Enable-PSScriptModuleLogging

	Write-Host "Enabling Powershell script block logging."
	Enable-PSScriptBlockLogging

	Write-Host "Enabling Powershell script transcript logging."
	Enable-PSScriptTranscriptionLogging

	Exit 0
	
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}