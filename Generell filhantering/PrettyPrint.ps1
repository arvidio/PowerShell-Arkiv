$x = [XML](Get-Content .\Documents\Arkivexport\BUN2022-07-14TT1328Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
