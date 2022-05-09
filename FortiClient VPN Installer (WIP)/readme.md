# FortiClient VPN Installer with Client Settings [WIN]
**Script to deploy FortiClient VPN Installer with Client Settings**

**Installs Forticlient 7.0.2.90 VPN agent with options to configure the VPN settings if client name is listed**
- Select Yes/No to install the VPN client
- Select a client's VPN configuration or leave unset for generic settings

```
DattoRMM Script Settings:
Category: Script
Script Type: Powershell
Icon: FortiClient2.png
Level: Basic(4)
```
**Setup:**

**Create a new component in DattoRMM and copy/paste the script file contents into the DattoRMM script window.**

## Variables
```
Script Variables:
[SELECTION] 'clientName' - (Select the client to specify VPN settings)
	- Default Value: ~No Client
	- Value Types:
    		~No Client - Leave value empty
		Client 1 - 1
      		Client 2 - 2
      		Client 3 - 3
      		Client 4 - 4
      		Client 5 - 5
      		Client 6 - 6
		
[SELECTION] 'installVPN' - (Install VPN client if checked.)
	- Default Value: Yes
	- Value Types:
    		No - False
    		Yes - True
```

## Files

- Every client name is associated with an exported registry key containing the VPN site settings
- Use the following command to export your Forticlient registry settings:
- Attach the exported .reg file to the DattoRMM forticlient install script so the script can use the file
- Attach a EXE installer of forticlient and name it "FortiClientVPN.exe"
```
reg export HKLM\Software\Fortinet\FortiClient\ C:\temp\client1.reg
```
