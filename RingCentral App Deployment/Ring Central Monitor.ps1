$ringCentralCheck = ("HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") | % {gci -Path $_ | % {get-itemproperty $_.pspath} | ? {$_.DisplayName -match "RingCentral"}}
If($ringCentralCheck -ne $NULL){
	write-host '<-Start Result->'
 	write-host "STATUS=Installed"
 	write-host '<-End Result->'
	Exit 0
}Else{
	write-host '<-Start Result->'
 	write-host "STATUS=Uninstalled"
 	write-host '<-End Result->'			
	Exit 1
}