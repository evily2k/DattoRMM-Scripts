# Enables Powershell module logging, script block logging, and transcript logging.
# PS Enable module logging
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

# PS Enable Script block logging
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

# PS Enable transcript logging
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
	Set-ItemProperty $basePath[2] -Name OutputDirectory -Value "C:\temp"
}

# Main
Try{
	Enable-PSScriptModuleLogging
	Enable-PSScriptBlockLogging
	Enable-PSScriptTranscriptionLogging
	
	#Creates a scheduled task to delete log files older than 7 days from C:\temp
	$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -WindowStyle Hidden -command "& {Get-ChildItem C:\Temp -Directory -force -ea 0 | ? {($_.LastWriteTime -lt (Get-Date).AddDays(-30)) -and ($_.Name -match ''^[0-9]+$'') -and ($_.Name -match ''\d{8}'')} | ForEach-Object { $_ | del -Force -Recurse; $_.FullName | Out-File C:\Temp\deletedlog.txt -Append}}"'
	$trigger =  New-ScheduledTaskTrigger -Daily -At 9am
	Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "PSLogCleanup" -Description "Cleans up old Powershell  Advanced logging files." -User "System"
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}