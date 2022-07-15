$x = [XML](Get-Content .\Documents\Arkivexport\FNN2022-07-15TT1130Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
