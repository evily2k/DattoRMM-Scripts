if(get-ScheduledTask -taskname "DisableWiFiandBluetooth" -erroraction silentlycontinue){
	write-host '<-Start Result->'
	write-host "STATUS=Disabled"
	write-host '<-End Result->'
	exit 0
}else{
	write-host '<-Start Result->'
 	write-host "STATUS=Enabled"
 	write-host '<-End Result->'			
	exit 1
}