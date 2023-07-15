<#
TITLE: Check for Specific Users [WIN]
PURPOSE: This script will search for all users listed in the $discoveredUsers array
CREATOR: Dan Meddock
CREATED: 09JUL2023
LAST UPDATED: 09JUL2023
#>

# Declarations
$discoveredUsers = @()

# Array of usernames to check
$usersToCheck = @(
	'forti*'
)

# Main 
Try{
	# Check if the user exists
	$user = net user | findstr /r /c:$usersToCheck
	$user = $user.Replace('Guest', '')

	# Output the result
	If($user -ne $null){$discoveredUsers += $user}
	
	# Output the detected users for DattoRMM activity log if any are found
	# If any users discovered exit with a failure to identify device; if none are found exit with a success
	If($discoveredUsers -ne $null){
		Write-Host "The following users were detected on this device:"
		Write-Host "$discoveredUsers"
		#Exit 1
	}
	If($user -eq $Null){
		Write-Host "No Users detected."
	}
}Catch{
    # Output any errors that are generated
    Write-Host $_.Exception.Message
}