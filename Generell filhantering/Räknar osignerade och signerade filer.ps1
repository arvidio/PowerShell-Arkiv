#Räknar signerade filer, eller snarare räknar förekomster av filer med '/Type /Sig' i sig. 
$filer= Get-ChildItem -Path D:\signfiler
$signatureindication='/Type /Sig'
$countsign = 0
$countunsign = 0
$filer | ForEach-Object {

$content = get-content -Path $_.FullName
if ($content -ccontains $signatureindication)
{$countsign++}
else 
{$countunsign++}
}
$countsign
$countunsign