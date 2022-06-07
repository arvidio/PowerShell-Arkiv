# mappen zipfiler nedan innehåller 3 mappar med zip filer i sig. bör gå oavsett struktur så länge alla undermappar endast innehåller zip-filer som du vill extrahera.
#byt ut path nedan till önskad filsökväg där zip-filerna ligger.
Set-Location C:\Users\97arer14\Desktop\zipfiler
#Hämtar alla zipfiler i undermappar till variabel
$Zipfiler = Get-ChildItem *.zip -Recurse
#Loopar alla och extraherar till mappen de ligger i. (Går nog att skapa nya mappar om du inte vill ha innehållet löst i undermapparna).
$Zipfiler | ForEach-Object{
Expand-Archive -Path $_.FullName -DestinationPath $_.DirectoryName
}