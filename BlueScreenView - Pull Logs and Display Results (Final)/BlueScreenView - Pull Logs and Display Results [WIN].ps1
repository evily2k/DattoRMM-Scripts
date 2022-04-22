<#
TITLE: BlueScreenView - Pull Logs and Display Results [WIN]
PURPOSE: Deploys BlueScreenView and outputs dump file into stdout
CREATOR: Dan Meddock
CREATED: 28AUG2021
LAST UPDATED: 22APR2022
#>

# Declarations
$tempFolder = "C:\Temp"
$DownloadURL = "https://www.nirsoft.net/utils/bluescreenview.zip"

# Main

# Transfers BlueScreenView to target machine; creates directory if it doesnt exist.
Try {
	# Creates the temp folder if it doesnt exist
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
	
	#Download and Extract BlueScreenView
	(New-Object System.Net.WebClient).DownloadFile($DownloadURL, "$($tempFolder)\bluescreenview.zip")
	Expand-Archive -LiteralPath "$($tempFolder)\bluescreenview.zip" -DestinationPath $tempFolder -Force

	# Run BlueScreenView and export dump to TXT file
	Start-Process -NoNewWindow -FilePath "C:\Temp\BlueScreenView.exe" -ArgumentList "/stext C:\Temp\bluescreenviewOut.txt"
	Sleep 5
	
	# Display MiniDump log TXT file contents in stdout
	$bsvLog = get-content C:\Temp\bluescreenviewOut.txt
	if ($bsvLog){
		foreach ($log in $bsvLog){
			Write-Host $log
		}
	}else{Write-Host "No BlueScreenView data in CSV dump file"}
	# Exit with a success
	Exit 0
}Catch{
	# Exit with an error if any errors logged
	Write-Error $_.Exception.Message 
	Exit 1
}
