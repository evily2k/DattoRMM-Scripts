#D ownloads and installs Dell Command 4.2.1
# Runs scan for updates, installs updates, if a reboot is required it will reboot after the installation completes, suspends bitlocker
# Function to output log results to Datto's activity log
Function writeDattoActivity(){
	$getLog = @(get-content -path $LogFilePath)
	foreach ($message in $getLog){write-host $message}
}
# Main
try {
	# Declarations
	$DownloadURL = "https://dl.dell.com/FOLDER07414802M/1/Dell-Command-Update-Application-for-Windows-10_W1RMW_WIN_4.2.1_A00.EXE"
	$DownloadLocation = "C:\Temp\Dell"
	$LogFilePath = "$($DownloadLocation)\dellUpdate.log"
	$druLocation64 = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
	$druLocation32 = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
	
	# Check if dell command exists; if not then download and install
    $TestDownloadLocation = Test-Path $DownloadLocation
    if (!$TestDownloadLocation) { new-item $DownloadLocation -ItemType Directory -force }
    $TestDownloadLocationZip = Test-Path "$($DownloadLocation)\DellCommandUpdate.exe"
    if (!$TestDownloadLocationZip) { 
        Copy-Item 'DellCommandUpdate.exe' -Destination $DownloadLocation -force
		#Invoke-WebRequest -UseBasicParsing -Uri $DownloadURL -OutFile "$($DownloadLocation)\DellCommandUpdate.exe"
        Start-Process -FilePath "$($DownloadLocation)\DellCommandUpdate.exe" -ArgumentList '/s' -Verbose -Wait
        set-service -name 'DellClientManagementService' -StartupType Manual
    } 
}
catch {
    write-host "The download and installation of DCUCli failed. Error: $($_.Exception.Message)"
    exit 1
}
# Run Dell Command and update
try {	
	if (test-path -path $druLocation32 -pathtype leaf){$druDir = $druLocation32}else{$druDir = $druLocation64}	
	write-host "Starting Dell Command update."
	start-process -NoNewWindow -FilePath $druDir -ArgumentList "/applyUpdates -silent -reboot=enable -autoSuspendBitLocker=enable -outputLog=$($DownloadLocation)\dellUpdate.log" -Wait
}
catch{
	write-host $_.Exception.Message
	writeDattoActivity
  exit 1
}
# Write log file output to console to display in Datto logging
writeDattoActivity
exit 0