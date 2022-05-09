# Install Pulse Secure Client [WIN]

**This script is used as a Datto component.**

**Installs the specified version of Pulse Secure Client with VPN site settings if specified and preconfig file included.**

```
DattoRMM Script Settings:
Category: Script
Script Type: Powershell
Icon: PulseSecure.png
Level: Low(2)
```
**Setup:**

**Create a new component in DattoRMM and copy/paste the script file contents into the DattoRMM script window.**

## Variables
```
Script Variables:
[SELECTION] 'clientName' - (Select the location profile for Pulse Secure)
	- Default Value: ~No Client
	- Value Types:
    		~No Client - Leave value empty
		Chicago - 1
[SELECTION] 'installVPN' - (Install Pulse Secure if checked)
	- Default Value: Yes
	- Value Types:
    		No - False
    		Yes - True
```
  
