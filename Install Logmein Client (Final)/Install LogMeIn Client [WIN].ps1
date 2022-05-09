<#
TITLE: Install LogMeIn Client [WIN]
PURPOSE: Script will download LogMeIn installer and apply the siteToken key specific in the script variables
CREATOR: Dan Meddock
CREATED: 14MAR2022
LAST UPDATED: 09MAY2022
#>

# Declarations
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$DownloadURL = "https://secure.logmein.com/logmein.msi"
$logmeinFile = "C:\Temp\LogMeIn.msi"
$tempFolder = "C:\Temp"
# Replace "00_asdflkajsdflkjasdflkasdf" with the correct logmein token or set the token at the site level in DattoRMM
$siteToken = if($env:LogMeInToken){$env:LogMeInToken}else{"00_asdflkajsdflkjasdflkasdf"}


# Main
Try{	
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}
	# Transfer installers to computer
	Write-Host "Transferring installers to device."
	Invoke-WebRequest -Uri $DownloadURL -OutFile $logmeinFile	
	# Start installation of both applications
	Write-Host "Starting install of applications."
	msiexec /i $logmeinFile /quiet DEPLOYID=$siteToken INSTALLMETHOD=5 FQDNDESC=1
	Exit 0	
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}