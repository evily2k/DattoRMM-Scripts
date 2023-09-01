if((test-path "C:\ProgramData\{4CEC2908-5CE4-48F0-A717-8FC833D8017A}") -and (Get-Service tsvchst -erroraction silentlycontinue)){
	write-host '<-Start Result->'
	write-host "STATUS=Installed."
	write-host '<-End Result->'
	exit 0
}else{
	write-host '<-Start Result->'
 	write-host "STATUS=Not Installed"
 	write-host '<-End Result->'			
	exit 1
}