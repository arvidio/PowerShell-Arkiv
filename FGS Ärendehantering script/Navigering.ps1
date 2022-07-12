#Hitta något som arkivexport.xml
[XML]$XML = get-content C:\Users\97arer14\Documents\Arkivexport\TN2022-06-30TT1013Arkivexport.xml

$arenden = $XML.Leveransobjekt.ArkivobjektListaArenden.ArkivobjektArende

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