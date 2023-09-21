<#
TITLE: Disables WiFi and Bluetooth Adapters [WIN]
PURPOSE: Disables WiFi and Bluetooth but keeps Ethernet enabled
CREATOR: Dan Meddock
CREATED: 25JUl2023
LAST UPDATED: 28AUG2023
#>

# Function to schedule script to run every 15 minutes to disable wifi and bluetooth adapters
function scheduleDisableWiFiandBluetooth {
	# powershell script used in scheduled task
	$installScript = "C:\Temp\DisableWiFiandBluetooth.ps1"
	
# Commands to DisableWiFiandBluetooth
$installCommand = @'
# Function to disable network adapters except for Ethernet adapters
function DisableNetworkAdaptersExceptEthernet {
    $adapters = Get-NetAdapter | Where-Object { (!($_.Name -like '*Ethernet*')) -and (!($_.InterfaceDescription -like '*Ethernet*'))}
    foreach ($adapter in $adapters) {
        if ($adapter.Status -eq 'Up') {
            Disable-NetAdapter -Name $adapter.Name -Confirm:$false
        }
    }
}

# Function to enable network adapters except for Ethernet adapters
function EnableNetworkAdapters {
    $adapters = Get-NetAdapter | Where-Object { (!($_.Name -like '*Ethernet*')) -and (!($_.InterfaceDescription -like '*Ethernet*'))}
    foreach ($adapter in $adapters) {
        if ($adapter.Status -ne 'Up') {
			Enable-NetAdapter -Name $adapter.Name -Confirm:$false
        }
    }
}

# Function to disable Bluetooth devices
function DisableBluetooth {
    $bluetoothAdapters = Get-PnpDevice -Class Bluetooth -erroraction silentlycontinue
    foreach ($adapter in $bluetoothAdapters) {
        if ($adapter.Status -eq 'OK') {
            Disable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false -erroraction silentlycontinue
        }
    }
}

# Function to enable Bluetooth devices
function EnableBluetooth {
    $bluetoothAdapters = Get-PnpDevice -Class Bluetooth -erroraction silentlycontinue
    foreach ($adapter in $bluetoothAdapters) {
        if ($adapter.Status -ne 'OK') {
            Enable-PnpDevice -InstanceId $adapter.InstanceId -Confirm:$false -erroraction silentlycontinue
        }
    }
}

# Main 
Try{	
	# Disable network adapters except Ethernet
	DisableNetworkAdaptersExceptEthernet

	# Disable Bluetooth
	DisableBluetooth
}catch{
	# Catch any errors thrown and exit with an error
	Write-Error $_.Exception.Message 
}
Exit 0
'@

	# Output scriptblock to directory
	$installCommand | out-file $installScript

	# Create Scheduled task
	$taskname = "DisableWiFiandBluetooth"
	$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-executionpolicy bypass -noprofile -file $installScript"
	$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 15)
	$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
	$task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal
	Register-ScheduledTask $taskname -InputObject $task
	Start-ScheduledTask -TaskName $taskname
}

scheduleDisableWiFiandBluetooth

Exit 0