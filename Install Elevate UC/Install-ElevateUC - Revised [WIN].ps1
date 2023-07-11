<#
TITLE: Install-ElevateUC - Revised [WIN]
PURPOSE: This script will kill all Elevate UC processes. Uninstalls Elevate if it's installed in AppData. Then it downloads the latest Elevate UC application. Once downloaded it will start the Elevate UC install silently. After the install it adds a shortcut to the desktop and start menu.
CREATOR: Dan Meddock
CREATED: 05APR2023
LAST UPDATED: 02JUL2023
#>

# Declarations
$workingDir = "C:\Temp"
$downloadURL = "https://cp.serverdata.net/voice/pbx/softphonereleases/default/latest-win/elevate-uc-x64.msi"
$elevateInstaller = "C:\temp\elevate-uc-x64.msi"

# Main
try {
    # Checks if Elevate UC processes are running and if so it will stop them
    $elevateProcess = Get-Process -Name "Elevate UC" -ErrorAction SilentlyContinue
	if ($elevateProcess){$elevateProcess | Stop-Process -Force}

    # Clean up old installation files
    if (Test-Path $elevateInstaller){Remove-Item -Path $elevateInstaller -Force}

    # Check for Elevate UC installed in User AppData and uninstall if found
    $users = Get-ChildItem -Path C:\Users -Directory
    foreach ($user in $users){
        $appDataDir = Join-Path -Path $user.FullName -ChildPath "AppData\Local\Programs\Elevate UC"
        $programFilesDir = "C:\Program Files\Elevate UC\Uninstall Elevate UC.exe"
        if (Test-Path $appDataDir){
            # Attempts to uninstall Elevate UC from the AppData directory
            Write-Host "Found AppData installation for $($user.Name)."
            Write-Host "Attempting to uninstall Elevate UC from the user directory."
            Start-Process -FilePath "$appDataDir\Uninstall Elevate UC.exe" -ArgumentList "/S" -Wait
        }
        if (Test-Path $programFilesDir){
            # Attempts to uninstall Elevate UC from the Program Files directory
            Write-Host "Found Program Files installation for $($user.Name)."
            Write-Host "Attempting to uninstall Elevate UC from the Program Files directory."
            Start-Process -FilePath $programFilesDir -ArgumentList "/allusers /S" -Wait
        }
    }

    # Check if the Temp folder exists; if not, create it
    if (!(Test-Path $workingDir -PathType Container)){New-Item -Path $workingDir -ItemType Directory -Force | Out-Null}

    # Download the latest Elevate UC MSI installer
    Write-Host "Downloading the latest version of the Elevate UC application."
    Invoke-WebRequest -OutFile $elevateInstaller -Uri $downloadURL

	# Determine if this is an updgrade or install
	if (!(Test-Path -path "C:\Program Files\Elevate UC")){$installType = "Installing"}else{$installType = "Updating"}
	
    # Start Elevate UC installation silently
    Write-Host "$installType the latest version of Elevate UC."
    Start-Process -FilePath msiexec -ArgumentList "/I `"$elevateInstaller`" /qn" -Wait

    # Set shortcut paths
    $appPath = "C:\Program Files\Elevate UC\Elevate UC.exe"
    $scPath = "$([Environment]::GetFolderPath('CommonDesktopDirectory'))\Elevate UC.lnk"
    $smPath = "$([Environment]::GetFolderPath('CommonPrograms'))\Elevate UC.lnk"

    # Create a shortcut for the application on the Desktop
    Write-Host "Creating a desktop shortcut and start menu entry for Elevate UC."
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($scPath)
    $Shortcut.TargetPath = $appPath
    $Shortcut.Arguments = "-show"
    $Shortcut.Save()
	
	# Output install/update was successful
	if ($installType -eq "Installing"){$installType = "installation"}else{$installType = "update"}
	Write-Host "Elevate UC $installType completed successfully."

} catch {
    # Output any errors that are generated
    Write-Error $_.Exception.Message
}

Exit 0