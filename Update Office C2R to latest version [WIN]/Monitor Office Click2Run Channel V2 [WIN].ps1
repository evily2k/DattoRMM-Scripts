function write-DRRMAlert ($message){
    write-host '<-Start Result->'
    write-host "Alert=$message"
    write-host '<-End Result->'
}

$version = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentVersion
if($Version -lt "6.3"){
	write-DRRMAlert "Unsupported OS. Only Server 2012R2 or Windows 10 and up are supported."
	exit 0
}

$ReportedVersion = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -Name "VersionToReport" -erroraction silentlycontinue
$Channel = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -Name "CDNBaseUrl" -erroraction silentlycontinue

if($ReportedVersion -eq $null){
	write-DRRMAlert "Office C2R version is not installed on this device."
	exit 0
}

If(!$Channel){ 
	$Channel = "Non-C2R version or No Channel selected."
}else{
	switch ($Channel) { 
		"http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60" {$Channel = "Monthly Channel"} 
		"http://officecdn.microsoft.com/pr/64256afe-f5d9-4f86-8936-8840a6a4f5be" {$Channel = "Monthly Channel (Targeted)"} 
		"http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114" {$Channel = "Semi-Annual Channel"} 
		"http://officecdn.microsoft.com/pr/b8f9b850-328d-4355-9145-c59439a0c4cf" {$Channel = "Semi-Annual Channel (Targeted)"} 
	}
}

if($Channel -eq $ENV:Channel){
	write-DRRMAlert "Healthy. Channel set to $ENV:Channel"
}else{
	write-DRRMAlert "Not healthy - Channel set to $Channel"
	exit 1
}