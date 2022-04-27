# Disable NTLMv1 Authentication [WIN]
**This script will disable or enable (if checked) NTLMv1 by changing a registry value**

Value 5 corresponds to the policy option "Send NTLMv2 response only. Refuse LM NTLM".

```
DattoRMM Script Settings:
Category: Script
Script Type: Powershell
Icon: Settings.png
Level: Basic(3)
```
**Setup:**

**Create a new component in DattoRMM and copy/paste the script file contents into the DattoRMM script window.**
```
Variables:
	[BOOLEAN] 'EnableNTLMv1' - (Check this box if you want to restore NTLMv1 Authentication)
		Default Value: False
```
**Or**

**Import the "Disable NTLMv1 Authentication WIN.cpt" file**
