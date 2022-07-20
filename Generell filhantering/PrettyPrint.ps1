$x = [XML](Get-Content .\Documents\Arkivexport\VN2022-07-20TT1411Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
