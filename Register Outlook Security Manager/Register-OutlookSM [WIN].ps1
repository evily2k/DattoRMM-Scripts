<#
TITLE: Register-OutlookSM [WIN]
Datto Component: Registers the Outlook Security Manager DLL files
PURPOSE: DLLs need to be registered so Outlook Security Manager will work properly.
CREATOR: Dan Meddock
CREATED: 13FEB2023
LAST UPDATED: 14FEB2023
#>

# Log Register-OutlookSM output to log file
Start-Transcript -Path "C:\temp\registerOutlookSM.log"

# Declarations
$outlookPath = "c:\program files (x86)\common files\outlook security manager"

# Main
Try{
	if (test-path $outlookPath){
		set-location $outlookPath
		Write-Host "Registering Outlook Security Manager DLL files now..."
		start-process "C:\windows\system32\regsvr32.exe" -arg "/s secman64.dll"
		start-process "C:\windows\system32\regsvr32.exe" -arg "/s secman.dll"
	}else{
		Write-Host "Outlook Security Manager path not found."
	}
}Catch{
	# Catch any powershell errors and output the error message
	Write-Error $_.Exception.Message	
	# Stop transcript logging
	Stop-Transcript
	Exit 1
}

# Stop transcript logging
Stop-Transcript
Exit 0

The HuntMon service failed to start due to the following error: The system cannot find the file specified. for LPLFSRVR2012