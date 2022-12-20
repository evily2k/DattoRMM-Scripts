<#
TITLE: Install DisplayLink Drivers [WIN]
PURPOSE: Installs the DisplayLink USB Graphics Software for Windows
CREATOR: Dan Meddock
CREATED: 16DEC2022
LAST UPDATED: 20DEC2022
#>

# Log Windows Updates output to log file
Start-Transcript -Path "C:\temp\DisplayLinkInstall.log"

# Declarations
$workingDir = "C:\Temp"

# Main

Try {
	# Check if Temp folder exists
	If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force}
	
	# Change location to working directory
	set-location $workingDir
	
	# Start DisplayLink install
	Write-Host "Installing DisplayLink Graphics driver now."
	start-process .\DisplayLinkSetup.exe -argumentlist "-silent -noreboot" -nonewwindow

}Catch{
	Write-Host $($_.Exception.Message)
	Exit 1
}


# Stop transcript logging
Stop-Transcript
Exit 0