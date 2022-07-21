#Script som med hjälp av pdftotext.exe byter namn på filer till det personnummer som finns OCR-at i filen (betyg)
#https://www.xpdfreader.com/pdftotext-man.html
#Skrivet för PowerShell 7.2


#Detta ändras för att peka på rätt filer
$filer=get-childitem -Path .\Desktop\Betyg\*.pdf

foreach($fil in $filer){
    #Detta behöver peka på pdftotext.exe C:\.\pdftotext.exe om den ligger direkt under C till exempel.
    .\Documents\Script\PDF\.\pdftotext.exe -enc UTF-8 $fil.FullName .\Documents\temptext.txt
    $tempfil = Get-ChildItem .\Documents\temptext.txt
    $temptext = Get-Content $tempfil
    $personnummer = $temptext | Out-String -stream | Select-String -Pattern '[\d]{6}-[\d]{4}'
    if($personnummer -match '[\d]{6}-[\d]{4}'){
        #Går att förfina för att lägga till lite mer intressant information. 
        Rename-Item -Path $fil -NewName "$personnummer.pdf"
    }
    elseif ($null -eq $personnummer) {
        Write-Host "Gör inget"
    }
    else{
        Write-Host "Något gick fel"
    }
    Remove-Item $tempfil
}
 