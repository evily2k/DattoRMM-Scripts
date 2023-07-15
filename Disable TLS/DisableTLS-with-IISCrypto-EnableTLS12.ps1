<#
TITLE: DisableTLS-with-IISCrypto-EnableTLS12 [WIN]
PURPOSE: This script will disable TLS 1.0 and TLS 1.1 and enables TLS 1.2 and disables all the weak ciphers. Use IISCrypto CLI tool and custom template.
CREATOR: Dan Meddock
CREATED: 11JUL2023
LAST UPDATED: 12JUL2023
#>

# Declarations

$ChangeTLS = $env:ChangeTLS
$Reboot = $env:Reboot
#$DisableTLS = "True"
$tempFolder = "C:\Temp"
$IISCryptoZip = "IISCrypto.zip"
$IISCryptoCLI = "IISCryptoCli.exe"
$date = Get-Date -Format "yyyy-MM-dd"
$tls12Enabled = Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Name 'Enabled' -ErrorAction SilentlyContinue

# Functions

Function checkTLS {
	Try{
		# set variable to false
		$protocolEnabled = $false

		# Check if TLS 1.0 is enabled
		$protocols = [System.Net.ServicePointManager]::SecurityProtocol

		# TLS 1.0 is enabled if the SecurityProtocol contains Tls or Tls11
		If ($protocols -band [System.Net.SecurityProtocolType]::Tls -or
			$protocols -band [System.Net.SecurityProtocolType]::Tls11) {
			$protocolEnabled = $true
		}

		# Output the result
		If ($protocolEnabled) {
			Write-Host "TLS 1.0 is enabled."
			Exit 1
		} Else {
			Write-Host "TLS 1.0 is not enabled."
			If ($tls12Enabled -eq 1) {
				Write-Host "TLS 1.2 is enabled."
			} Else {
				Write-Host "TLS 1.2 is not enabled."
				Exit 1
			}
			Exit 0
		}
	}Catch{
		Write-Error "An error occurred: $($_.Exception.Message)"
	}
}

Function changeTLS {
	param([Parameter (Mandatory=$true)] [int32] $templateType)
	
	Try{
		# Switch to select the template to use for TLS settings
		switch ($templateType){
			1{$template = "Disable-TLS10andTLS11-Enables-TLS12.ictpl"}
			2{$template = "Reset-Server-Defaults.ictpl"}
		}

		# Check if Temp folder exsists and if not create item
		If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force | Out-Null}
		
		# Clean up old installation files left over from a previous deployment
		If (Test-Path "C:\temp\IISCrypto"){
			Write-Host "Detected previous install files. Deleting files and then downloading new one."
			Remove-Item -Path "C:\temp\IISCrypto.zip" -Force -ErrorAction SilentlyContinue
			Remove-Item -Path "C:\temp\IISCrypto" -Recurse -Force -ErrorAction SilentlyContinue
		}
		
		# Copy installer to device
		Write-Host "Transferring IIS Crypto tool to device."
		Copy-Item $IISCryptoZip -Destination $tempFolder -force
		
		# Extract zip folder contents
		Write-Host "Extracting IIS Crypto files to device."
		Expand-Archive -literalpath C:\Temp\$IISCryptoZip -DestinationPath $tempFolder

		# Run the IIS Crypto CLI tool with the specified configuration template
		Write-Host "Starting IIS Crypto and using ""$template"" template to apply TLS settings."
		start-process "C:\temp\IISCrypto\iiscryptocli.exe" -argumentlist "/backup C:\temp\TLSbackup-$date.reg /template C:\temp\iiscrypto\$template" -NoNewWindow -Wait
		sleep 30

		# Restart the IIS service for the changes to take effect
		Write-Host "Restarting the IIS service for the changes to take effect."
		Restart-Service -Name W3SVC -Force -ErrorAction SilentlyContinue
		
		# Clean up old installation files
		If (Test-Path "C:\temp\IISCrypto"){
			Write-Host "Cleaning up files used during the installation."
			Remove-Item -Path "C:\temp\IISCrypto.zip" -Force -ErrorAction SilentlyContinue
			#Remove-Item -Path "C:\temp\IISCrypto" -Recurse -Force -ErrorAction SilentlyContinue
		}
		
		# Check if the reboot option was selected
		If ($Reboot -eq $true){
			Sleep 15
			Write-Host "Restarting to device to finish applying TLS changes."
			Restart-Computer -Force
		}Else{
			Write-Host "The device needs to be restarted to apply changes to TLS. Please restart this device."
		}		
		# Exit with a success
		Exit 0	
		
	}Catch{
		Write-Error $_.Exception.Message 
	}
}

# Main

# Check if the DattoRMM selection was to check the TLS version or to disable TLS 1.0 and 11 and enable TLS 1.2
If ($ChangeTLS -eq "Disable"){
	Write-Host "Disabling TLS 1.0 and 1.1 and enabling TLS 1.2. Please Reboot the device after the script completes to apply changes."
	changeTLS -templateType 1
} Elseif ($ChangeTLS -eq "Restore"){
	Write-Host "Restoring TLS settings back to the system defaults."
	changeTLS -templateType 2
}Else{
	Write-Host "Checking if TLS 1.0 and/or 1.1 is enabled."
	checkTLS
}