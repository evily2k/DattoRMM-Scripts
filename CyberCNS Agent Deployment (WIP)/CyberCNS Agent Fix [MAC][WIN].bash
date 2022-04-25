#!/bin/bash

@echo off
goto WindowsSection

export PATH=$PATH:/usr/local/bin
source ~/.profile 

exitcode=0

sudo launchctl unload  -w /Library/LaunchDaemons/com.CyberCNSAgentV2.AgentService.plist;sudo /opt/CyberCNSAgentV2/cybercnsagentv2_darwin -u ;sudo launchctl load  -w /Library/LaunchDaemons/com.CyberCNSAgentV2.AgentService.plist

exit $exitcode

:WindowsSection
SetLocal EnableDelayedExpansion

net stop cybercnsagentv2 & "c:\Program Files (x86)\CyberCNSAgentV2\cybercnsagentv2.exe" -u & net start cybercnsagentv2

Exit -0