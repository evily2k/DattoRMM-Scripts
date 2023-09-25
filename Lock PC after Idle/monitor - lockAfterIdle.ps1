if (Get-ScheduledTask "logoffAfterIdle" -ErrorAction SilentlyContinue){
	write-host '<-Start Result->'
 	write-host "STATUS=Enabled"
 	write-host '<-End Result->'
	exit 0
}else{
	write-host '<-Start Result->'
 	write-host "STATUS=Disabled"
 	write-host '<-End Result->'			
	exit 1
}