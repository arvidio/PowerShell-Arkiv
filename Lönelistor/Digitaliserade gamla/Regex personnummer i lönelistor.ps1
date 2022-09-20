#Script som med hjälp av pdftotext.exe byter namn på filer till det personnummer som finns OCR-at i filen (lönelistor)
#https://www.xpdfreader.com/pdftotext-man.html
#Skrivet för PowerShell 7.2


#Detta ändras för att peka på rätt filer
$filer=get-childitem -Path "E:\Lönelistor Norrtälje\*.pdf" -Recurse

foreach($fil in $filer){
    #Detta behöver peka på pdftotext.exe C:\.\pdftotext.exe om den ligger direkt under C till exempel.
    .\Documents\Script\PDF\.\pdftotext.exe -enc UTF-8 $fil.FullName .\Documents\temptext.txt
    $tempfil = Get-ChildItem .\Documents\temptext.txt
    $temptext = Get-Content $tempfil
    $personnummer = $temptext | Out-String -stream | Select-String -Pattern '[\d]{6}-[\d]{4}'
    if($personnummer -match '[\d]{6}-[\d]{4}'){
        $filnamn = $fil.BaseName 
        Rename-Item -Path $fil -NewName "$filnamn"+"_"+"$personnummer.pdf"
    }
    Remove-Item $tempfil
}
 