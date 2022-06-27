#D:\diabas\famdata\vol1\000\000\00\0000000001

#Lägg allt som behövs in i <Bilaga\> sen kopiera in i mapp?
#Alternativt kopiera ut endast när paketet skapas. Kanske tom går att skapa på servern?

#Plocka ut nummer från databasen, exempel nedan
$nummer = "20003"

$paddatnummer = $nummer.PadLeft(10,[char]"0")
$eftervol1 = $paddatnummer[0] + $paddatnummer[1] + $paddatnummer[2] + "\" + $paddatnummer[3] + $paddatnummer[4] + $paddatnummer[5] + "\" + $paddatnummer[6] + $paddatnummer[7] + "\" + $paddatnummer
$fullpath = "\\nkadmdiabas01\D$\diabas\famdata\vol1\" + $eftervol1

$filer = Get-ChildItem "$fullpath"
foreach($fil in $filer){
    if($fil.Extension -eq ".attributes"){Write-host "Göringe"}
    else{
        $FilHash = $fil | Get-FileHash
        $FilHash
    }
}



#Fungerar så länge jag har varit in och skrivit credentials verkar det som.