$x = [XML](Get-Content .\Documents\Arkivexport\SN2022-11-07TT1054Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
