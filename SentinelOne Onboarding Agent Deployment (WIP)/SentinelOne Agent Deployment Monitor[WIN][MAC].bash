#!/bin/bash
@echo off
goto WindowsSection

if ls /Applications | grep SentinelOne
then
	echo "<-Start Result->"
	echo "SentinelOne=Installed."
	echo "<-End Result->"
	exit 0
else
	echo "<-Start Result->"
	echo "SentinelOne=Not Installed."
	echo "<-End Result->"
	exit 1
fi


:WindowsSection
SetLocal EnableDelayedExpansion

wmic product get name | findstr /R /C:"Sentinel[ ]Agent"
if %ERRORLEVEL%==1 goto itfailed

goto endit

:itfailed
echo "<-Start Result->"
echo "SentinelOne=Not Installed."
echo "<-End Result->"
exit 1

:endit
echo "<-Start Result->"
echo "SentinelOne=Installed."
echo "<-End Result->"
exit 0