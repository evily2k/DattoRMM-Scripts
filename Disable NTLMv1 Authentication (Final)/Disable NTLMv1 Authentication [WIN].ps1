<#
TITLE: Disable IE AutoFill Form [WIN]
PURPOSE: Script to disable the autofill feature in IE
CREATOR: Dan Meddock
CREATED: 14MAR2022
LAST UPDATED: 27APR2022
#>

# Main
Try{
	# Checks if EnableNTLMv1 = "True" and if so then it deletes the regkey
	if ($env:EnableNTLMv1 -eq "True"){
		write-host "Removing registry key that disables NTLMv1"
		Remove-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\Lsa -Name "LmCompatibilityLevel"
	}else{
		# Create registry key to disable Auto Form Fill
		write-host "Adding registry key that disables NTLMv1"
		reg add HKLM\SYSTEM\CurrentControlSet\Services\Lsa /f /v LmCompatibilityLevel /t REG_DWORD /d 5
	}
	Exit 0
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}