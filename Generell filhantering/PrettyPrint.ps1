$x = [XML](Get-Content .\Documents\Arkivexport\FNR2022-07-15TT1313Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
