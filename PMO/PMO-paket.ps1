#Script för att skapa ett "korrekt" SIP utefter en PMO-export.

$ExportPaket = Get-ChildItem .\Exempel_Arkivfunktionen_PMO_191212121212.zip
$PaketNamn = $ExportPaket.BaseName
New-Item -ItemType Directory -Path .\PMOWorker
$Destination=New-Item -ItemType Directory -path .\PMOWorker\$PaketNamn

Expand-Archive -Path $ExportPaket -DestinationPath $Destination

$MappMedPersoner = Get-ChildItem $Destination

foreach($mapp in $MappMedPersoner){
    $AlltIMapp = Get-ChildItem $mapp -Recurse
    
}