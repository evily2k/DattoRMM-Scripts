<#
TITLE: Get CHKDSK results [WIN]
PURPOSE: Pulls the most recent CHKDSK logs and outputs to stdout for DattoRMM
CREATOR: Dan Meddock
CREATED: 09DEC2021
LAST UPDATED: 09MAY2022
#>

# Declarations
$tempFolder = "C:\Temp"
$LogFilePath = "C:\temp\CHKDSK_SCAN.txt"

# Function to output log results to Datto's activity log
Function writeDattoActivity(){
	$getLog = @(get-content -path $LogFilePath)
	foreach ($message in $getLog){write-host $message}
}

# Main
try{
	# Check if Temp folder exists
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
	
	
	# Get CHKDSK results
    get-winevent -FilterHashTable @{logname="Application"; id="1001"}| ?{$_.providername -match "wininit"} | fl timecreated, message | out-file "C:\temp\CHKDSK_SCAN.txt"
	
	# Check if log file has data; if not, error out	
	if([String]::IsNullOrWhiteSpace((Get-content $LogFilePath))){
		Write-Host "No data in log file"
		Exit 1
	}
}catch{
  writeDattoActivity
  exit 1
}
writeDattoActivity
exit 0