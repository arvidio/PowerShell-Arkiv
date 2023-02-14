$x = [XML](Get-Content '.\Documents\Script\Metadata tillBSNpaket\Metadata.xml')
$x.Save(".\Documents\Prettyprint.xml")
