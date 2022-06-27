#Hitta något som arkivexport.xml
[XML]$XML = get-content C:\Users\97arer14\Documents\Arkivexport\JVP2022-06-10TT0102Arkivexport.xml -Encoding utf8NoBOM

$arenden = $XML.Leveransobjekt.ArkivobjektListaArenden.ArkivobjektArende

foreach($arende in $arenden){
    $motpart = $arende.Motpart
    $motpart.Postadress
}