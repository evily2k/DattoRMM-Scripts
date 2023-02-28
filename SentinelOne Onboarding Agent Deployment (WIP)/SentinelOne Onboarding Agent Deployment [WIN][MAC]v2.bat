#!/bin/bash

@echo off
goto WindowsSection

installer="SentinelOne Installer"
appPath="/Library/Sentinel/sentinel-agent.bundle/Contents/MacOS/SentinelAgent.app/"
packageName="SentinelAgent_macos.pkg"
exitcode=0
if [ -z $SentinelOneDeployment ]
then
	echo "- Sentinel One Group Token not set at the site level. Exiting&"
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
set "sentinelInstaller=SentinelInstaller_windows_64bit.msi"

wmic product get name | findstr /R /C:"Sentinel[ ]Agent"
if %ERRORLEVEL% == 0 goto :installed
if NOT EXIST %tempFolder% mkdir %tempFolder%
if NOT DEFINED SentinelOneDeployment (
  echo "SentinelOneDeployment site token not defined"
  exit 1
)
set /a "exitcode=0"
set "sentinelToken=!SentinelOneDeployment!"
move %sentinelInstaller% C:\temp\SentinelOne.msi
echo move %sentinelInstaller% C:\temp\SentinelOne.msi
msiexec.exe /I C:\temp\SentinelOne.msi /q /norestart UI=false SITE_TOKEN=!sentinelToken! /l*v C:\temp\SentinelOneInstallLog.txt
echo msiexec.exe /I C:\temp\SentinelOne.msi /q /norestart UI=false SITE_TOKEN=!sentinelToken! /l*v C:\temp\SentinelOneInstallLog.txt
echo "Installing Sentinel One using !CS_PROFILE_NAME! Site Token."
echo !sentinelToken!
timeout 10
type C:\temp\SentinelOneInstallLog.txt
set errorlevel=0
type C:\temp\SentinelOneInstallLog.txt | findstr /R /C:"Product: Sentinel Agent -- Installation failed." && echo SentinelOne failed to install. Check log for more details (C:\temp\SentinelOneInstallLog.txt). && Exit 1	
echo SentinelOne install completed without errors.
exit 0

:installed
echo "SentinelOne is already installed. Exiting.."
Exit 1