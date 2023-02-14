[XML]$XML = Get-Content '.\Documents\Script\Metadata tillBSNpaket\Prettyprint.xml'

$Lankar = $XML.Leveransobjekt.ArkivobjektListaArenden.ArkivobjektArende.ArkivobjektListaHandlingar.ArkivobjektHandling.Bilaga.Lank

foreach($lank in $Lankar){
    $test= Test-Path ".\Documents\Script\Content2\$lank"
    if($test -like "False"){
        $lank
    }
}