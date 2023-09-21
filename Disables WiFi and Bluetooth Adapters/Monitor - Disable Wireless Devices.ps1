try{
	$a = 0
	$wifi = @()
	$bluetooth = @()
	$adapters = Get-NetAdapter | Where-Object { (!($_.Name -like '*Ethernet*')) -and (!($_.InterfaceDescription -like '*Ethernet*'))}
	foreach ($adapter in $adapters) {
			if ($adapter.Status -eq 'Up') {
				Write-Host "Wireless device detected:"
				Write-Host $adapter
				$wifi += $adapter
				$a++
			}
	}
	$bluetoothAdapters = Get-PnpDevice -Class Bluetooth -erroraction silentlycontinue
	foreach ($adapter in $bluetoothAdapters) {
			if ($adapter.Status -eq 'OK') {
				Write-Host "Bluetooth device detected:"
				Write-Host $adapter
				$bluetooth += $adapter
				$a++
			}
	}
	if($a -gt 0){
		if ($bluetooth -ne $NULL){
			$EnabledAdapters += $bluetooth.name + "`r`n"
		}
		if($wifi -ne $NULL){
			$EnabledAdapters += $wifi.name + "`r`n"
		}
		$EnabledAdapters = "Enabled: $EnabledAdapters"
		Write-Host "Save value to UDF 15 that wireless device has been detected and is Enabled."
		New-ItemProperty "HKLM:\SOFTWARE\CentraStage" -Name "Custom17" -PropertyType string -Value $EnabledAdapters -Force
	}else{
		$EnabledAdapters = "All Wireless Devices are Disabled."
		Write-Host "No Wireless Devices were detected or they are all disabled currently."
		New-ItemProperty "HKLM:\SOFTWARE\CentraStage" -Name "Custom17" -PropertyType string -Value $EnabledAdapters -Force
	}
}Catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message
}