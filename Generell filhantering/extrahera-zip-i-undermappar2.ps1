# mappen zipfiler nedan innehåller 3 mappar med zip filer i sig. bör gå oavsett struktur så länge alla undermappar endast innehåller zip-filer som du vill extrahera.
#byt ut path nedan till önskad filsökväg där zip-filerna ligger.
Set-Location C:\Users\97arer14\Desktop\zipfiler
#Hämtar alla zipfiler i undermappar till variabel
$Zipfiler = Get-ChildItem *.zip -Recurse
#Loopar alla, skapar en ny mapp som heter extraherat och extraherar till den nya mappen.
$Zipfiler | ForEach-Object{
$mapp = $_.DirectoryName
New-Item -ItemType Directory -Path "$mapp\extraherat"
Expand-Archive -Path $_.FullName -DestinationPath "$mapp\extraherat"
}
