$x = [XML](Get-Content .\Documents\Arkivexport\ONS2022-07-18TT1507Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
