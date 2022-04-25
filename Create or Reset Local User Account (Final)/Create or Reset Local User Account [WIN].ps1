<#
TITLE: Create or Reset Local User Account [WIN]
PURPOSE: Create a local user with options to change existing users password and add the new or existing user account to the local Administrators group.
CREATOR: Dan Meddock
CREATED: 07MAR2022
LAST UPDATED: 25APR2022
#>

# Declarations
$localAccount = $env:localAccount 
$localPassword = $env:localPassword
[bool]$Admin = $env:admin
[bool]$PasswordReset = $env:passwordReset

# Main
try{	
	# Checks if a value was enter in the username field in the DattoRMM Script; if not exit.
	If(!($localAccount)){Write-Host "No username was specified. Exiting..."; Exit 1}
	If(!($localPassword)){Write-Host "No password was specified. Exiting..."; Exit 1}

	# Get local user information
	$userCheck = get-localuser | Where-Object {$_.Name -eq $localAccount}
	$administratorsAccount = Get-WmiObject Win32_Group -filter "LocalAccount=True AND SID='S-1-5-32-544'" 
	$administratorQuery = "GroupComponent = `"Win32_Group.Domain='" + $administratorsAccount.Domain + "',NAME='" + $administratorsAccount.Name + "'`"" 
	$user = Get-WmiObject Win32_GroupUser -filter $administratorQuery | select PartComponent |where {$_ -match $localAccount} 
	
	# Check if user exists
	If($userCheck){
		# Check if password reset checkbox is checked
		If($PasswordReset){
			Write-Host "$localAccount already exists. Resetting $localAccount password to $localPassword."
			net user $localAccount $localPassword /expires:never
			#if user isnt an admin add them to the Administrators group
			If(!($user)){
				Write-Host "Adding $localAccount to local administrators group."
				net localgroup administrators $localAccount /add
			}Else{
				Write-Host "$localAccount is already a member of the Administrators group."
				}
		}Else{
			Write-Host "$localAccount already exists. Exiting..."
			Exit 1
			}
	}Else{
		# If user doesnt exist then create the account
		Write-Host "Creating $localAccount account with the password $localPassword..."
		net user $localAccount $localPassword /add
		Write-Host "Setting $localAccount password to never expire."
		net user $localAccount $localPassword /expires:never
		# Add user to admin group if admin check box is checked
		If($admin){
			Write-Host "Adding $localAccount to the Administrators group."
			net localgroup administrators $localAccount /add
		}
	}
	Exit 0
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}