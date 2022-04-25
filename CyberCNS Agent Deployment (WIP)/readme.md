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
Script Type: Batch
Icon: CCNS-icon.png
Level: Basic(4)
```
**Setup:**

**Create a new component in DattoRMM and copy/paste the script file contents into the DattoRMM script window.**
 - Update the URL variable in the Windows and Mac Sections to your CyberCNS URL so it knows where to download the agent from
 - Example for MAC/WIN: 
 
 			set url="https://mysitename.mycybercns.com/agents/ccnsagent/cybercnsagent.exe"
 
 			curl -k https://mysitename.mycybercns.com/agents/ccnsagent/cybercnsagent_darwin -O
			
 - Example for WIN only: 
 		
			$source = 'https://mysitename.mycybercns.com/agents/ccnsagent/cybercnsagent.exe' 
	
```
Script Variables:
[SELECTION] 'agentType' - (Agent deployment type)
	- Default Value: Probe
	- Value Types:
		Probe - Probe
		LightWeight - LightWeight
		Scan - Scan
Site Variables:
	'cybercnsclientid' - Obtain value from CCNS agent deployment for that site in CCNS
	'cybercnsclientsecret' - Obtain value from CCNS agent deployment for that site in CCNS
	'cybercnsdomain' - Example: set url="https://mysitename.mycybercns.com/agents/ccnsagent/cybercnsagent.exe"
	'cybercnscompanyid' - Obtain value from CCNS agent deployment for that site in CCNS
```
