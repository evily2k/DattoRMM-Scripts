<#
TITLE: Install nmap and run ipscan report[WIN]
PURPOSE: Installs nmap if not installed and then runs a ipscan
CREATOR: Dan Meddock
CREATED: 18APR2025
LAST UPDATED: 18APR2025
#>

# Main

function nmap {	
	$programName = "nmap"	
	$installed = ("HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") | % {gci -Path $_ | % {get-itemproperty $_.pspath} |
	Where-Object { $_.DisplayName -like "*$programName*" }}

	if ($installed) {
		Write-Output "Program is installed."
	} else {
		Write-Output "Program is NOT installed."
		#Download nmap
		$page = Invoke-WebRequest -Uri "https://nmap.org/dist/"
		$latestInstaller = $page.Links |
			Where-Object { $_.href -match "nmap-[\d\.]+-setup\.exe" } |
			Sort-Object href -Descending |
			Select-Object -First 1
		$DownloadURL = "https://nmap.org/dist/" + $latestInstaller.href
		$FileName = [System.IO.Path]::GetFileName($DownloadURL)
		$installerPath = Join-Path $env:TEMP $FileName
		(New-Object System.Net.WebClient).DownloadFile($DownloadURL, $installerPath)
		
			if (Test-Path $installerPath) {
				Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait
				Write-Output "Nmap installer executed successfully."
			} else {
				Write-Error "Installer not found at $installerPath"
			}
	}
	
}

function Get-MacVendor($mac) {
	# Get Vendor via Mac
	return (irm "https://www.macvendorlookup.com/api/v2/$($mac.Replace(':','').Substring(0,6))" -Method Get)
}

