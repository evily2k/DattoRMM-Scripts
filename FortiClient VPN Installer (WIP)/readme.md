# CyberCNS Agent Deployment [WIN][MAC]
**Script to deploy CyberCNS to MacOS and Windows computers**

The DattoRMM script will prompt to select the CCNS agent type:
  - Probe for scanning the network from that device
  - LightWeight for scanning just that device
  - Scan for unsure(?)
  
  Note: For MacOS it installs nmap as a prerequisite.

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
```
reg export HKLM\Software\Fortinet\FortiClient\ C:\temp\client1.reg
```
