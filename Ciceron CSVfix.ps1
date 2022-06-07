#Script under uppbyggnad för mindre ändringar i information som kommer direkt från databas. System är Ciceron Diabas (Classic) 5.7. Databasen bör vara densamma för nyare versioner av Ciceron DoÄ.
#Kontakt: arvid.eriksson@norrtalje.se
#Skrivet för PowerShell 7.2


#Sökvägar till olika SQL-uttag (Konverterade till UTF8NoBOM, kan nog importera dem som BOM och trycka ut som NoBOM?)
$CSVusr= Import-Csv C:\Users\97arer14\Documents\JVPAnvändare.csv -Delimiter ";" -Encoding utf8NoBOM
$CSVare= Import-Csv C:\Users\97arer14\Documents\JVPCases3.csv -Delimiter ";" -Encoding utf8NoBOM
$CSVhan= Import-CSV C:\Users\97arer14\Documents\JVPHandlingar2.csv -Delimiter ";" -Encoding utf8NoBOM
$CSVenh= Import-CSV C:\Users\97arer14\Documents\JVPEnhet.csv -Delimiter ";" -encoding utf8NoBOM
$CSVdia= Import-CSV C:\Users\97arer14\Documents\JVPDiarieplaner.csv -Delimiter ";" -encoding utf8NoBOM
$CSVhty= Import-Csv C:\Users\97arer14\Documents\JVPhandlingstyper.csv -Delimiter ";" -Encoding utf8NoBOM


foreach($dpl in $CSVdia){
    $dplbeteckning = $dpl.prim_nr
    $dpltext = $dpl.prim_text
    foreach($arende in $CSVare){
        $dplan = $arende.prim_nr
        if($dplan -match $dplbeteckning){
            $arende.prim_nr = $dplan + " " + $dpltext
        }
    }
}
foreach($htyp in $CSVhty){
    $handtypkod = $htyp.atgard_typ
    $handtyptext = $htyp.atgard_typ_text
    foreach($handling in $CSVhan){
        $handlingstyp = $handling.atgard_typ
        if($handlingstyp -match $handtypkod){
            $handling.atgard_typ = $handling.atgard_typ.Replace($handtypkod,$handtyptext)
        }
    }
}
### Testa detta
foreach($arende in $CSVare){
    $arende.mod_dat = $arende.mod_dat.SubString(0,10)
    $arende.reg_dat = $arende.reg_dat.SubString(0,10)
    $arende.ankomst_dat = $arende.ankomst_dat.Substring(0,10)
    $arende.avslut_dat = $arende.avslut_dat.Substring(0,10)
    #Fattar inte felmeddelandena men funkar?
}
foreach($h in $CSVhan){
    $h.mod_dat = $h.mod_dat.SubString(0,10)
    $h.reg_dat = $h.reg_dat.SubString(0,10)
    $h.ink_dat = $h.ink_dat.Substring(0,10)
    $h.utg_dat = $h.utg_dat.Substring(0,10)
    #Fattar inte felmeddelandena men funkar?
}

foreach($user in $CSVusr){
    $usrsign = $user.usrsign
    $usrnamn = $user.usr_namn
    foreach($arende in $CSVare){
        $handlaggare = $arende.usrsign_handl
        $registrator = $arende.usrsign_reg
        if($handlaggare -match $usrsign){
            $arende.usrsign_handl = ($arende.usrsign_handl).Replace($usrsign,$usrnamn)
        }
        if($registrator -match $usrsign){
            $arende.usrsign_reg = ($arende.usrsign_reg).Replace($usrsign,$usrnamn)
        }

    }
}

foreach($user in $CSVusr){
    $usrsign = $user.usrsign
    $usrnamn = $user.usr_namn
    foreach($handling in $CSVhan){
        $handlaggare = $handling.usrsign_handl
        $registrator = $handling.usrsign_reg
        if($handlaggare -match $usrsign){
            $handling.usrsign_handl = ($handling.usrsign_handl).Replace($usrsign,$usrnamn)
        }
        if($registrator -match $usrsign){
            $handling.usrsign_reg = ($handling.usrsign_reg).Replace($usrsign,$usrnamn)
        }

    }
}

foreach($enhet in $CSVenh){
    $enhetkod = $enhet.enhet_kod
    $enhetnamn = $enhet.enhet_namn
    foreach($arende in $CSVare){
        $enhetskod = $arende.enhet_kod
        if($enhetskod -match $enhetkod){
            $arende.enhet_kod = ($arende.enhet_kod).Replace($enhetkod,$enhetnamn)
        }
    }
    foreach($handling in $CSVhan){
        $enhetskod = $handling.enhet_kod
        if($enhetskod -match $enhetkod){
            $handling.enhet_kod = ($handling.enhet_kod).Replace($enhetkod,$enhetnamn)
        }
    }
}



$Csvare | Export-Csv -Path C:\users\97arer14\Documents\CSVarefixed.csv -encoding utf8NoBOM -Delimiter ";" -UseQuotes Never
$csvhan | Export-CSV -Path C:\users\97arer14\Documents\CSVhanfixed.csv -encoding utf8NoBOM -Delimiter ";" -UseQuotes Never