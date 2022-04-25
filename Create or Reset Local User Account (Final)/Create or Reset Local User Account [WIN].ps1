<#
TITLE: Create or Reset Local User Account [WIN]
PURPOSE: Create a local user with options to change existing users password and add the new or existing user account to the local Administrators group.
CREATOR: Dan Meddock
CREATED: 07MAR2022
LAST UPDATED: 28MAR2022
#>

# Declarations
$localAccount = $env:localAccount 
$localPassword = $env:localPassword
[bool]$Admin = $env:admin
[bool]$PasswordReset = $env:passwordReset

# Main
try{	
	If(!($localAccount)){Write-Host "No username was specified. Exiting..."; Exit 1}
	If(!($localPassword)){Write-Host "No password was specified. Exiting..."; Exit 1}

	$userCheck = get-localuser | Where-Object {$_.Name -eq $localAccount}
	$administratorsAccount = Get-WmiObject Win32_Group -filter "LocalAccount=True AND SID='S-1-5-32-544'" 
	$administratorQuery = "GroupComponent = `"Win32_Group.Domain='" + $administratorsAccount.Domain + "',NAME='" + $administratorsAccount.Name + "'`"" 
	$user = Get-WmiObject Win32_GroupUser -filter $administratorQuery | select PartComponent |where {$_ -match $localAccount} 
	
	If($userCheck){
		If($PasswordReset){
			Write-Host "$localAccount already exists. Resetting $localAccount password to $localPassword."
			net user $localAccount $localPassword /expires:never
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
		Write-Host "Creating $localAccount account with the password $localPassword..."
		net user $localAccount $localPassword /add
		Write-Host "Setting $localAccount password to never expire."
		net user $localAccount $localPassword /expires:never
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