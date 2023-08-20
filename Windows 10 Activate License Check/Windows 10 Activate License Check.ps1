<#
TITLE: Windows 10 Activate License Check [WIN]
PURPOSE: Checks if Windows is permanently activated
CREATOR: Dan Meddock
CREATED: 15AUG2023
LAST UPDATED: 15AUG2023
#>

# Declarations
$testActivation = Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | where { $_.PartialProductKey } | select Description, LicenseStatus

# Main
Try{
	if($testActivation.LicenseStatus -eq $null){
		Write-Host "Windows activation check failed to run. Please investigate."
		#Exit 1
	}
	if($testActivation.LicenseStatus -ne "1"){
		Write-Host "Windows is not permanently activated."
		#Exit 1
	}else{
		Write-Host "Windows is permanently activated."
		#Exit 0
	}
}Catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message 
}