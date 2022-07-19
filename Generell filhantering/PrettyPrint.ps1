$x = [XML](Get-Content .\Documents\Arkivexport\TSN2022-07-19TT1558Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
