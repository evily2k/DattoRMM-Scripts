<#
TITLE: updateElevateUC
PURPOSE: This script will uninstall Elevate if its installed in AppData. It downloaded the latest installer and compares its version to whats installed. If its newer then it installs the app.
CREATOR: Dan Meddock
CREATED: 05APR2023
LAST UPDATED: 10APR2023
#>

# Declarations
$workingDir = "C:\Temp"
$downloadURL = "https://cp.serverdata.net/voice/pbx/softphonereleases/default/latest-win/elevate-uc-x64.msi"
$elevateInstaller = "C:\temp\elevate-uc-x64.msi"

# Check if Elevate UC is installed via Registry
$varString = "Elevate UC" 
$uninstallRegPaths = ("HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") 

# Function to check a MSI files version number
function get-MSIVersion{
	param (
		[parameter(Mandatory=$true)] 
		[ValidateNotNullOrEmpty()] 
		[System.IO.FileInfo] $MSIPATH
	) 
	if(!(Test-Path $MSIPATH.FullName)){ 
		throw "File '{0}' does not exist" -f $MSIPATH.FullName 
	} 
	try{ 
		$WindowsInstaller = New-Object -com WindowsInstaller.Installer 
		$Database = $WindowsInstaller.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $Null, $WindowsInstaller, @($MSIPATH.FullName, 0)) 
		$Query = "SELECT Value FROM Property WHERE Property = 'ProductVersion'"
		$View = $database.GetType().InvokeMember("OpenView", "InvokeMethod", $Null, $Database, ($Query)) 
		$View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null) | Out-Null
		$Record = $View.GetType().InvokeMember( "Fetch", "InvokeMethod", $Null, $View, $Null ) 
		$Version = $Record.GetType().InvokeMember( "StringData", "GetProperty", $Null, $Record, 1 ) 
		return $Version
	}catch{ 
		throw "Failed to get MSI file version: {0}." -f $_
	}
}

try{
	# Check for Elevate UC installed in User AppData and uninstall if found.
	$users = Get-ChildItem C:\Users 
	foreach ($user in $users){
		$elevateDir = "$($user.fullname)\AppData\Local\Programs\Elevate UC\"
		if(test-path $elevateDir){
			Write-Host "Found appdata install for $user."
			Write-Host "Attempting to uninstall Elevate UC from user directory."
			Start-Process "$elevateDir\Uninstall Elevate UC.exe" -argumentlist "/S" -wait
		}
	}

	#Check if Temp folder exists; if not create it
	If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force | Out-Null}

	# Download the Elevvate UC latest MSI installer
	Invoke-WebRequest -OutFile $elevateInstaller -uri $downloadURL

	# Get registry info for Elevate UC installed version
	$elevateReg = $uninstallRegPaths | % {gci -Path $_ | % {get-itemproperty $_.pspath} | ? {$_.DisplayName -match "$varString"}} 
	
	# Get Elevate UC MSI version number
	$elevateMSIversion = get-MSIVersion -MSIPath $elevateInstaller
	
	# Compare the two versions and install the MSI if its on a newer version
	if ($elevateMSIversion -gt $elevateReg.DisplayVersion){
		write-host "Elevate UC is out dated. Installing latest version."
		Start-Process msiexec -argumentlist "/I $elevateInstaller /qn"
	}else{
		write-host "Elevate UC is already on the latest version available."
	}
}catch{
	Write-Error $_.Exception.Message
}

Exit 0