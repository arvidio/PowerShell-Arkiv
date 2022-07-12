$dpl = Get-Content -Path .\Desktop\dpl.csv
$udpl = $dpl | Select-Object -Unique
Compare-Object -ReferenceObject $udpl -DifferenceObject $dpl


$t = Get-Content -Path .\Desktop\Utedit.csv
$x = $t | Select-Object -Unique
Compare-Object -ReferenceObject $x -DifferenceObject $t