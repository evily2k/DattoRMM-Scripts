<#
TITLE: Disable-TLS [WIN]
PURPOSE: This script will disable TLS 1.0 and TLS 1.1
CREATOR: Dan Meddock
CREATED: 10JUL2023
LAST UPDATED: 10JUL2023
#>

# Declarations

# Disable TLS 1.0 and TLS 1.1 registry settings for client and server
$TLSprotocolsKey = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
$dotNet35x32 = "HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727"
$dotNet35x64 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727"
$dotNet4x32 = "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319"
$dotNet4x64 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319"
$tls10Key = Join-Path -Path $TLSprotocolsKey -ChildPath "TLS 1.0"
$tls11Key = Join-Path -Path $TLSprotocolsKey -ChildPath "TLS 1.1"
$tls12Key = Join-Path -Path $TLSprotocolsKey -ChildPath "TLS 1.2"
$reg32bWinHttp = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp"
$reg64bWinHttp = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp"
$regWinHttpDefault = "DefaultSecureProtocols"
$regWinHttpValue = "0x00000800"

# Main 
Try{
	# Disable TLS 1.0 for client and server
	New-Item -Path "$tls10Key\Client" -Force | Out-Null
	Set-ItemProperty -Path "$tls10Key\Client" -Name "Enabled" -Value 0 -Force
	Set-ItemProperty -Path "$tls10Key\Client" -Name "DisabledByDefault" -Value 1 -Force
	New-Item -Path "$tls10Key\Server" -Force | Out-Null
	Set-ItemProperty -Path "$tls10Key\Server" -Name "Enabled" -Value 0 -Force
	Set-ItemProperty -Path "$tls10Key\Server" -Name "DisabledByDefault" -Value 1 -Force

	# Disable TLS 1.1 for client and server
	New-Item -Path "$tls11Key\Client" -Force | Out-Null
	Set-ItemProperty -Path "$tls11Key\Client" -Name "Enabled" -Value 0 -Force
	Set-ItemProperty -Path "$tls11Key\Client" -Name "DisabledByDefault" -Value 1 -Force
	New-Item -Path "$tls11Key\Server" -Force | Out-Null
	Set-ItemProperty -Path "$tls11Key\Server" -Name "Enabled" -Value 0 -Force
	Set-ItemProperty -Path "$tls11Key\Server" -Name "DisabledByDefault" -Value 1 -Force
	
	# Enable TLS 1.2 for client and server
	New-Item -Path "$tls12Key\Client" -Force | Out-Null
	Set-ItemProperty -Path "$tls12Key\Client" -Name "Enabled" -Value 1 -Force
	Set-ItemProperty -Path "$tls12Key\Client" -Name "DisabledByDefault" -Value 0 -Force
	New-Item -Path "$tls12Key\Server" -Force | Out-Null
	Set-ItemProperty -Path "$tls12Key\Server" -Name "Enabled" -Value 1 -Force
	Set-ItemProperty -Path "$tls12Key\Server" -Name "DisabledByDefault" -Value 0 -Force
	
	# for Windows x86
	New-ItemProperty -Path $reg32bWinHttp -Name $regWinHttpDefault -Value $regWinHttpValue -PropertyType DWORD
	# for Windows x64
	New-ItemProperty -Path $reg64bWinHttp -Name $regWinHttpDefault -Value $regWinHttpValue -PropertyType DWORD
	
	# Enable TLS1.2 for .Net 
	Set-ItemProperty -Path "$dotNet35x32" -Name "SystemDefaultTlsVersions" -Value 1 -Force
	Set-ItemProperty -Path "$dotNet35x64" -Name "SystemDefaultTlsVersions" -Value 1 -Force
	Set-ItemProperty -Path "$dotNet35x32" -Name "SchUseStrongCrypto" -Value 1 -Force
	Set-ItemProperty -Path "$dotNet35x64" -Name "SchUseStrongCrypto" -Value 1 -Force
	Set-ItemProperty -Path "$dotNet4x32" -Name "SystemDefaultTlsVersions" -Value 1 -Force
	Set-ItemProperty -Path "$dotNet4x64" -Name "SystemDefaultTlsVersions" -Value 1 -Force
	Set-ItemProperty -Path "$dotNet4x32" -Name "SchUseStrongCrypto" -Value 1 -Force
	Set-ItemProperty -Path "$dotNet4x64" -Name "SchUseStrongCrypto" -Value 1 -Force
	
	# Restart the machine for changes to take effect
	Write-Host "TLS 1.2 has been enabled."
	Write-Host "TLS 1.0 and TLS 1.1 have been disabled. Restart the machine for changes to take effect."
}Catch{
    Write-Error "An error occurred: $($_.Exception.Message)"
}