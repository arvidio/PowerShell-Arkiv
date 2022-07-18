$x = [XML](Get-Content .\Documents\Arkivexport\NKAB2022-07-18TT1159Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
