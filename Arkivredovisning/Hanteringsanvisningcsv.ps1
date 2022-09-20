$CSV = Import-CSV .\Desktop\Bok2.csv -Delimiter ";" -Encoding utf8NoBOM

$resultat=foreach($process in $CSV){
    $processnamn = $process.Hanteringsanvisningar
    $Handlingstyp = $process.Handlingstyp
    $BevGal = $process.Bevarasgallras
    $Registrering = $process.Registrering

    if(($BevGal -ne "Bevaras")-and($Registrering -eq "Diarieföring")){
        $processnamn
        $Handlingstyp
        $BevGal
        $Registrering
        "##########################################"
    } 
}
$Resultat | Out-File .\Desktop\VO2.txt