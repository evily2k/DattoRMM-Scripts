#!/bin/bash

@echo off
goto WindowsSection

export PATH=$PATH:/usr/local/bin
source ~/.profile 

exitcode=0

if [ -z $cybercnscompanyid ]
then
	echo "- CyberCNS Company ID not set at the site level. Has the site been imported to CyberCNS?"
	echo "Exiting script..."
	Exit -1
else
	if ls /Applications | grep nmap
	then
		echo "Nmap detected, starting CyberCNS install."
	else
		echo "Nmap not found; Installing Nmap."
		curl -k https://nmap.org/dist/nmap-7.92.dmg -O
		hdiutil attach nmap-7.92.dmg
		sudo installer -pkg /Volumes/nmap-7.92/nmap-7.92.mpkg -target "/"
		hdiutil detach /Volumes/nmap-7.92
	fi
	echo "- CyberCNS Company ID found for $CS_PROFILE_NAME; Downloading CCNS agent."
	curl -k https://kandeconsultingv2.mycybercns.com/agents/ccnsagent/cybercnsagent_darwin -O
	chmod +x cybercnsagent_darwin
	echo "Installing CyberCNS agent ($agentType)." 
	sudo ./cybercnsagent_darwin -c $cybercnscompanyid -a $cybercnsclientid -s $cybercnsclientsecret -b $cybercnsdomain -i $agentType
fi
exit $exitcode

:WindowsSection
SetLocal EnableDelayedExpansion

set "tempFolder=C:\Temp"
tasklist | FINDSTR /I "cybercnsagentv2.exe"

if %ERRORLEVEL% == 0 goto :installed
if NOT EXIST %tempFolder% mkdir %tempFolder%
if NOT DEFINED cybercnscompanyid (
  echo "CyberCNS Company ID not set at the site level. Has the site been imported to CyberCNS?"
  exit -1
)
set /a "exitcode=0"
set url="https://%SITEURL%.mycybercns.com/agents/ccnsagent/cybercnsagent.exe"
set file="C:\temp\cybercnsagent.exe"
set "cybercnscompanyid=!cybercnscompanyid!"
set "cybercnsclientid=!cybercnsclientid!"
set "cybercnsclientsecret=!cybercnsclientsecret!"
set "cybercnsdomain=!cybercnsdomain!"
set "agentType=!agentType!"
if NOT DEFINED CS_PROFILE_NAME (
	echo "Downloading CyberCNS agent..."
) else (
	echo "Downloading CyberCNS agent for !CS_PROFILE_NAME!"
)
certutil -urlcache -split -f %url% %file%
cd %tempFolder%
.\cybercnsagent.exe -c %cybercnscompanyid% -a %cybercnsclientid% -s %cybercnsclientsecret% -b %cybercnsdomain% -i %agentType%
Exit -0

:installed
echo "CyberCNS is already running. Exiting.."
Exit -1