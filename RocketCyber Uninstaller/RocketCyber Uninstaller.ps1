<#
TITLE: RocketCyber Uninstaller [WIN]
PURPOSE: Uninstalls the RocketCyber agent silently
CREATOR: Dan Meddock
CREATED: 08SEP2023
LAST UPDATED: 08SEP2023
#>
 
$service_name = "rocketagent"
$agent_name = "RocketAgent"

filter timestamp {"$(Get-Date -Format G): $_"}

function remove_uninstall_from_all_users(){

    # Regex pattern for SIDs
    $PatternSID = 'S-1-5-21-\d+-\d+\-\d+\-\d+$' 
 
    try{
        # Get all user SIDs found in HKEY_USERS
        $local_users = Get-ChildItem Registry::HKEY_USERS | ? {$_.PSChildname -match $PatternSID} | Select @{name="SID";expression={$_.PSChildName}}     
        New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
        
        # Loop through each profile on the machine
        Foreach ($item in $local_users){
            Remove-Item -Path HKU:\$($item.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$service_name -Force -Recurse -ErrorAction SilentlyContinue
        }

        # Catch any in .DEFAULT 
        Remove-Item -Path HKU:\.DEFAULT\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$service_name -Force -Recurse -ErrorAction SilentlyContinue
        Remove-PSDrive -Name HKU

    }catch{
        $err = $_.Exception.Message
        Write-Output $err | timestamp        
    }
}

function is_installed() {
    if (Get-Service $service_name -ErrorAction SilentlyContinue){
        return $true
    }
    return $false
}

function uninstaller_main(){
    if ((is_installed)){
        # remove regkeys
        # remove all files
        # remove local directory
        Write-Host "Uninstalling $agent_name"
        # stop services
        Write-Host "Stopping $service_name"
        Stop-Service $service_name -ErrorAction SilentlyContinue
        sc.exe delete $service_name

        if (Get-Service "rocket_kernel" -ErrorAction SilentlyContinue){
            try{
                Write-Host "Stopping rocket_kernel"
                Stop-Service "rocket_kernel" -ErrorAction SilentlyContinue
                sc.exe delete "rocket_kernel"

            }catch{
                $err = $_.Exception.Message
                Write-Output $err | timestamp
            }
        }

        if (Get-Service "windivert" -ErrorAction SilentlyContinue){
            try{
                Write-Host "Stopping windivert"
                Stop-Service "windivert" -ErrorAction SilentlyContinue
                sc.exe delete "windivert"

            }catch{
                $err = $_.Exception.Message
                Write-Output $err | timestamp
            }
        }

        Write-Host "Removing Uninstall Keys"
        #remove system wide uninstall items
        try{
            Remove-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$service_name -Force -Recurse -Verbose -ErrorAction SilentlyContinue
            Remove-Item -Path HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$service_name -Force -Recurse -Verbose -ErrorAction SilentlyContinue
        }catch{
            $err = $_.Exception.Message
            Write-Output $err | timestamp
        }

        remove_uninstall_from_all_users
        Write-Host "Removing Directory"
        try{
            Get-ChildItem "$Env:Programfiles\RocketAgent" -Recurse | Remove-Item -Force -Recurse
            Remove-Item -Force "$Env:Programfiles\RocketAgent" -Recurse

        }catch{
            $err = $_.Exception.Message
            Write-Output $err | timestamp
        }

        Write-Host "Removal Complete."

    }else{
        Write-Host "$agent_name not installed"
    }

}

try{
	if(test-path "C:\Program Files\RocketAgent\uninstall.exe"){
		Start-Process "C:\Program Files\RocketAgent\uninstall.exe" -argumentlist "/S"
		uninstaller_main
	}else{
		uninstaller_main
	}
}catch{
    $err = $_.Exception.Message
    Write-Output $err | timestamp
}