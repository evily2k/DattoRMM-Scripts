# Create or Reset Local User Account [WIN]
**The script will prompt you to create or reset a local user account with options to reset user account password and add to administrators group**

Create a local user with options to change existing users password and add the new or existing user account to the local Administrators group.

```
DattoRMM Script Settings:
Category: Script
Script Type: Powershell
Icon: winUser.png
Level: Basic(3)
```
**Setup:**

**Create a new component in DattoRMM and copy/paste the script file contents into the DattoRMM script window.**
```
Variables:
	[BOOLEAN] 'passwordReset' - (Change users password if user already exists)
		Default Value: True
	[STRING] 'localAccount' - (Type the username)
	[BOOLEAN] 'admin' - (Add user to local admin group)
		Default Value: True
	[STRING] 'localPassword' - (Type the password)
```
**Or**

**Import the "Create or Reset Local User Account WIN.cpt" file**
