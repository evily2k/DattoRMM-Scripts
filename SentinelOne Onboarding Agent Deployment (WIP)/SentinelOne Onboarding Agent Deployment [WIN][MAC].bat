#!/bin/bash

@echo off
goto WindowsSection

installer="SentinelOne Installer"
appPath="/Library/Sentinel/sentinel-agent.bundle/Contents/MacOS/SentinelAgent.app/"
packageName="SentinelAgent_macos_v21_12_2_6003.pkg"
exitcode=0
if [ -z $SentinelOneDeployment ]
then
	echo "- Sentinel One Group Token not set at the site level. Exiting…"
	Exit -1
else
	echo "- Sentinel One Group Token found for $CS_PROFILE_NAME."
fi
if [[ -e $appPath ]]; then
	echo "$appPath is already installed. Exiting..."
	exit -1
else
	echo "$appPath was not found, running $installer"
	echo "$SentinelOneDeployment" > /var/tmp/"com.sentinelone.registration-token"
	cp $packageName /var/tmp/SentinelOneInstaller.pkg
	/usr/sbin/installer -pkg /var/tmp/SentinelOneInstaller.pkg -target /Library
	exit -0
fi
exit $exitcode

:WindowsSection
SetLocal EnableDelayedExpansion

set "tempFolder=C:\Temp"
set "sentinelInstaller=SentinelInstaller_windows_64bit_v21_7_2_1038.msi"

wmic product get name | findstr /R /C:"Sentinel[ ]Agent"
if %ERRORLEVEL% == 0 goto :installed
if NOT EXIST %tempFolder% mkdir %tempFolder%
if NOT DEFINED SentinelOneDeployment (
  echo "SentinelOneDeployment site token not defined"
  exit -1
)
set /a "exitcode=0"
set "sentinelToken=!SentinelOneDeployment!"
move %sentinelInstaller% C:\temp\SentinelOne.msi
echo move %sentinelInstaller% C:\temp\SentinelOne.msi
msiexec.exe /I C:\temp\SentinelOne.msi /q /norestart UI=false SITE_TOKEN=!sentinelToken!
echo msiexec.exe /I C:\temp\SentinelOne.msi /q /norestart UI=false SITE_TOKEN=!sentinelToken!
echo "Installing Sentinel One using !CS_PROFILE_NAME! Site Token."
echo !sentinelToken!
Exit -0

:installed
echo "SentinelOne is already installed. Exiting.."
Exit -1