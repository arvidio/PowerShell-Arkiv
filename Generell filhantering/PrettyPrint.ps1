$x = [XML](Get-Content .\Documents\Arkivexport\ST2022-07-19TT1049Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
