#Script inte menat för körning rakt av.

#första samlingen av script jag skrev (så viss chans att det finns bad-practice exempel i överflöd)
# Från att byta namn på skannade betyg till att ta ut texten ur filnamnet till csv. Har försökt få allt skannat än så länge till konsekvent PERSONNUMMER_EFTERNAMN_FORNAMN.pdf, för att sedan 
# Betygen ligger sedan sorterade i mappstruktur, där mapparna motsvarar klassen generellt (eller det som står på aktomslaget).
# Generellt bara jobbat med betyg från en skola, men skolan har nog satts manuellt istället för att inkludera i filnamnet.
#Skrivet till PS 5.1 ursprungligen.

#Byt specialtecken (ÅÄÖÜÉ) mellanslag osv till arkivvänligt filnamn. Kontroll krävs då det sällan är enhetligt för hela år/klasser.
Get-ChildItem *.pdf | Rename-Item -NewName {$_.Name -replace ", ","_" -replace " ","-" -replace "´","-" -creplace "å","a" -creplace "Å","A" -creplace "ä","a" -creplace "Ä","A" -creplace "ö","o" -creplace "Ö","O" -creplace "ü","u" -creplace "Ü","U" -creplace "é","e" -creplace "É","E"}

#Endast punkt mellanslag till understreck bindesstreck
Get-ChildItem *.pdf | Rename-Item -NewName {$_.Name -replace ", ","_" -replace " ","-"}

###### SPARA 19XX Använd endast vid eventuellt dubbla millenium + sekeltal, ex 191997XXXX-XXXX som skett vid olika hantering vid inskrivning.
#Ta bort första två tecknen, ex 1964 till 64.
#Get-ChildItem *.pdf | Rename-Item -NewName {[string]($_.name).Substring(2)}

#Lägg till 19 som prefix i filnamn i nuvarande mapp. -Recurse på gci om undermappar ska sökas igenom
#Get-ChildItem *.pdf -Recurse | Rename-Item -NewName {"19" + $_.Name}

#Checksum för filer med oförändrade samt förändrade filnamn,####### Path manuell så ändra på det! ###################
#Mest för att kolla så att inget missades i kopierande av kopior...
$OFiler = Get-ChildItem -Path 'C:\Users\97arer14\Documents\Script\Betyg Rodengymnasiet 2011 Utan 19' -Recurse *.pdf 
$OFilerChecksum = $OFiler | Get-FileHash -Algorithm SHA256
$FFiler = Get-ChildItem -Path 'C:\Users\97arer14\Documents\Script\Betyg Rodengymnasiet 2011 Med 19' -Recurse *.pdf 
$FFilerChecksum = $FFiler | Get-FileHash -Algorithm SHA256
Compare-Object -Property Hash -ReferenceObject $OFilerChecksum -DifferenceObject $FFilerChecksum

#Lägg till Skola och Avgångsår i filnamn (Då elever har betyg i flera årgångar) SÄTT ÅR/SKOLA MANUELLT.
$Files = Get-ChildItem *.pdf -Recurse
$Files | Rename-Item -NewName {"Rodengymnasiet_2006_"+$_.Name}


### Skapar en csvfil från filnamn efter PERSONNUMMER_EFTERNAMN_FORNAMN.pdf



$Filenames = Get-ChildItem *.pdf | Get-ChildItem -Name

$Filenames | ForEach-Object { 
                          
                          $CurrentFileName = $_
                          $Column0 = $_.split("_")[0]
                          $Column1 = $_.split("_")[1]
                          $Column2 = $_.split("_"".")[2] #Kommer inte fungera i 7.2, använd scriptblock typ $_ -split {$_ -eq '_' -or $_ -eq '.'}

                          $Column0+";"+$Column1+";"+$Column2+";"+$CurrentFileName
                        } | Out-File -FilePath "betygscsv$(get-date -f HHmm).csv" -Encoding utf8


### Ska skriva nedanstående för tillagt skolnamn och avgångsår istället. Klass "går ej" att ha i filnamnet så mappen behöver fortfarande hämtas.
### Inkluderar skolklass från mappstruktur med *:\*\*\KLASS. Ändra Column 3 split efter hur många \ som kommer innan klassens namn.

$Fileobject = Get-ChildItem -Recurse *.pdf

$Fileobject | ForEach-Object { 
                          $CurrentFolder = $_.DirectoryName
                          $CurrentFileName = $_.Name
                          #Hämtar Skola
                          $Column4 = $CurrentFileName.split("_")[0]
                          #Hämtar Avgångsår
                          $Column5 = $CurrentFileName.split("_")[1]
                          #Hämtar Personnummer
                          $Column0 = $CurrentFileName.split("_")[2]
                          #Hämtar Efternamn
                          $Column1 = $CurrentFileName.split("_")[3]
                          #Hämtar Förnamn och gömmer .pdf
                          $Column2 = $CurrentFileName.split("_"".")[4]
                          #Hämtar mapp från filens Directory Name. Siffran i [] ska peka på det fält där klassnamnet står, räknat från 0.
                          $Column3 = $CurrentFolder.split("\")[6]

                          $Column0+";"+$Column1+";"+$Column2+";"+$Column3+";"+$Column4+";"+$Column5+";"+$CurrentFileName
                        } | Out-File -FilePath "betygscsv$(get-date -f HHmm).csv" -Encoding utf8


#Gammal version som inte inkluderar skolnamn/avgångsår.            
#$Fileobject = Get-ChildItem -Recurse *.pdf

#$Fileobject | foreach { 
#                          $CurrentFolder = $_.DirectoryName
#                          $CurrentFileName = $_.Name
#                          #Hämtar Personnummer
#                          $Column0 = $CurrentFileName.split("_")[0]
#                          #Hämtar Efternamn
#                          $Column1 = $CurrentFileName.split("_")[1]
#                          #Hämtar Förnamn och gömmer .pdf
#                          $Column2 = $CurrentFileName.split("_"".")[2]
#                          #Hämtar mapp från filens Directory Name. Siffran i [] ska peka på det fält där klassnamnet står, räknat från 0.
#                          $Column3 = $CurrentFolder.split("\")[6]
#
#                          $Column0+";"+$Column1+";"+$Column2+";"+$Column3+";"+$CurrentFileName
#                        } | Out-File -FilePath "betygscsv$(get-date -f HHmm).csv" -Encoding utf8