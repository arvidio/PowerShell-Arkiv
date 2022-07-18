$x = [XML](Get-Content .\Documents\Arkivexport\ON2022-07-18TT1430Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
