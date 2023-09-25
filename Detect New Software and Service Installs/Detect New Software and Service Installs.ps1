# Define the paths for storing previous state
$AppListPath = "C:\Monitoring\PreviousAppList.txt"
$ServiceListPath = "C:\Monitoring\PreviousServiceList.txt"

Install-Module -Name BurntToast -Force -Scope CurrentUser

# Function to get a list of installed applications
Function Get-InstalledApplications {
    try {
        Get-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select-Object DisplayName
    } catch {
        Write-Error "Error retrieving installed applications: $_"
        return @()
    }
}

# Function to get a list of running services
Function Get-RunningServices {
    try {
        Get-Service | Select-Object DisplayName
    } catch {
        Write-Error "Error retrieving running services: $_"
        return @()
    }
}

# Function to compare two lists and find differences
Function Compare-Lists ($oldList, $newList) {
    Compare-Object $oldList $newList
}

Try{
	# Load the previous lists if they exist
	$PreviousAppList = @()
	$PreviousServiceList = @()

	if (Test-Path $AppListPath) {
		try {
			$PreviousAppList = Get-Content $AppListPath
		} catch {
			Write-Error "Error loading previous application list: $_"
		}
	}

	if (Test-Path $ServiceListPath) {
		try {
			$PreviousServiceList = Get-Content $ServiceListPath
		} catch {
			Write-Error "Error loading previous service list: $_"
		}
	}

	# Get the current lists of installed applications and running services
	$CurrentAppList = Get-InstalledApplications | ForEach-Object { $_.DisplayName }
	$CurrentServiceList = Get-RunningServices | ForEach-Object { $_.DisplayName }

	# Compare the current lists with the previous ones
	$NewApps = Compare-Lists $PreviousAppList $CurrentAppList
	$NewServices = Compare-Lists $PreviousServiceList $CurrentServiceList

	# Update the previous lists with the current ones
	try {
		$CurrentAppList | Out-File $AppListPath
		$CurrentServiceList | Out-File $ServiceListPath
	} catch {
		Write-Error "Error updating previous lists: $_"
	}

	# Check if there are new applications or services and send alerts if needed
	if ($NewApps) {
		$NewApps | ForEach-Object {
			Write-Host "New Application Installed: $_"
			# Send an alert (e.g., email, log entry, etc.)
		}
	}

	if ($NewServices) {
		$NewServices | ForEach-Object {
			Write-Host "New Service Added: $_"
			# Send an alert (e.g., email, log entry, etc.)
		}
	}
}Catch{
	$err = $_.Exception.Message
    Write-Output $err | timestamp
}