# Script will check for any shared printers; if detected, a UDF will be set identifying the server as a print server

# Declarations
$sharedPrinters = (gwmi Win32_Printer).shared

# Main
Try{
	#Check if Temp folder exsists
	if ($sharedPrinters -contains $true){
		New-ItemProperty -Path "HKLM:\SOFTWARE\CentraStage" -Name "Custom19" -Value "Shared Printers Detected." -Force | Out-Null
		write-host "Server has been flagged as a Print server"
		Exit 0
	}else{
		write-host "Server has no shared printers"
		Exit 1
	}
	
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}