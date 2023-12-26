<#
TITLE: Install Encompass 360 SmartClient [WIN]
PURPOSE: Installs all the prerequisite applications and any Windows features, then it installs the SmartClient software, then it applies the Client ID, Server URL, and enables Autostart.
CREATOR: Dan Meddock
CREATED: 22NOV2022
LAST UPDATED: 26DEC2023
#>

# Log Windows Updates output to log file
Start-Transcript -Path "C:\temp\EncompassInstall.log"

# Declarations
$tempFolder = "C:\Temp"
$encompassZip = 'Encompass.zip'
$clientID = "XXXXXXXXXX"
$serverURL = "https://hosted.elliemae.com"
$autoStart = "1"
$encompassZipPath = $tempFolder + "\" + $encompassZip
$encompassPath = $encompassZipPath -replace ".zip",""
$preReq ='adobereader'

# Registry paths
$encompassReg = @(
   'HKLM:\SOFTWARE\Ellie Mae\SmartClient\C:/SmartClientCache/Apps/Ellie Mae/Encompass',
    'HKLM:\SOFTWARE\Wow6432Node\Ellie Mae\SmartClient\C:/SmartClientCache/Apps/Ellie Mae/Encompass'
)

Set-ExecutionPolicy Bypass -Scope Process -Force

# Set TLS settings
try {
	[Net.ServicePointManager]::SecurityProtocol = [Enum]::ToObject([Net.SecurityProtocolType], 3072)
} catch [system.exception] {
	write-host "- ERROR: Could not implement TLS 1.2 Support."
	write-host "  This can occur on Windows 7 devices lacking Service Pack 1."
	write-host "  Please install that before proceeding."
}

# Function to install prerequisite applications via Chocolatey
function InstallChocoApp {
	Try{
		# Install or update the Chocolatey software management tool
		if (!(Test-Path($env:ChocolateyInstall + "\choco.exe"))) {iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))}
		& cmd /c """$env:ChocolateyInstall\choco.exe"" install $app -y --force"
	}Catch{
		Write-Host $($_.Exception.Message)
	}
}

# Add registry keys for either 64 or 32 bit
function addRegistryKeys {
	foreach ($Path in $encompassReg) {
		if (Test-Path $Path) {
			New-ItemProperty -LiteralPath $Path -Name 'AuthServerURL' -PropertyType String -Value $serverURL
			New-ItemProperty -LiteralPath $Path -Name 'SmartClientIDs' -PropertyType String -Value $clientID
			New-ItemProperty -LiteralPath $Path -Name 'AutoSignOn' -PropertyType String -Value $autoStart
		}
	}
}

# Uses VCredist PS module to uninstall all versions of VCredist
function uninstallVCredist {
	Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
	Install-Module -name VcRedist -force -Confirm:$false
	Uninstall-VcRedist -Confirm:$false
}

# Creates a desktop and start menu shortcut
Function addShortcut {
	$appPath = '"C:\SmartClientCache\Apps\Ellie Mae\Encompass\AppLauncher.exe"'
	$scPath = "C:\Users\Public\Desktop\Encompass.lnk"
	$smPath = "C:\Users\All Users\Start Menu\Encompass.lnk"
	$WshShell = New-Object -comObject WScript.Shell
	$Shortcut = $WshShell.CreateShortcut($scPath)
	$Shortcut.TargetPath = $appPath
	$Shortcut.IconLocation = "C:\SmartClientCache\Apps\Ellie Mae\Encompass\App.ico,0"
	$Shortcut.Save()
	cp $scPath $smPath
}

Try{
	
	# Check if Temp folder exists
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}

	# Uninstall all versions of VCredist before starting SmartClient install
	Write-Host "Uninstall all versions of Visual C++ Redistributable"
	uninstallVCredist
	Sleep 10
	
	# Install prerequisite applications via Chocolatey
	Write-Host "Installing Adobe Reader DC..."
	Foreach ($app in $preReq){InstallChocoApp}
	sleep 10
	
	# Enabled DontNet3.5 and NetFx3 (prerequisite) via DISM
	Write-Host "Enabling DotNet3.5 feature which contains DotNet2.0 and NetFx3"
	DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /NoRestart
	sleep 10
	
	# Extract zip folder contents
	Write-Host "Downloading and extracting SmartClient install components."
	Copy-Item $encompassZip -Destination $tempFolder -force
	Expand-Archive -literalpath $encompassZipPath -DestinationPath $tempFolder	
	
	# Change working directory to the extracted Encompass folder
	set-location $encompassPath	
	
	# Install VCredist from installer
	Write-Host "Installing Visual C++ Redistributable 2015 U3..."
	start-process .\VC2015U3\vc_redist.x86.exe -argumentlist "/s" -Wait -NoNewWindow
	Sleep 10
	
	# Install Amyuni PDF Converter
	Write-Host "Installing Amyuni PDF Converter..."
	start-process .\PdfConverter\InstallPdfConverter.exe -argumentList "-s" -Wait -NoNewWindow
	Sleep 10
	
	# Install Encompass Document Converter
	Write-Host "Installing Encompass Document Converter..."
	start-process .\BlackIce\DocumentConverter.exe -argumentList "/s" -Wait -NoNewWindow
	sleep 10
	
	# Install Encompass eFolder Printer
	Write-Host "Installing Encompass eFolder Printer..."
	start-process .\EPDInstaller\EPDInstaller.exe -argumentList "/qn /norestart" -Wait -NoNewWindow
	sleep 10
	
	# Install SmartClient Core
	Write-Host "Installing SmartClient Core..."
	start-process .\sccoreinstaller\sccoreinstaller.exe -argumentList "/qn /norestart" -Wait -NoNewWindow
	Sleep 10
	
	# Install Encompass SmartClient
	Write-Host "Installing Encompass SmartClient..."
	start-process .\encsc\encsc.exe -argumentList "/qn /norestart" -Wait -NoNewWindow
	Sleep 10
	
	# Add registry keys for either 64 or 32 bit
	Write-Host "Adding registry keys for ClientID, Autostart, and Server URL..."
	addRegistryKeys
	Sleep 10
	
	# Create desktop and start menu shortcuts
	Write-Host "Creating shortcuts for Encompass in the start menu and the public desktop."
	addShortcut
	
}catch{
	Write-Host $($_.Exception.Message)
	Exit 1
}

# Stop transcript logging
Stop-Transcript
Exit 0