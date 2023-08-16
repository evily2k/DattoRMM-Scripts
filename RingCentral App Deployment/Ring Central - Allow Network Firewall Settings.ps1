<#
TITLE: Ring Central - Allow Network Firewall Settings
PURPOSE: Adds the firewall settings for Ring Central so you aren't prompted to allow it manually.
CREATOR: Dan Meddock
CREATED: 19JUN2023
LAST UPDATED: 19JUN2023
#>

# Main
Try{
	# Add firewall rules so users dont need admin rights to set the rules by theirself
	Write-Host "Adding firewall rules for Ring Central."
	New-NetFirewallRule -DisplayName "Allow RingCentral (Inbound) - All Networks" -Direction Inbound -Program "C:\Program Files\RingCentral\RingCentral.exe"  -Action Allow -Enabled True
	New-NetFirewallRule -DisplayName "Allow RingCentral (Outbound) - All Networks" -Direction Outbound -Program "C:\Program Files\RingCentral\RingCentral.exe"  -Action Allow -Enabled True
}catch{
	Write-Error $_.Exception.Message
	Exit 1
}
Exit 0