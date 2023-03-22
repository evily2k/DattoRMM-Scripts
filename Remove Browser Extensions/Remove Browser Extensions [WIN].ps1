<#
TITLE: remove-BrowserExtension
PURPOSE: Disable and block installs of specific browser extentions
CREATOR: Dan Meddock
CREATED: 07MAR2023
LAST UPDATED: 07MAR2023
#>

function remove-BrowserExtension {
	param (
		[Parameter (Mandatory)]
		[String]$browser,
		[Parameter (Mandatory)]
		[String]$extensionId
	)
	
	Write-Host "Browser = $browser"
	Write-Host "ExtensionID = $extensionID `n"
	
	# Set the Browser for extension removal
	if($browser -eq "Chrome"){$browserReg = "Google\Chrome"}
	if($browser -eq "Edge"){$browserReg = "Microsoft\Edge"}
	
	# Regkeys to add extension to blocklist and remove from force install list
	$regKey = "HKLM:\SOFTWARE\Policies\$browserReg\ExtensionInstallBlocklist"
	$regKeyInstall = "HKLM:\SOFTWARE\Policies\$browserReg\ExtensionInstallForcelist"
	
	# Check for blocklist regkey and create if missing
	if(!(Test-Path $regKey)){
		New-Item $regKey -Force
		Write-Host "Created Reg Key $regKey"
	}
	# Add extension to blocklist
	$extensionsList = New-Object System.Collections.ArrayList
	$number = 0
	$noMore = 0
	Write-Host "Checking $browser's blocklist for extension"
	do{
		$number++
		try{
			$install = Get-ItemProperty $regKey -name $number -ErrorAction Stop
			$extensionObj = [PSCustomObject]@{
				Name = $number
				Value = $install.$number
			}
			$extensionsList.add($extensionObj) | Out-Null
			Write-Host "$browser extension blocklist detected : $($extensionObj.name) / $($extensionObj.value)"
		}catch{
			$noMore = 1
		}
	}until($noMore -eq 1)
	$extensionCheck = $extensionsList | Where-Object {$_.Value -eq $extensionId}
	if($extensionCheck){
		Write-Host "$browser extension already blocked."
	}else{
		$newExtensionId = $extensionsList[-1].name + 1
		New-ItemProperty $regKey -PropertyType String -Name $newExtensionId -Value $extensionId
		Write-Host "Added Extension to $browser's blocked extensions list."
	}
	
	# Check for Forcelist regkey for extension
	if (Test-Path $regKeyInstall) {
		$extensionId = $extensionId, ";https://clients2.google.com/service/update2/crx" -join ""
		$extensionsInstallList = New-Object System.Collections.ArrayList
		$number = 0
		$noMore = 0
		Write-Host "Checking $browser's Extension Force Install List for extension"
		do {
			$number++
			try {
				$install = Get-ItemProperty $regKeyInstall -name $number -ErrorAction Stop
				$extensionObj = [PSCustomObject]@{
					Name  = $number
					Value = $install.$number
				}
				$extensionsInstallList.add($extensionObj) | Out-Null
				Write-Host "$browser extension detected : $($extensionObj.name) / $($extensionObj.value)"
			}catch {
				$noMore = 1
			}
		}until($noMore -eq 1)
		$extensionCheck = $extensionsInstallList | Where-Object { $_.Value -eq $extensionId }
		# Remove extension from the force install list
		if ($extensionCheck) {
			Write-Host "Removing $browser extension from the force install extension list."
			Remove-ItemProperty $regKeyInstall -Name $extensionCheck.name -Force
		}
	}
}

remove-BrowserExtension -browser $env:browserName -extensionID $env:extensionID