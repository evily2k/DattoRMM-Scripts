try{
	$paths = @("C:\users\*\Downloads",
		"C:\Users\*\AppData\Local\Microsoft\Windows\INetCache",
		"C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files",
		"C:\temp")
		
	foreach ($path in $paths){
		Get-ChildItem -Recurse -filter "*.pdf" $path | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-3)} | remove-item -force -verbose
	}
}catch{
	write-host $_.Exception.Message
}