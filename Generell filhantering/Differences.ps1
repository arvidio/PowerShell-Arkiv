$dpl = Get-Content -Path .\Documents\dpl.csv



$t = Get-Content -Path .\Documents\Utedit.csv
$x = $t | Select-Object -Unique
Compare-Object -ReferenceObject $x -DifferenceObject $t

foreach($dp in $dplo){
    $dps = $dp.Split(" ")
    $beteck = $dps[0]
    $rad= $beteck + ";" + $dps
    $rad | Out-File 2.csv -Append
} 


$2 = Import-csv .\2.csv -delimiter ";"



foreach($zz in $2){
    $Beteckningar += $zz.beteck + @"
    

"@
    
}

$4 = Get-Content .\4.csv
$4 | Select-Object -Unique | Out-File 5.csv
