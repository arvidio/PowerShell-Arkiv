$x = [XML](Get-Content .\Documents\Arkivexport\PE2022-07-18TT1535Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
