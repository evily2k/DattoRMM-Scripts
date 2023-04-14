#Built-In apps to be removed from all users (requires elevated powershell)

$AppRemoveList = @()

$AppRemoveList += @("*LinkedInForWindows*")

$AppRemoveList += @("*BingWeather*")

$AppRemoveList += @("*DesktopAppInstaller*")

$AppRemoveList += @("*GetHelp*")

$AppRemoveList += @("*Getstarted*")

$AppRemoveList += @("*Messaging*")

$AppRemoveList += @("*Microsoft3DViewer*")

$AppRemoveList += @("*MicrosoftOfficeHub*")

$AppRemoveList += @("*MicrosoftSolitaireCollection*")

$AppRemoveList += @("*MicrosoftStickyNotes*")

$AppRemoveList += @("*MixedReality.Portal*")

$AppRemoveList += @("*Office.Desktop.Access*")

$AppRemoveList += @("*Office.Desktop.Excel*")

$AppRemoveList += @("*Office.Desktop.Outlook*")

$AppRemoveList += @("*Office.Desktop.Powerpoint*")

$AppRemoveList += @("*Office.Desktop.Publisher*")

$AppRemoveList += @("*Office.Desktop.Word*")

$AppRemoveList += @("*Office.Desktop*")

$AppRemoveList += @("*Office.onenote*")

$AppRemoveList += @("*Office.Sway*")

$AppRemoveList += @("*OneConnect*")

$AppRemoveList += @("*Print3D*")

$AppRemoveList += @("*ScreenSketch*")

$AppRemoveList += @("*Skype*")

$AppRemoveList += @("*Windowscommunicationsapps*")

$AppRemoveList += @("*WindowsFeedbackHub*")

$AppRemoveList += @("*WindowsMaps*")

$AppRemoveList += @("*WindowsAlarms*")

$AppRemoveList += @("*YourPhone*")

$AppRemoveList += @("*Advertising.xaml*")

$AppRemoveList += @("*Advertising.xaml*") #intentionally listed twice

$AppRemoveList += @("*OfficeLens*")

$AppRemoveList += @("*BingNews*")

$AppRemoveList += @("*WindowsMaps*")

$AppRemoveList += @("*NetworkSpeedTest*")

$AppRemoveList += @("*Microsoft3DViewer*")

$AppRemoveList += @("*CommsPhone*")

$AppRemoveList += @("*3DBuilder*")

$AppRemoveList += @("*CBSPreview*")

$AppRemoveList += @("*king.com.CandyCrush*")

$AppRemoveList += @("*nordcurrent*")

$AppRemoveList += @("*Facebook*")

$AppRemoveList += @("*MinecraftUWP*")

$AppRemoveList += @("*Netflix*")

$AppRemoveList += @("*RoyalRevolt2*")

$AppRemoveList += @("*bingsports*")

$AppRemoveList += @("*Lenovo*")

$AppRemoveList += @("*DellCustomerConnect*")

$AppRemoveList += @("*DellDigitalDelivery*")

$AppRemoveList += @("*DellPowerManager*")

$AppRemoveList += @("*MyDell*")

$AppRemoveList += @("*DellMobileConnect*")

$AppRemoveList += @("*DellFreeFallDataProtection*")

$AppRemoveList += @("*DropboxOEM*")





#************************

#*** Begin Processing ***

#************************



# Removing Built-In Apps

write-host "Removing Built-In Cludge...\n"

ForEach ($x in $AppRemoveList) {

Get-AppxProvisionedPackage -Online | Where DisplayName -like $x | Remove-AppxProvisionedPackage -online

Get-AppxPackage -Allusers | where packagefullname -like $x | remove-AppxPackage



$appPath="$Env:LOCALAPPDATA\Packages\$Appremovelist*"

remove-item $appPath -Recurse -Force -Erroraction SilentlyContinue

}


#Delete layout file if it already exists

If(Test-Path C:\Windows\StartLayout.xml)

{

Remove-Item C:\Windows\StartLayout.xml

}



#Creates the blank layout file

echo "<LayoutModificationTemplate xmlns:defaultlayout=""http://schemas.microsoft.com/Start/2014/FullDefaultLayout"" xmlns:start=""http://schemas.microsoft.com/Start/2014/StartLayout"" Version=""1"" xmlns=""http://schemas.microsoft.com/Start/2014/LayoutModification"">" >> C:\Windows\StartLayout.xml

echo " <LayoutOptions StartTileGroupCellWidth=""6"" />" >> C:\Windows\StartLayout.xml

echo " <DefaultLayoutOverride>" >> C:\Windows\StartLayout.xml

echo " <StartLayoutCollection>" >> C:\Windows\StartLayout.xml

echo " <defaultlayout:StartLayout GroupCellWidth=""6"" />" >> C:\Windows\StartLayout.xml

echo " </StartLayoutCollection>" >> C:\Windows\StartLayout.xml

echo " </DefaultLayoutOverride>" >> C:\Windows\StartLayout.xml

echo "</LayoutModificationTemplate>" >> C:\Windows\StartLayout.xml


Get-AppxProvisionedPackage -online | %{if ($_.packagename -match "Microsoft.Office.Desktop") {$_ | Remove-AppxProvisionedPackage -AllUsers}}


Function Remove-App([String]$AppName){
    $PackageFullName = (Get-AppxPackage $AppName).PackageFullName
    $ProPackageFullName = (Get-AppxProvisionedPackage -Online | where {$_.Displayname -eq $AppName}).PackageName
    Remove-AppxPackage -package $PackageFullName | Out-Null
    Remove-AppxProvisionedPackage -online -packagename $ProPackageFullName | Out-Null
}

###########
# EXECUTE #
###########
# Active identifiers
Remove-App "Microsoft.GetHelp"							# MS support chat bot
Remove-App "Microsoft.Getstarted"						# 'Get Started' link
Remove-App "Microsoft.Messaging"						# SMS app. Requires a phone link.
Remove-App "Microsoft.MicrosoftOfficeHub"				# Office 365. Interferes with Office ProPlus
Remove-App "Microsoft.MicrosoftSolitaireCollection"		# Game
Remove-App "Microsoft.OneConnect"						# Paid WiFi and Cellular App
Remove-App "Microsoft.SkypeApp"							# Skype
Remove-App "Microsoft.Wallet"							# Mobile payment storage
Remove-App "microsoft.windowscommunicationsapps"		# MS Calendar and Mail apps. Interferes with Office ProPlus
Remove-App "Microsoft.WindowsFeedbackHub"				# MS Beta test opt-in app
Remove-App "Microsoft.YourPhone"						# Links an Android phone to the PC