<#
TITLE: Install BNTouch Mortgage CRM Outlook Plugin [WIN]
PURPOSE: Installs the BNTouch Mortgage CRM Outlook Plugin for Windows
CREATOR: Dan Meddock
CREATED: 21DEC2022
LAST UPDATED: 21DEC2022
#>

# Log Windows Updates output to log file
Start-Transcript -Path "C:\temp\BNTouch.log"

# Declarations
$workingDir = "C:\Temp"

# Main

Try {
	# Check if Temp folder exists
	If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force}
	
	# Change location to working directory
	set-location $workingDir
	
	# Start BNTouch Mortgage CRM Outlook Plugin install
	Write-Host "Installing BNTouch Mortgage CRM Outlook Plugin now."
	start-process .\BNTouchOutlookAddon-EmailLog-22.exe -argumentlist "/verysilent" -wait

}Catch{
	Write-Host $($_.Exception.Message)
	Exit 1
}


# Stop transcript logging
Stop-Transcript
Exit 0