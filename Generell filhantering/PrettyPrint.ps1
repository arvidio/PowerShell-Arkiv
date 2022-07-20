$x = [XML](Get-Content .\Documents\Arkivexport\UN2022-07-20TT0936Arkivexport.xml)
$x.Save(".\Documents\Prettyprint.xml")
