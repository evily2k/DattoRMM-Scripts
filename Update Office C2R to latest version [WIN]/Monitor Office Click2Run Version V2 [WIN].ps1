function write-DRRMAlert ($message) {
    write-host '<-Start Result->'
    write-host "Alert=$message"
    write-host '<-End Result->'
}
   
$version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentVersion
if($Version -lt "6.3"){
	write-DRRMAlert "Unsupported OS. Only Server 2012R2 and up are supported."
	exit 0
}

$ReportedVersion = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -Name "VersionToReport" -erroraction silentlycontinue

if($ReportedVersion -eq $null){
	write-DRRMAlert "Office C2R version is not installed on this device."
	exit 0
}

$ENVVersion = $ENV:Version
if($ReportedVersion -ge $ENVVersion){
	write-DRRMAlert "Healthy. Minimum version has been met. Reported version is $ReportedVersion. Minimum version is $ENV:Version"
	exit 0
}else{
	write-DRRMAlert "Not healthy - Reported version is $ReportedVersion. Minimum version is $ENV:Version"
	exit 1
}