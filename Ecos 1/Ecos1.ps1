##WIP för ECOS1. Nedan skapar ett eget element.


$csvAr = Import-Csv 'C:\Users\97arer14\Documents\new 2.csv' -Encoding utf8NoBOM -Delimiter ";"

foreach($arende in $csvAr){
$EgnaElementStart = @"
<EgnaElement>
"@
$EgnaElementSlut = "</EgnaElement>"
if("NULL" -eq $arende.Fastighetsbeteckning){
    $EgnaElementBeskrivning = $null
    $EgnaElementStart = $null
    $EgnaElementSlut = $null
    $EgetElement1 = $null
}
else{
    $Fastighetsbeteckning = $arende.Fastighetsbeteckning
$EgetElement1 = @"
<EgetElement Namn="Fastighetsbeteckning" DataTyp="String"><Varde>$Fastighetsbeteckning</Varde></EgetElement>
"@
$EgnaElementBeskrivning = @"
<EgnaElementBeskrivning>Det egna elementet beskriver vilken fastighet ärendet berör.</EgnaElementBeskrivning>
"@
}
$EgnaElementTagg = $EgnaElementStart + $EgnaElementBeskrivning + $EgetElement1 + $EgnaElementSlut
$EgnaElementTagg
}
