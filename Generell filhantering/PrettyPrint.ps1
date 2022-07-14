$x = [XML](Get-Content .\Documents\Arkivexport\DK2022-07-14TT1403Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
