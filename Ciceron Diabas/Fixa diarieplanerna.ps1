$CSV = Import-csv -path .\desktop\Listadpl.csv -Delimiter ";"

$CSV | Select-Object -ExpandProperty Beteckning -Unique | Out-File .\Desktop\Unika.csv

foreach($dpl in $CSV){
    $beteckning = $dpl.Beteckning
    $text = $dpl.Namn
    
}
