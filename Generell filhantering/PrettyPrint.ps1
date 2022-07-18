$x = [XML](Get-Content .\Documents\Arkivexport\KN2022-07-18TT0917Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
