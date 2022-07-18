$x = [XML](Get-Content .\Documents\Arkivexport\MEX2022-07-18TT1129Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
