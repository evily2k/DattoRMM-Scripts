# Datto RMM Script: Add Chrome Extension [WIN]
**The script will prompt you to enter in a string value of an extension ID taken from the Chrome Web Store URL for the extension**

**Example Extension ID:** cjpalhdlnbpafiamejdnhcphjbkeiagm

```
Datto Settings:
Category: Script
Script Type: Powershell
Icon: chromeextension.png
Level: Low(2)
```
```
Datto Variables:
[STRING] chromeExtensionID (String value of an extension ID taken from the Chrome Web Store URL for the extension)
[SELECTION] installType (Choose whether you want to install the extension for EVERY user, or just a single user)
```
**Setup:**
**Either create a new component in DattoRMM and copy/paste the script file contents into the DattoRMM script window.**

Then add in both 'chromeExtensionID' and 'installType' variables in the Datto component settings.
