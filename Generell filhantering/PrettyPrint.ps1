$x = [XML](Get-Content .\Documents\Arkivexport\KFA2022-07-18TT0854Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
