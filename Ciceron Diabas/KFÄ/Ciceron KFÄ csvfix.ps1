#Script under uppbyggnad för mindre ändringar i information som kommer direkt från databas. System är Ciceron Diabas (Classic) 5.7. Databasen bör vara densamma för nyare versioner av Ciceron DoÄ.
#Kontakt: arvid.eriksson@norrtalje.se
#Skrivet för PowerShell 7.2


#Sökvägar till olika SQL-uttag
$CSVusr= Import-Csv .\Documents\KFÄDiariumAnvandare.csv -Delimiter "¤" -Encoding utf8NoBOM
$CSVare= Import-Csv .\Documents\KFÄDiariumArenden.csv -Delimiter "¤" -Encoding utf8NoBOM
$CSVhan= Import-CSV .\Documents\KFÄDiariumHandlingar.csv -Delimiter "¤" -Encoding utf8NoBOM
$CSVenh= Import-CSV .\Documents\KFÄDiariumEnhet.csv -Delimiter "¤" -encoding utf8NoBOM
$CSVdia= Import-CSV .\Documents\KFÄDiariumDiarieplan.csv -Delimiter "¤" -encoding utf8NoBOM
$CSVhty= Import-Csv .\Documents\KFÄDiariumHandlingstyper.csv -Delimiter "¤" -Encoding utf8NoBOM

Read-Host -Prompt "Kontrollera Linebreaks först, annars kommer den lägga på en massa ¤"

foreach($dpl in $CSVdia){
    $dplbeteckning = $dpl.prim_nr
    $dpltext = $dpl.prim_text
    foreach($arende in $CSVare){
        $dplan = $arende.prim_nr
        if($dplan -eq $dplbeteckning){
            $arende.prim_nr = $dplan + " " + $dpltext
        }
    }
}
foreach($htyp in $CSVhty){
    $handtypkod = $htyp.atgard_typ
    $handtyptext = $htyp.atgard_typ_text
    foreach($handling in $CSVhan){
        $handlingstyp = $handling.atgard_typ
        if($handlingstyp -eq $handtypkod){
            $handling.atgard_typ = $handling.atgard_typ.Replace($handtypkod,$handtyptext)
        }
    }
}
### Testa detta
foreach($arende in $CSVare){
    if('NULL' -ne $arende.mod_dat){
        $arende.mod_dat = $arende.mod_dat.SubString(0,10)
    }
    if('NULL' -ne $arende.reg_dat){
        $arende.reg_dat = $arende.reg_dat.SubString(0,10)
    }
    if('NULL' -ne $arende.ankomst_dat){
        $arende.ankomst_dat = $arende.ankomst_dat.Substring(0,10)
    }
    if('NULL' -ne $arende.avslut_dat){
        $arende.avslut_dat = $arende.avslut_dat.Substring(0,10)
    }
    
    
    
    
}
foreach($h in $CSVhan){
    if('NULL' -ne $h.mod_dat){
        $h.mod_dat = $h.mod_dat.SubString(0,10)
    }
    if('NULL' -ne $h.reg_dat){
        $h.reg_dat = $h.reg_dat.SubString(0,10)
    }
    if('NULL' -ne $h.ink_dat){
        $h.ink_dat = $h.ink_dat.Substring(0,10)
    }    
    if('NULL' -ne $h.utg_dat){
        $h.utg_dat = $h.utg_dat.Substring(0,10)
    }
    
    
    
}

foreach($user in $CSVusr){
    $usrsign = $user.usrsign
    $usrnamn = $user.usr_namn
    foreach($arende in $CSVare){
        $handlaggare = $arende.usrsign_handl
        $registrator = $arende.usrsign_reg
        if($handlaggare -eq $usrsign){
            $arende.usrsign_handl = ($arende.usrsign_handl).Replace($usrsign,$usrnamn)
        }
        if($registrator -eq $usrsign){
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
        if($handlaggare -eq $usrsign){
            $handling.usrsign_handl = ($handling.usrsign_handl).Replace($usrsign,$usrnamn)
        }
        if($registrator -eq $usrsign){
            $handling.usrsign_reg = ($handling.usrsign_reg).Replace($usrsign,$usrnamn)
        }

    }
}

foreach($enhet in $CSVenh){
    $enhetkod = $enhet.enhet_kod
    $enhetnamn = $enhet.enhet_namn
    foreach($arende in $CSVare){
        $enhetskod = $arende.enhet_kod
        if($enhetskod -eq $enhetkod){
            $arende.enhet_kod = ($arende.enhet_kod).Replace($enhetkod,$enhetnamn)
        }
    }
    foreach($handling in $CSVhan){
        $enhetskod = $handling.enhet_kod
        if($enhetskod -eq $enhetkod){
            $handling.enhet_kod = ($handling.enhet_kod).Replace($enhetkod,$enhetnamn)
        }
    }
}



$Csvare | Export-Csv -Path .\Documents\CSVarefixed.csv -encoding utf8NoBOM -Delimiter "¤" -UseQuotes Never
$csvhan | Export-CSV -Path .\Documents\CSVhanfixed.csv -encoding utf8NoBOM -Delimiter "¤" -UseQuotes Never