#CyberCNS Agent Deployment [WIN][MAC]
**Script to deploy CyberCNS to MacOS and Windows computers**

Select the CCNS agent type when running the script
  - Probe for scanning the network from that device
  - LightWeight for scanning just that device
  - Scan for unsure(?)
  
  Note: For MacOS it installs nmap as a prerequisite.

```
DattoRMM Script Settings:
Category: Script
Script Type: Powershell
Icon: CCNS-icon.png
Level: Basic(4)
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
