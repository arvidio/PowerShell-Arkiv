$x = [XML](Get-Content .\Documents\Arkivexport\BSN2022-07-14TT1135Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
