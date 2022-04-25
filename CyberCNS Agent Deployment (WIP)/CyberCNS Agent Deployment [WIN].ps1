<#
TITLE: CyberCNS Agent Deployment [WIN]
PURPOSE: Script to deploy CyberCNS to Windows computers
CREATOR: Dan Meddock
CREATED: 14FEB2022
LAST UPDATED: 25APR2022
#>

# Declarations
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$source = 'https://mysitename.mycybercns.com/agents/ccnsagent/cybercnsagent.exe'
$destination = 'cybercnsagent.exe'

# Verify site variable is set at the site level
$companyID = $env:cybercnscompanyid
$clientID = $env:cybercnsclientid
$clientSecret = $env:cybercnsclientsecret
$CNSDomain = $env:cybercnsdomain
$agentType = $env:agentType

# Main
Try{
	# Check if CCNS variable set in Datto site variables
	If(!($companyID)){
		write-host "No CCNS site variable set"
		Exit 1
	}
	Write-host "Downloading CyberCNS agent..."
	Invoke-WebRequest -Uri $source -OutFile $destination 
	If($CS_PROFILE_NAME){
	Write-host "Installing CyberCNS $agentType agent for $CS_PROFILE_NAME ..."
	}Else{Write-host "Installing CyberCNS $agentType agent..."}
	./cybercnsagent.exe -c $companyID -a $clientID -s $clientSecret -b $CNSDomain -i $agentType
	Exit 0
}catch{
	Write-Error $_.Exception.Message 
	Exit 1
}