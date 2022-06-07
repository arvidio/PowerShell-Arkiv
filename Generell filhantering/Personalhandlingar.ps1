#För att spara metadata från filnamn uppbyggda som personnummer_namn1_namn2_namnx.pdf
#Ej använt i större utsträckning endast test.

Set-Location C:\Users\97arer14\Documents\Script

$signatureindication='/Type /Sig'

$files = Get-ChildItem -Path C:\Users\97arer14\Documents\Script\*.pdf

foreach ($file in $files){
    $fileName=$file.Name
    $fileFullName=$file.FullName
    $fileSize=$file.length

    $content=Get-Content $file

    if($content -like "*$signatureindication*"){
    Write-Host "$fileFullName är signerad och måste valideras separat"
    }
    else{
        if($fileName -like "*_*"){
            $splitunderscore=$fileName.Split("_")
            $PersonID = $splitunderscore[0]
            $filmetadataCSV = $PersonID+";;;;;"+$fileSize+";"+$fileFullName
            $filmetadataCSV |Out-File C:\Users\97arer14\Documents\Script\filmetadata.csv -Append -Encoding utf8
        }
        elseif($fileName -like "* *"){
            $split = $fileName.Split(" ")
            $splitcount=$split.Count
                if($splitcount -eq 4){
                    $PersonID = $split[0]
                    $name1 = $split[1]
                    $name2 = $split[2]
                    $handlingstyp=$split[3].Trim(".pdf")
                    $filmetadataCSV = $PersonID+";"+$name1+";"+$name2+";;"+$handlingstyp+";"+$fileSize+";"+$fileFullName
                    $filmetadataCSV |Out-File C:\Users\97arer14\Documents\Script\filmetadata.csv -Append -Encoding utf8
                }
                elseif($splitcount -eq 5){
                    $PersonID = $split[0]
                    $name1 = $split[1]
                    $name2 = $split[2]
                    $name3 = $split[3]
                    $handlingstyp=$split[4].Trim(".pdf")
                    $filmetadataCSV = $PersonID+";"+$name1+";"+$name2+";"+$name3+";"+$handlingstyp+";"+$fileSize+";"+$fileFullName
                    $filmetadataCSV | Out-File C:\Users\97arer14\Documents\Script\filmetadata.csv -Append -Encoding utf8
                }
                else{
                    Write-host "$fileFullName har för många namn i sig! Läggs in i lista toomanynames.csv"
                    $fileFullName | Out-File toomanynames.csv -Encoding utf8 -Append
                }
            }
        }
}
