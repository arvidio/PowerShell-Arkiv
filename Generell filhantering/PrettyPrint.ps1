$x = [XML](Get-Content .\Documents\Arkivexport\THN2022-07-19TT1338Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
