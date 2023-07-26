<#
TITLE: Disables WiFi and Bluetooth Adapters [WIN]
PURPOSE: Disables WiFi and Bluetooth but keeps Ethernet enabled
CREATOR: Dan Meddock
CREATED: 25JUl2023
LAST UPDATED: 26JUl2023
#>

# Declarations

# Function to disable network adapters except for Ethernet adapters
function DisableNetworkAdaptersExceptEthernet {
    $adapters = Get-NetAdapter | Where-Object { (!($_.Name -like '*Ethernet*')) -and (!($_.InterfaceDescription -like '*Ethernet*'))}

    foreach ($adapter in $adapters) {
        if ($adapter.Status -eq 'Up') {
            Write-Host "Disabling network adapter $($adapter.Name)..."
            Disable-NetAdapter -Name $adapter.Name -Confirm:$false
            Write-Host "Network adapter $($adapter.Name) disabled."
        }
    }
}

# Function to disable Bluetooth
function DisableBluetooth {
    $bluetoothAdapters = Get-PnpDevice -Class Bluetooth -erroraction silentlycontinue

    foreach ($adapter in $bluetoothAdapters) {
        if ($adapter.Status -eq 'OK') {
            Write-Host "Disabling Bluetooth adapter $($adapter.Name)..."
            Disable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false
            Write-Host "Bluetooth adapter $($adapter.Name) disabled."
        }
    }
}

# Main 
Try{	
	# Disable network adapters except Ethernet
	DisableNetworkAdaptersExceptEthernet #-whatif

	# Disable Bluetooth
	DisableBluetooth #-whatif
}catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message 
}
Exit 0