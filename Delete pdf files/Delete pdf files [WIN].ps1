<#
TITLE: Delete pdf files [WIN]
PURPOSE: Deletes pfd files that are older that three days old from the directories specified in the $paths variable
CREATOR: Dan Meddock
CREATED: 15JUN2022
LAST UPDATED: 20JUN2022
#>

# Declarations
$paths = @("C:\users\*\Downloads",
	"C:\Users\*\AppData\Local\Microsoft\Windows\INetCache",
	"C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files",
	"C:\WINDOWS\TEMP"
	)

# Main
Try{
	foreach ($path in $paths){
		Get-ChildItem -Recurse -filter "*.pdf" $path | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-3)} | remove-item -force -verbose
	}
}Catch{
	Write-Host $_.Exception.Message
}