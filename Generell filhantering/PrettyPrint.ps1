$x = [XML](Get-Content '.\Documents\Arkivexport\FORV2023-02-27TT1038Arkivexport.xml')
$x.Save(".\Documents\Script\Prettyprint.xml")