function ipscan {	
	Clear-Host
	# Start gathering network data
	Write-Host -NoNewLine 'Getting Ready...'

	# Hostname
	$hostName = [System.Net.Dns]::GetHostName()

	# Check Internet Connection and Get External IP
	$hotspotRedirectionTest = irm "http://www.msftncsi.com/ncsi.txt"
	$externalIP = if ($hotspotRedirectionTest -eq "Microsoft NCSI") {irm "http://ifconfig.me/ip"} else {"No Internet or Redirection"}

	# Find Gateway
	$gateway = (Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -First 1).NextHop
	$gatewayParts = $gateway -split '\.'
	$gatewayPrefix = "$($gatewayParts[0]).$($gatewayParts[1]).$($gatewayParts[2])."

	# Internal IP
	$internalIP = (Get-NetIPAddress | Where-Object {$_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -ne 'Loopback Pseudo-Interface 1' -and ($_.IPAddress -like "$gatewayPrefix*")}).IPAddress

	# Host adapter type
	$adapter = (Get-NetIPAddress -InterfaceAlias "*Ethernet*","*Wi-Fi*" -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "$gatewayPrefix*" }).InterfaceAlias

	# My Mac
	$myMac = (Get-NetAdapter -Name $adapter).MacAddress.Replace('-',':')

	# Convert subnet prefix to readable number
	$prefixLength = (Get-NetIPAddress | Where-Object {$_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -ne 'Loopback Pseudo-Interface 1'} | Select-Object -First 1).PrefixLength
	$subnetMask = ([System.Net.IPAddress]::Parse(($([Math]::Pow(2, $prefixLength)) - 1) * [Math]::Pow(2, 32 - $prefixLength))).GetAddressBytes() -join "."

	# Domain
	$domain = (Get-WmiObject -Class Win32_ComputerSystem).Domain

	# Output results
	$global:hostOutput = [PSCustomObject]@{
		Host = if($hostName){$hostName} else {'Unknown'}
		ExternalIP = if($externalIP){$externalIP} else {'Unknown'}
		InternalIP = if($internalIP){$internalIP} else {'Unknown'}
		Adapter = if($adapter){$adapter} else {'Unknown'}
		Subnet = if($subnetMask){$subnetMask} else {'Unknown'}
		Gateway = if($gateway){$gateway} else {'Unknown'}
		Domain = if($domain){$domain} else {'Unknown'}
	}

	# Ping Entire Subnet
	for ($i = 1; $i -le 254; $i++) {
		Test-Connection $gatewayPrefix$i -Count 1 -AsJob | Out-Null
		Write-Progress -Activity "Sending Packets" -Status "Progress..." -PercentComplete ($i * (100 / 254))
	}
	Write-Progress -Activity "Sending Packets" -Status "Done" -PercentComplete 100
	Start-Sleep -Seconds 1
	Write-Progress -Activity "Sending Packets" -Completed

	# Wait with progress
	for ($i = 1; $i -le 100; $i++) {
		Write-Progress -Activity "Listening" -Status "Waiting for responses..." -PercentComplete ($i)
		Start-Sleep -Milliseconds 50
	}
	Write-Progress -Activity "Listening" -Status "Done" -PercentComplete 100
	Start-Sleep -Seconds 1
	Write-Progress -Activity "Listening" -Completed	
	
	# Host network data collection finished
	Write-Host 'Done';Write-Host

	# Output host info
	$hostOutput | Out-String -Stream | Where-Object { $_.Trim().Length -gt 0 } | Write-Host
	
	# Start gathering network data
	Write-Host;Write-Host -NoNewLine 'Running IPscan...'

	# Filter for Reachable or Stale states and select only IP and MAC address
	$arpInit = Get-NetNeighbor | Where-Object { $_.State -eq "Reachable" -or $_.State -eq "Stale" } | Select-Object -Property IPAddress, LinkLayerAddress

	# Convert IP Addresses from string to int by each section
	$arpConverted = $arpInit | Where-Object { $_.IPAddress -match "^\d+\.\d+\.\d+\.\d+$" } | Sort-Object -Property { $ip = $_.IPAddress; [version]($ip) }

	# Sort by IP using [version] sorting
	$arpOutput = $arpConverted | Sort-Object {[version]$_.IPaddress}
	$self = 0
	$myLastOctet = [int]($internalIP -split '\.')[-1]

	# Get My Vendor via Mac lookup
	$tryMyVendor = (Get-MacVendor "$myMac").Company
	$myVendor = if($tryMyVendor){$tryMyVendor.substring(0, [System.Math]::Min(25, $tryMyVendor.Length))} else {'Unknown'}
	
	# Initialize an array to store the results
	$global:displayBuffer = @()
	$self = 0

	# Cycle through ARP table
	foreach ($line in $arpOutput) {
		$ip = $line.IPAddress
		$mac = $line.LinkLayerAddress.Replace('-',':')
		
		# Get Hostname
		try {
			$name = [System.Net.Dns]::GetHostEntry($ip).HostName
		} catch {
			$name = "Unable to Resolve"
		} finally {
			if ([string]::IsNullOrEmpty($name)) {
				$name = "Unable to Resolve"  
			}			
		}

		# Get Remote Device Vendor via Mac lookup
		$tryVendor = (Get-MacVendor "$mac").Company
		$vendor = if ($tryVendor) { $tryVendor.Substring(0, [System.Math]::Min(25, $tryVendor.Length)) } else { 'Unknown' }

		# Format display string
		$displayX = ("{0,-18} {1,-26} {2, -14} {3}" -f $mac, $vendor, $ip, $name)
		$displayZ = ("{0,-18} {1,-26} {2, -14} {3}" -f $myMac, $myVendor, $internalIP, "$hostName (This Device)")

		$lastOctet = [int]($ip -split '\.')[-1]

		if ($myLastOctet -gt $lastOctet) {
			$global:displayBuffer += $displayX
		} else {
			if ($self -ge 1) {
				$global:displayBuffer += $displayX
			} else {
				$global:displayBuffer += $displayZ
				$global:displayBuffer += $displayX
				$self++
			}
		}
	}
	
	# Network data collection finished
	Write-Host 'Done';Write-Host
	
	# Table header
	$DisplayA = ("{0,-18} {1,-26} {2, -14} {3}" -f 'MAC ADDRESS', 'VENDOR', 'IP ADDRESS', 'REMOTE HOSTNAME')
	Write-Host $DisplayA
	Write-Host "================================================================================================="
	
	# Now display all collected output
	$displayBuffer | ForEach-Object { Write-Host $_ }
}

Try{
	# Check if nmap is installed and if not then install it
	nmap
	# Run ipscan report for the network the current device is on
	ipscan
}Catch{
	# Exit with an error if any errors logged
	Write-Error $_.Exception.Message 
	Exit 1
}