<#
TITLE: Block-Windows11Update
PURPOSE: This script will lock the Windows 10 build down to 22H2
CREATOR: Dan Meddock
CREATED: 17MAY2023
LAST UPDATED: 17MAY2023
#>

# Declarations
$systemInfo = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
$regPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'

# Main
Try{
	If (($systemInfo.Version -ge "10.0.10240") -and ($systemInfo.ProductType -eq 1)){
		If(!(Test-Path $regPath -PathType Container)){New-Item $regPath -Force -Verbose}
		Set-ItemProperty -Path $regPath -Name ProductVersion -Value "Windows 10" -Type STRING -Force -Verbose
		Set-ItemProperty -Path $regPath -Name TargetReleaseVersion -Value 1 -Type DWORD -Force -Verbose
		Set-ItemProperty -Path $regPath -Name TargetReleaseVersionInfo -Value $ENV:TargetVersion -Type STRING -Force -Verbose
		Set-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name $ENV:usrUDF -Value "Blocked Windows 11 Update." -Type STRING -Force -Verbose
		Write-Host "Value written to User-defined Field $ENV:usrUDF`."
		Exit 0
	}Else{
		Write-Host "Computer OS is not Windows 10."
		Exit 1
	}
}Catch{
	Write-Error "An error occurred: $($_.Exception.Message)"
}