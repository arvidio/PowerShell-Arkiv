$x = [XML](Get-Content .\Documents\Arkivexport\FNH2022-07-15TT1249Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
