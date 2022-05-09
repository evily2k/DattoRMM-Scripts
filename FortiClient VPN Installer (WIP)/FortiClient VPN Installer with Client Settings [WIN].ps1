<#
TITLE: FortiClient VPN Installer with Client Settings [WIN]
PURPOSE: Installs Forticlient VPN agent with options to configure the VPN settings if client name is listed
CREATOR: Dan Meddock
CREATED: 20FEB2022
LAST UPDATED: 09MAY2022
#>

# Declarations
$tempFolder = "C:\Temp"
$FortiClient = "C:\temp\FortiClientVPN.exe"
$clientName = $env:clientName
$installVPN = $env:installVPN
$installCheck = test-path -path "C:\Program Files\Fortinet\FortiClient\FortiClient.exe"

# Sets the VPN settings via switch
Function SetVPNSettings {
	param([Parameter (Mandatory=$true)] [int32] $clientName)	
	switch ($clientName){
		1{	
			$client = "Client 1"
			$clientReg = 'Client1.reg'
		}
		2{
			$client = "Client 2"
			$clientReg = 'Client2.reg'
		}
		3{
			$client = "Client 3"
			$clientReg = 'Client3.reg'
		}
		4{
			$client = "Client 4"
			$clientReg = 'Client4.reg'
		}
		5{
			$client = "Client 5"
			$clientReg = 'Client5.reg'
		}
		6{
			$client = "Client 6"
			$clientReg = 'Client6.reg'
		}
	}
	$FortiReg = Join-Path -Path $tempFolder $clientReg
	Copy-Item $clientReg -Destination $FortiReg -force
	Invoke-Command {reg import $FortiReg *>&1 | Out-Null}
	$getRegKeyName = (get-childitem -path "HKLM:\Software\Fortinet\FortiClient\Sslvpn\Tunnels\").name
	$ipCheck = (gp "HKLM:\Software\Fortinet\FortiClient\Sslvpn\Tunnels\*").server
	Write-Host $getRegKeyName
	Write-Host "Applying $client's ($ipCheck) registry key for FortiClient Settings"	
}

# Main
Try{
	#Check if Temp folder exsists
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
	
	# Installs FortiClient VPN agent
	  If($installVPN -eq "True"){
		#Check if FortiClient is already installed		
		if($installCheck){
			Write-Host "FortiClient VPN is already installed."
		}else{
			# Transfer installers to computer
			Write-Host "Transferring installer to device."
			Copy-Item -Path 'FortiClientVPN.exe' -Destination $FortiClient -force

			# Start installation of both applications
			Write-Host "Starting install of FortiClient VPN."
			Start-Process -NoNewWindow -FilePath $FortiClient -ArgumentList "/quiet /norestart"; sleep 30
		}
	}Else{Write-Host "VPN install is disabled."}
	
	# Transfer and install regkey
	If($clientName){
		SetVPNSettings -clientName $clientName
		Get-ItemProperty "HKLM:\Software\Fortinet\FortiClient\Sslvpn\Tunnels\*"
		Exit 0
	}Else{Write-Host "No client VPN settings specified."}
	Exit 0
	
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}