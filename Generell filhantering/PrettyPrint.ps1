$x = [XML](Get-Content .\Documents\Arkivexport\RTJ2022-09-01TT0917Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
