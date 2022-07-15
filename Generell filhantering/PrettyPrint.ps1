$x = [XML](Get-Content .\Documents\Arkivexport\FN2022-07-15TT0940Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
