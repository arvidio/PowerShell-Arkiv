$x = [XML](Get-Content .\Documents\Arkivexport\RÄN2022-07-19TT0909Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
