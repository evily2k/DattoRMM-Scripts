<#
TITLE: Teramind Deployment [WIN]
PURPOSE: Installs or uninstalls the Teramind application silently
CREATOR: Dan Meddock
CREATED: 28JUL2023
LAST UPDATED: 03AUG2023
#>

# Declarations
$tempFolder = "C:\Temp"
$application = 'teramind_agent_x64_s.msi'
$removalTool = 'teramind-remover.exe'
$appInstaller = "C:\temp\teramind_agent_x64_s.msi"
$removalToolDir = "C:\temp\teramind-remover.exe"
$install = $env:install
	
# Main
Function installTeramind {
	Try{
		# Check if Temp folder exists
		If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force | Out-Null}
			
		# Transfer installers to computer
		Write-Host "Transferring installer to device."
		Copy-Item $application -Destination $appInstaller -force
		$application = $application -replace '.msi',''
		
		# Start application install
		Write-Host "Starting install of $application."
		Start-process msiexec.exe -argumentlist "/I $appInstaller /qn"; sleep 30
			
	}catch{
		# Catch any errors thrown and exit with an error
		Write-Error $_.Exception.Message
	}
}

Function removeTeramind {
	Try{
		# Check if Temp folder exsists
		If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force | Out-Null}
			
		# Transfer installers to computer
		Write-Host "Transferring removal tool to device."
		Copy-Item $removalTool -Destination $removalToolDir -force
		$removalTool = $removalTool -replace '.exe',''
		
		# Start application install
		Write-Host "Starting the $removalTool tool."
		Start-process $removalToolDir -argumentlist "/silent"; sleep 30
		
		# Check if install directory has been deleted
		$a = 0
		if(test-path "C:\ProgramData\{4CEC2908-5CE4-48F0-A717-8FC833D8017A}"){
			Write-Host "Installation directory detected still. Teramind removal may be incomplete."
			$a++
		}else{
			Write-Host "Installation directory was removed successfully."
		}
		
		# Check if service still exists
		if(Get-Service tsvchst -erroraction silentlycontinue){
			Write-Host "Teramind service detected. Teramind removal may be incomplete."
			(Get-Service tsvchst).status
			$a++
		}else{
			Write-Host "Teramind service was removed successfully."
		}
		
		# If directory or service exist still then exit with an error
		if($a -ge 1){
			Write-Host "One or more of Teramind's components failed to remove. Please investigate."
			Exit 1
		}
			
	}catch{
		# Catch any errors thrown and exit with an error
		Write-Error $_.Exception.Message
	}
}

# Run the installer or the removal tool
if($install -eq "True"){
	Write-Host "Starting install for Teramind"
	installTeramind
	Write-Host "Finished installing $application."
}else{
	Write-Host "Starting removal tool for Teramind"
	removeTeramind
	Write-Host "Finished removing Teramind with the $removalTool."
}
# Exit with a success

Exit 0