# Uninstall All Version of Pulse Secure [WIN]

**This script is used as a Datto component.**
**No additional files or variables are needed with this script.**

**This script will attempt uninstall all versions of the Pulse Secure Desktop Client and all its components.**

First the script finds all the uninstall keys for Pulse Secure in the registry.
Then it will attempt to uninstall all applications on the system that contain the words 'Pulse Secure' or 'Pulse Application'
Once that completes it will attempt to remove the Pulse Secure Setup client that gets installed in AppData.
It will schedule a task as the currently signed in user or a local admin account with the word "*ADMIN" in its name to execute the uninstall.
Once the AppData uninstall completes the script will clean up left over registry keys; any key deleted gets backed up first.
The script will find any HKCU regkeys left over and will backup and delete.
The installer script creates desktop icons so I added lines to remove those if detected.
Finally the script will delete any left over Pulse Secure folders left over in AppData.

```
Datto Settings:
Category: Script
Script Type: Powershell
Icon: PulseSecureUninstall.png
Level: Low(2)
```
**Setup:**

**Create a new component in DattoRMM and copy/paste the script file contents into the DattoRMM script window.**
