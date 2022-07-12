$x = [XML](Get-Content .\Documents\Arkivexport\KS2022-07-12TT0835Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
