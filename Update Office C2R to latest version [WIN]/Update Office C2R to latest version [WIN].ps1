<#
TITLE: Update Office C2R to latest version [WIN]
PURPOSE: Script to update Office C2R installs and set update channel to Monthly.
CREATOR: Dan Meddock
CREATED: 22MAR2023
LAST UPDATED: 22MAR2023
#>

# Declarations
$ReportedVersion = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -Name "VersionToReport" -erroraction silentlycontinue
$Channel = (Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -Name "CDNBaseUrl") -split "/" | Select-Object -Last 1
$latestVersion = "16.0.16026.20238"

# Main
Try{
	$winVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentVersion
	if ($winVersion -lt "6.3") {
		write-host "Unsupported OS. Only Server 2012R2 and up are supported."
		exit 1
	}
	if($reportedVersion -eq $Null){
		write-host "The C2R version of office was not detected."
		exit 1
	}
	If(!$Channel){ 
		$Channel = "Non-C2R version or No Channel selected."
	}else{
		switch ($Channel) { 
			"492350f6-3a01-4f97-b9c0-c7c6ddf67d60"  { $Channel = 'Current ("Monthly")' }
			"64256afe-f5d9-4f86-8936-8840a6a4f5be"  { $Channel = "Current Preview (`"Monthly Targeted`"/`"Insiders`")" }
			"7ffbc6bf-bc32-4f92-8982-f9dd17fd3114"  { $Channel = "Semi-Annual Enterprise (`"Broad`")" }
			"b8f9b850-328d-4355-9145-c59439a0c4cf"  { $Channel = "Semi-Annual Enterprise Preview (`"Targeted`")" }
			"55336b82-a18d-4dd6-b5f6-9e5095c314a6"  { $Channel = "Monthly Enterprise" }
			"5440fd1f-7ecb-4221-8110-145efaa6372f"  { $Channel = "Beta" }
			"f2e724c1-748f-4b47-8fb8-8e0d210e9208"  { $Channel = "LTSC" }
			"2e148de9-61c8-4051-b103-4af54baffbb4"  { $Channel = "LTSC Preview" }
		}
		
		if(!($Channel -eq 'Current ("Monthly")')){
			write-host "Office C2R Update Channel is not the Current Monthly channel."
			write-host "Setting update channel to Current Monthly."
			Start-Process -WindowStyle hidden -FilePath "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe" -argumentlist "/changesetting Channel=Monthly"
		}
		
		if($ReportedVersion -lt $latestVersion){
			write-host "Office version is outdated. Updating Office to the latest build."
			Start-Process -WindowStyle hidden -FilePath "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeC2RClient.exe"  -argumentlist "/update USER displaylevel=False"
		}else{
			write-host "Office is up to date."
		}
	}
}catch{
	Write-Host $($_.Exception.Message)
}

Exit 0