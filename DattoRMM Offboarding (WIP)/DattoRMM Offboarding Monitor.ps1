if (Get-ScheduledTask "Datto Offboarding" -ErrorAction SilentlyContinue){
	write-host '<-Start Result->'
 	write-host "STATUS=Installed"
 	write-host '<-End Result->'
	exit 0
}else{
	write-host '<-Start Result->'
 	write-host "STATUS=Not Installed"
 	write-host '<-End Result->'			
	exit 1
}