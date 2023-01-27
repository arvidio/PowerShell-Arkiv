#Hitta något som arkivexport.xml
[XML]$XML = get-content ''
[XML]$XML = get-content ''
[XML]$XML = get-content ''

$arenden = $XML.Leveransobjekt.ArkivobjektListaArenden.ArkivobjektArende
$handlingar = $XML.Leveransobjekt.ArkivobjektListaArenden.ArkivobjektArende.ArkivobjektListaHandlingar.ArkivobjektHandling

#Hitta ärenden där Motpart saknar Namn-tagg.
foreach($arende in $arenden){
    $dnr = $arende.ArkivobjektID
    $motpart = $arende.Motpart
    $motpartn = $arende.Motpart.Namn
    if(($null -eq $motpartn)-and($null -ne $motpart)){
        $motpart
        $dnr
    }
    
}
#Hitta ärenden med Klass 513
foreach($arende in $arenden){
    $dnr = $arende.ArkivobjektID
    $park = "513 Parkeringstillstånd"
    $klass = $arende.Klass

    if($klass -eq $park){
        $dnr
    }
    
}
#Hitta ärenden där Upprattad Expedierad Atkmost och Arendemening. saknas
foreach($arende in $arenden){
    $dnr = $arende.ArkivobjektID
    $Uppr = $arende.Upprattad
    $Expe = $arende.Expedierad
    $Atko = $arende.Atkomst
    $Aren = $arende.Arendemening
    if(($null -eq $Uppr)-and($null -eq $Expe)-and($null -eq $Atko)-and($null -eq $Aren)){
        $dnr
    }
}


#Hitta ärenden där SistaAnvandandetidpunkt är tomt (Vanligtvis CSV-problem)
foreach($arende in $arenden){
    $dnr = $arende.ArkivobjektID
    $SistaAnv = $arende.SistaAnvandandetidpunkt
    if($null -eq $SistaAnv){
        $dnr
    }
}

foreach($arende in $arenden){
    $dnr = $arende.ArkivobjektID
    $amening = $arende.Arendemening
    if($null -eq $amening){
        $dnr
    }
}

$handlingar = $arenden.ArkivobjektListaHandlingar.ArkivobjektHandling

foreach($handling in $handlingar){
    $dnr = $handling.ArkivobjektID
    $avsandNamn = $handling.Avsandare.Namn
    $avsandOrg = $handling.Avsandare.Organisation
    if(($null -eq $avsandNamn)-and($null -ne $avsandOrg)){
        "Avsändare"
        $dnr
    }
    $mottNamn = $handling.Mottagare.Namn
    $mottOrg = $handling.Mottagare.Organisation
    if(($null -eq $mottNamn)-and($null -ne $mottOrg)){
        "Mottagare"
        $dnr
    }
}