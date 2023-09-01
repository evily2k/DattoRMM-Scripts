<#
TITLE: Disables WiFi and Bluetooth Adapters [WIN]
PURPOSE: Disables WiFi and Bluetooth but keeps Ethernet enabled
CREATOR: Dan Meddock
CREATED: 25JUl2023
LAST UPDATED: 26JUl2023
#>

# Declarations
$undoChanges = $env:undoChanges

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

# Function to enable network adapters except for Ethernet adapters
function EnableNetworkAdapters {
    $adapters = Get-NetAdapter | Where-Object { (!($_.Name -like '*Ethernet*')) -and (!($_.InterfaceDescription -like '*Ethernet*'))}
    foreach ($adapter in $adapters) {
        if ($adapter.Status -ne 'Up') {
            Write-Host "Enabling network adapter $($adapter.Name)..."
            Enable-NetAdapter -Name $adapter.Name -Confirm:$false
            Write-Host "Network adapter $($adapter.Name) enabled."
        }
    }
}

# Function to disable Bluetooth devices
function DisableBluetooth {
    $bluetoothAdapters = Get-PnpDevice -Class Bluetooth -erroraction silentlycontinue
    foreach ($adapter in $bluetoothAdapters) {
        if ($adapter.Status -eq 'OK') {
            Write-Host "Disabling Bluetooth adapter $($adapter.Name)..."
            Disable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false -erroraction silentlycontinue
            Write-Host "Bluetooth adapter $($adapter.Name) disabled."
        }
    }
}

# Function to enable Bluetooth devices
function EnableBluetooth {
    $bluetoothAdapters = Get-PnpDevice -Class Bluetooth -erroraction silentlycontinue
    foreach ($adapter in $bluetoothAdapters) {
        if ($adapter.Status -ne 'OK') {
            Write-Host "Enabling Bluetooth adapter $($adapter.Name)..."
            Enable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false -erroraction silentlycontinue
            Write-Host "Bluetooth adapter $($adapter.Name) Enabled."
        }
    }
}

# Main 
Try{
	if ($undoChanges -eq "False"){
		# Disable network adapters except Ethernet
		Write-Host "Checking for network adapters that are not Ethernet and disabling them."
		DisableNetworkAdaptersExceptEthernet #-whatif

		# Disable Bluetooth
		Write-Host "Checking for bluetooth devices and disabling them."
		DisableBluetooth #-whatif
	}else{
		# Enable Wifi and Bluetooth
		Write-Host "Enabling Wifi and Bluetooth to undo changes made by this script."
		EnableNetworkAdapters
		EnableBluetooth
	}
}catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message 
}
Exit 0