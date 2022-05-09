#!/bin/bash

#Searching for application via the appPath listed below
installer="SentinelOne Installer"
appPath="/Library/Sentinel/sentinel-agent.bundle/Contents/MacOS/SentinelAgent.app/"

if [[ -e $appPath ]]; then
echo "$appPath was found. Exiting…"
exit 0
else
echo "$appPath was not found, running $installer"
exit 1
fi

#!/bin/bash

if [ -z $SentinelOneDeployment ]
then
	echo "- Sentinel One Group Token not set at the site level."
else
	echo "- Sentinel One Group Token found for $CS_PROFILE_NAME."
	varSplashKey=$SentinelOneDeployment
fi
echo "site token check: $SentinelOneDeployment"
mkdir ./tmp 
echo "$SentinelOneDeployment" > ./tmp/com.sentinelone.registration-token.txt
echo "Starting Sentinel Install."
pwd
mv 
/usr/sbin/installer -pkg SentinelAgent_macos_v21_12_2_6003.pkg -target /Library