# Enable Advanced Powershell Logging with Log Cleanup [WIN]
**Enables Powershell module logging, script block logging, and transcript logging.**

- Added a scheduled task to delete log file folders once they are 30 days old.
- Checks for previous scheduled tasks and deletes one if it exists
- Logging folder is in C:\temp\PSLogging

```
DattoRMM Script Settings:
Category: Script
Script Type: Powershell
Icon: PowerShell.png
Level: Basic(4)
```
**Setup:**

**Create a new component in DattoRMM and copy/paste the script file contents into the DattoRMM script window.**

**Or**

**Import the "Enable Advanced Powershell Logging with Log Cleanup WIN.cpt" file**
