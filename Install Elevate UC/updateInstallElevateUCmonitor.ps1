$datetime = get-date
$elevateInstaller = "C:\temp\elevate-uc-x64.msi"
$varString = "Elevate UC" 
$workingDir = "C:\Temp"
$uninstallRegPaths = ("HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") 
$downloadURL = "https://cp.serverdata.net/voice/pbx/softphonereleases/default/latest-win/elevate-uc-x64.msi"

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

function write-status{
	param([String] $MSIPATH)	
	write-host '<-Start Result->'
	write-host "STATUS=$MSIPATH"
	write-host '<-End Result->'	
}

# Get registry info for Elevate UC installed version
$elevateReg = $uninstallRegPaths | % {gci -Path $_ | % {get-itemproperty $_.pspath} | ? {$_.DisplayName -match "$varString"}} 

# Get Elevate UC MSI version number
$elevateMSIversion = get-MSIVersion -MSIPath $elevateInstaller

if(((gci $elevateInstaller).CreationTime) -lt (((Get-Date).AddDays(-7)).tostring("yyyy-M-dd"))){
		If(!(test-path $workingDir -PathType Leaf)){new-item $workingDir -ItemType Directory -force}
		Invoke-WebRequest -OutFile $elevateInstaller -uri $downloadURL
}

if ($elevateReg -eq $null){
	write-status -msipath "Not Installed"
	Exit 1
}

If($datetime.DayOfWeek -eq "Monday"){	
	if ($elevateMSIversion -gt $elevateReg.DisplayVersion){
		write-status -msipath "OutDated"
		exit 1
	}else{
		write-status -msipath "UpToDate"			
		exit 0
	}
}else{
	if ($elevateMSIversion -gt $elevateReg.DisplayVersion){
		write-status -msipath "OutDated"
		exit 0
	}else{
		write-status -msipath "UpToDate"			
		exit 0
	}
}