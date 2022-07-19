$x = [XML](Get-Content .\Documents\Arkivexport\ROD2022-07-19TT1029Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
