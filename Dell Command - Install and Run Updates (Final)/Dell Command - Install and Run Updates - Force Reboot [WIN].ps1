<#
TITLE: Dell Command - Install and Ran Updates - Force Reboot[WIN]
PURPOSE: Installs Dell Command vias chocolatey, runs scan for updates, suspends bitlocker, installs updates, if a reboot is required it will reboot after the installation completes.
CREATOR: Dan Meddock
CREATED: 10DEC2021
LAST UPDATED: 23MAR2023
#>

# Log Get-ChocoApps output to log file
Start-Transcript -Path "C:\temp\installUpdateDCU.log"

# Declarations
# Add any Chocolatey supported applications to this list to be installed
$app = 'dellcommandupdate'

# Enable script execution
Set-ExecutionPolicy Bypass -Scope Process -Force

# Download and install Chocolatey
function InstallChoco {
    $bool = 0
    Try {
        if (!(Test-Path($env:ChocolateyInstall + "\choco.exe"))) {
			iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
        }
    }Catch{
        Write-Host $($_.Exception.Message)
    }
}

# Installs the application using Chocolatey
function InstallDCU {
	Try{
		if ($app -ne " ") {
			$app.Split(" ") | % {
				if (!($_ -like " ") -and $_.length -ne 0) {
					Write-Host Installing $_ 
					& cmd /c """$env:ChocolateyInstall\choco.exe"" install $_ -y"
				}
			}
		} else {
			$VersionChoco = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($env:ChocolateyInstall + "\choco.exe").ProductVersion
			Write-Host Installing
			Write-Host Chocolatey v$VersionChoco
			Write-Host Package name is required. Please pass at least one package name to install.`n
		}
	}Catch{
		Write-Host $($_.Exception.Message)
	}
}

# Function to run and install Dell Command updates
Function updateDell {
	# Locate dcu-cli.exe and start the Dell Command and Update process
	Try{
		# Download direcotry and DCU-CLI variables
		$logFile = "C:\temp\dellUpdate.log"
		$druLocation64 = "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe"
		$druLocation32 = "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe"
		
		if (($druLocation64) -or ($druLocation32)){
			# Find dcu-cli.exe programfile location
			if (test-path -path $druLocation32 -pathtype leaf){$druDir = $druLocation32}else{$druDir = $druLocation64}		
			# Start Dell Command update process; apply all updates and ignore reboot; suspend bitlocker if detected and output log to C:\temp
			write-host "Running Dell Command and Update to update dell drivers."
			start-process -NoNewWindow $druDir -ArgumentList "/applyUpdates -silent -reboot=enable -autoSuspendBitLocker=enable -outputLog=$logFile" -Wait
			get-content $logFile
			sleep 5
			Remove-Item $logFile -Force
		}else{
			# Dell Command Update was not found on this device
			write-host "Dell Command Update is not installed on this computer."
			Write-host "Skipping Dell Command Update."
		}
	}Catch{
		# Catch any powershell errors and output the error message
		write-host $_.Exception.Message
	}
}

# Main

# Enable TLS 1.2 security protocol
try {
	[Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)
} catch [system.exception] {
	write-host "- ERROR: Could not implement TLS 1.2 Support."
	write-host "  This can occur on Windows 7 devices lacking Service Pack 1."
	write-host "  Please install that before proceeding."
}

# Start the Chocolatey install/update
InstallChoco

# Install Dell Command Update via Chocolatey
InstallDCU

# Run DCU and install updates and force a reboot if needed
updateDell

Stop-Transcript
Exit 0
