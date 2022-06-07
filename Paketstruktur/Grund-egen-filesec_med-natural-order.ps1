## Allt i ordning borde fungera om sipBild.xml inte finns. Set-Location behöver vara mappen med filerna.


Set-Location ################# Fyll ######################

#ToNatural är snott från nätet, och används för att sortera objekt (i detta fall filer) på samma sätt som namn sorteras i utforskaren i Windows. Alltså nån typ av alfanumrerisk ordning. 2.tif kommer före 10.tif exempelvis. Så inte egentligen nödvändigt men kan vara bra med en förståelig ordning.
#Används nere innan loopen för att sortera objekten innan den körs.
$ToNatural = { [regex]::Replace($_, '\d+', { $args[0].Value.PadLeft(20) }) }


$i= 1
Get-ChildItem | Sort-Object $ToNatural | ForEach-Object {
$FilskapadDatum = $_ | Select-Object -ExpandProperty CreationTime | Get-Date -Format yyyy-MM-ddTHH:mm:ss
$Filstorlek = $_.Length
$Filnamn = $_.Name
$Filsokvag = $_.FullName

$Checksumma = Get-FileHash -Path $Filsokvag -Algorithm SHA256
$Hash = $Checksumma.Hash
#Saknar bindesstreck i $Checksumma.Algorithm, går säkert att fixa lätt om det orkas. Skriver ju ändi in SHA256 ovan så varför inte "skriva in" SHA-256 i XML. SHA-256 är det format FGS Paketstruktur önskar algoritmen.
$HashTyp = "SHA-256"


$XML=@"
<mets:file ID="IDBildImportNr$i" USE="Image" MIMETYPE="image/tiff" SIZE="$Filstorlek" CREATED="$FilskapadDatum" CHECKSUM="$Hash" CHECKSUMTYPE="$HashTyp" ext:ORIGINALFILENAME="$Filnamn"><mets:FLocat LOCTYPE="URL" xlink:type="simple" xlink:href="file:///Content/1/$Filnamn"/></mets:file>
"@

$XML | Out-File -FilePath "sipFILETAGGAR.xml" -Append
$i++
}