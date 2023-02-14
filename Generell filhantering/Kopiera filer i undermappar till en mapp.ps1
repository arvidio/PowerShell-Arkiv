$Filer = Get-ChildItem .\Documents\Script\Content -Recurse -File
foreach($fil in $Filer){
Copy-Item $fil -Destination .\Documents\Script\Content2
}
