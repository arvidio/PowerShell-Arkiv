$x = [XML](Get-Content .\Documents\Arkivexport\PLK2022-07-18TT1558Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
