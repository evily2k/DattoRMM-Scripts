if(test-path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\systemreset.exe"){
		write-host '<-Start Result->'
		write-host "STATUS=Disabled"
		write-host '<-End Result->'
		Exit 0
}else{
		write-host '<-Start Result->'
		write-host "STATUS=Enabled"
		write-host '<-End Result->'
		Exit 1
}