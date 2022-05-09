<#
TITLE: Force Windows 10 Upgrade to Newest Build [WIN]
PURPOSE: Runs the Windows Update Assistant and forces it to upgrade to the latest Windows build
CREATOR: Dan Meddock
CREATED: 09DEC2021
LAST UPDATED: 09MAY2022
#>

# Debug
#Set-PSDebug -Trace 2

# Disabled power settings that could prevent fom completing
powercfg.exe -x -disk-timeout-ac 0
powercfg.exe -x -disk-timeout-dc 0
powercfg.exe -x -standby-timeout-ac 0
powercfg.exe -x -standby-timeout-dc 0
powercfg.exe -x -hibernate-timeout-ac 0
powercfg.exe -x -hibernate-timeout-dc 0

# Funtion for logging errors
function Write-Log { 
    [CmdletBinding()] 
    param ( 
        [Parameter(Mandatory)] 
        [string]$Message
    ) 
      
    try { 
        if (!(Test-Path -path ([System.IO.Path]::GetDirectoryName($LogFilePath)))) {
            New-Item -ItemType Directory -Path ([System.IO.Path]::GetDirectoryName($LogFilePath))
        }
        $DateTime = Get-Date -Format G
        Add-Content -Value "$DateTime - $Message" -Path $LogFilePath
		Write-Host "$DateTime - $Message"
    } 
    catch { 
        Write-Error $_.Exception.Message 
		Write-Host $_.Exception.Message
    } 
}

# Function to check if script is running as a admin user
Function CheckIfElevated() {
    Write-Log "Info: Checking for elevated permissions..."
    if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
                [Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Log "ERROR: Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
        return $false
    }
    else {
        Write-Log "Info: Code is running as administrator — go on executing the script..."
        return $true
    }
}

# Main
try {
    # Declarations
    [string]$DownloadDir = 'C:\temp\Windows_FU\packages'
    [string]$LogDir = 'C:\temp\Windows_FU\Logs'
    [string]$LogFilePath = [string]::Format("{0}\{1}_{2}.log", $LogDir, "$(get-date -format `"yyyyMMdd_hhmmsstt`")", $MyInvocation.MyCommand.Name.Replace(".ps1", ""))
    [string]$Url = 'https://go.microsoft.com/fwlink/?LinkID=799445'
    [string]$UpdaterBinary = "$($DownloadDir)\Win10Upgrade.exe"
    [string]$UpdaterArguments = '/quietinstall /skipeula /auto upgrade /copylogs $LogDir'
	# Install all windows updates silently but dont force reboot
	#[string]$UpdaterArguments = '/quietinstall /skipeula /copylogs $LogDir'
    [System.Net.WebClient]$webClient = New-Object System.Net.WebClient
	$freespace = (Get-CimInstance CIM_LogicalDisk -Filter "DeviceId='C:'").FreeSpace
	$timeSpan = New-TimeSpan -Minutes 59 -Seconds 30	
 
    # Writes computer and user info to log
    Write-Log -Message ([string]::Format("Info: Script init - User: {0} Machine {1}", $env:USERNAME, $env:COMPUTERNAME))
    Write-Log -Message ([string]::Format("Current Windows Version: {0}", [System.Environment]::OSVersion.ToString()))
     
    # Check if script is running as admin and elevated  
    if (!(CheckIfElevated)) {
        Write-Log -Message "ERROR: Will terminate!"
        break
    }
	# Checks for at least 20GB free space available on the C drive
	if (!($freespace -gt 20GB)){
		Write-Log -Message ([string]::Format("C: has less than 20GB free space; cancelling update"))
		Write-Log -Message ([string]::Format("$($('{0:N2}' -f ($freespace/1gb)))GB free space available."))
		Exit 1
	}
    # Check if folders exis
    if (!(Test-Path $DownloadDir)) {
        New-Item -ItemType Directory -Path $DownloadDir
    }
    if (!(Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir
    }
    if (Test-Path $UpdaterBinary) {
        Remove-Item -Path $UpdaterBinary -Force
    }
    # Download the Windows Update Assistant
    Write-Log -Message "Attempting to download Windows Update Assistant.."
    $webClient.DownloadFile($Url, $UpdaterBinary)
 
    # If the Update Assistant exists -> create a process with argument to initialize the update process
    if (Test-Path $UpdaterBinary) {
		# Run a timer for the whole process
		$timer =  [system.diagnostics.stopwatch]::StartNew()
		Write-Log -Message "Running Windows Update Assistant to download and install updates."
        Start-Process -FilePath $UpdaterBinary -ArgumentList $UpdaterArguments -NoNewWindow -Wait -PassThru
		$timer.Stop()
			if ($timeSpan -gt $timer.Elapsed){
				Write-Log -Message "Windows Update Assistant ran for less than an hour; Upgrade failed most likely."
				Exit 1
			}
		Write-Log -Message "Update finished in $($timer.Elapsed.Hours) hours and $($timer.Elapsed.minutes) minutes."
		Write-Log -Message "Rebooting device to finish update."
		Exit 0
	}
    else {
        Write-Log -Message ([string]::Format("ERROR: File {0} does not exist!", $UpdaterBinary))
        Exit 1
    }	
}
catch {
    Write-Log -Message $_.Exception.Message 
    Write-Error $_.Exception.Message
}