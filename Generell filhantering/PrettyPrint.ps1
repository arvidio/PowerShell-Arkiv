$x = [XML](Get-Content .\Documents\Arkivexport\KFN2022-07-13TT0114Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
