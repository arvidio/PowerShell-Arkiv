#WIP för att få ut vilka filer som verkar vara tillräckligt stora för att antas vara brytpunkter.
$files = Get-ChildItem

foreach($file in $files){
    $length=$file.Length
    if($length -gt 1700000){
        $file.FullName
    }
}