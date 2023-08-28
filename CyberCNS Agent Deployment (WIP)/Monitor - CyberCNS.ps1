# Function to test if registry key exists
Function Test-ServiceStatus ($service) {
     if (get-service -name $service -ErrorAction Ignore) {
         $true
     } else {
         $false
     }
 }
 
 #Declarations
$service = 'CyberCNSAgentV2'
$serviceCheck = Test-ServiceStatus $service

# Main
# Verify service exists and get sservice status
if($serviceCheck){
	$serviceRunning = (get-service -name $service).status
	if($serviceRunning -eq "Running"){
		write-host '<-Start Result->'
		write-host "STATUS=Running"
		write-host '<-End Result->'
		exit 0
	}else{
		write-host '<-Start Result->'
		write-host "STATUS=Stopped"
		write-host '<-End Result->'			
		exit 1
	}
}else{
	write-host '<-Start Result->'
	write-host "STATUS=Not Installed"
	write-host '<-End Result->'			
	exit 1
}