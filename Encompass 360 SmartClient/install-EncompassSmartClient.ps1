<#
TITLE: Install Encompass 360 SmartClient [WIN]
PURPOSE: Installs all the prerequisite applications and any Windows features, then it installs the SmartClient software, then it applies the Client ID, Server URL, and enables Autostart.
INSTALLER: Download install .exe from elliemae.com/getencompass360 and run it to get the install files needed for this script
			Install components are extracted to %LOCALAPPDATA%\Encompass Installation\SmartClient\
			Save install components in zip folder called Encompass.zip to be used with this script
CREATOR: Dan Meddock
CREATED: 22NOV2022
LAST UPDATED: 23NOV2022
#>

# Declarations
$tempFolder = "C:\Temp"
$encompassZip = 'Encompass.zip'
$clientID = "XXXXXXXXX"
$serverURL = "https://hosted.elliemae.com"
$autoStart = "1"
$encompassZipPath = $tempFolder + "\" + $encompassZip
$encompassPath = $encompassZipPath -replace ".zip",""

# Registry paths
$encompassReg = @(
   'HKLM:\SOFTWARE\Ellie Mae\SmartClient\C:/SmartClientCache/Apps/Ellie Mae/Encompass',
    'HKLM:\SOFTWARE\Wow6432Node\Ellie Mae\SmartClient\C:/SmartClientCache/Apps/Ellie Mae/Encompass'
)

# List of prerequisite applications needed for Encompass install
$preReq = @(
	'vcredist140 --version=14.0.24215.1'
	'adobereader'
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

Try{
	# Install or update the Chocolatey software management tool
	if (!(Test-Path($env:ChocolateyInstall + "\choco.exe"))) {
		iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
	}

	# Install prerequisite applications via Chocolatey
	Foreach ($app in $preReq){InstallChocoApp}
	
	# Enabled DontNet3.5 and NetFx3 (prerequisite) via DISM
	Write-Host "Enabling DotNet3.5 feature which contains DotNet2.0 and NetFx3"
	DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
	
	# Check if Temp folder exists
	If(!(test-path $tempFolder -PathType Leaf)){new-item $tempFolder -ItemType Directory -force}

	# Transfer ZIP folder with Encompass files to device
	#Copy-Item $encompassZip -Destination $tempFolder -force
	
	# Extract zip folder contents
	Write-Host "Extracting SmartClient install components."
	Expand-Archive -literalpath $encompassZipPath -DestinationPath $tempFolder	
	
	# Change working directory to the extracted Encompass folder
	set-location $encompassPath
	
	# Install Amyuni PDF Converter
	Write-Host "Installing Amyuni PDF Converter."
	start-process .\PdfConverter\Install.exe -argumentList "-s" -wait
	
	# Install Encompass Document Converter
	Write-Host "Installing Encompass Document Converter."
	start-process .\BlackIce\DocumentConverter.exe -argumentList "/s" -wait
	
	# Install Encompass eFolder Printer
	Write-Host "Installing Encompass eFolder Printer."
	start-process .\EPDInstaller\EPDInstaller.exe -argumentList "/qn /norestart" -wait
	
	# Install SmartClient Core
	Write-Host "Installing SmartClient Core."
	start-process .\sccoreinstaller\sccoreinstaller.exe -argumentlist "/qn /norestart" -wait
	
	# Install Encompass SmartClient
	Write-Host "Installing Encompass SmartClient."
	start-process .\encsc\encsc.exe -argumentlist "/qn /norestart " -wait
	
	# Add registry keys for either 64 or 32 bit
	Write-Host "Adding registry keys for ClientID, Autostart, and Server URL."
	addRegistryKeys
	#Exit 0
}catch{
	Write-Host $($_.Exception.Message)
}