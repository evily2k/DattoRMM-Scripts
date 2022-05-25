<#
TITLE: NinjaRMM Remove Remnants [WIN]
PURPOSE: Script to remove any remnants of Ninja. Script will fail if Ninja is actively installed and running
CREATOR: Dan Meddock
CREATED: 14MAR2022
LAST UPDATED: 28MAR2022
#>

# Stop Ninja service
net stop NinjaRMMAgent
$tempFolder = "C:\Temp"

try{
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
	# Delete add/remove program entry
	$regPath = ((gp HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*) | where-object displayname -match "NinjaRMM").PSPath

	# Find and delete Ninja Install directory
	$path = "C:\program Files (x86)"
	$installDir = (gci -path $path -filter "*ninjarmm*" -recurse).directoryname
	if ($installDir){
		&cmd.exe /c rd /s /q $installDir[0]
		if (!(test-path $installDir[0])){
			Write-Host "NinjaRMM Program Files folder found and deleted"
		}else{
			Write-Host "Unable to delete NinjaRMM Directory."
		}
	}else{
		write-host "No NinjaRMM installation directory found."
	}
	$i=1
	foreach ($reg in $regPath){ 
		If(test-path $reg){			
			Write-Host "Ninja Registry key detected. Backing up Registry key."
			$regBack = $reg.Replace("Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE","HKLM")
			reg export $regBack "C:\temp\ninjaUninstall$i.reg"
			Write-Host "Registry key backed up to C:\temp"
			Write-Host "Deleting NinjaRMM Registry Key."
			Write-Host $regBack
			remove-item $reg -force
			$i++			
		}else{
			Write-host "No Ninja Uninstall Key found in the registry. Checking for Program Files."
		}
		If(test-path $reg){
			Write-Host "Uninstall Key detected. Removal failed."
		}
	}
	if(!($regPath)){
		Write-Host "No Registry keys found."
	}
	Exit 0
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}