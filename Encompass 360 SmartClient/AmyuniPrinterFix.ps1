$printer = "Amyuni Document Converter"
$encompass = "Encompass"
$printDir = "C:\Temp\Encompass\PdfConverter"

if(get-printer -name $printer -erroraction silentlycontinue){
	if(!(get-printer -name $encompass -erroraction silentlycontinue)){
		remove-printer -name $printer		
		if (test-path $printDir){
			set-location $printDir
			Write-Host "Installing Encompass PDF converter"
			start-process .\InstallPdfConverter.exe -argumentlist "-s" -wait -NoNewWindow
			get-printer -name $encompass
			Exit 0
		}else{
			Write-Host "PDFconverter Install directory not found"
			Exit 1
		}
	}else{
		if(get-printer -name $printer -erroraction silentlycontinue){
			write-host "Removing $printer"
			remove-printer -name $printer
		}			
		Write-Host "Encompass print driver already installed."
		Exit 0
	}
}else{
	if(!(get-printer -name $encompass -erroraction silentlycontinue)){
		if (test-path $printDir){
			set-location $printDir
			Write-Host "Installing Encompass PDF converter"
			start-process .\InstallPdfConverter.exe -argumentlist "-s" -wait -NoNewWindow
			get-printer -name $encompass
			Exit 0
		}else{
			Write-Host "PDFconverter Install directory not found"
			Exit 1
		}
	}
	Write-Host "$printer not found."
	Exit 0
}