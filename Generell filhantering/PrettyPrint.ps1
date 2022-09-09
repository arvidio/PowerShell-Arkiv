$x = [XML](Get-Content .\Documents\Arkivexport\TN2022-09-07TT1059Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
