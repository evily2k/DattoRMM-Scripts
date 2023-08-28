if (Get-ScheduledTask "Company Tool Removal" -ErrorAction SilentlyContinue){
	write-host '<-Start Result->'
 	write-host "STATUS=Activated"
 	write-host '<-End Result->'
	exit 0
}else{
	write-host '<-Start Result->'
 	write-host "STATUS=Deactivated"
 	write-host '<-End Result->'			
	exit 1
}