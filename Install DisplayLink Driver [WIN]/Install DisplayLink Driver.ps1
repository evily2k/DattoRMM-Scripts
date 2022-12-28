<#
TITLE: Install DisplayLink Drivers [WIN]
PURPOSE: Installs the DisplayLink USB Graphics Software for Windows
CREATOR: Dan Meddock
CREATED: 16DEC2022
LAST UPDATED: 16DEC2022
#>

# Log Windows Updates output to log file
Start-Transcript -Path "C:\temp\DisplayLinkInstall.log"

# Declarations
$tempFolder = "C:\Temp"
$encompassPath = $encompassZipPath -replace ".zip",""

# Main

Try {
	# Check if Temp folder exists
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
	
	# Change location to working directory
	set-location $workingDir
	
	# Start DisplayLink install
	start-process .\DisplayLinkSetup.exe -argumentlist "-silent -noreboot" -nonewwindow

}Catch{
	Write-Host $($_.Exception.Message)
	#Exit 1
}


# Stop transcript logging
Stop-Transcript
Exit 0