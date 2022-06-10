#Script under uppbyggnad för arkivering av information i databaser från Ciceron Classic (Ärende 5.7?) Databasen bör vara densamma för nyare versioner av Ciceron DoÄ.
#Kontakt: arvid.eriksson@norrtalje.se
#Skrivet för PowerShell 7.2
#Se även Ciceron CSVfix för förarbeten.

#För fält som kan innnehålla NULL för att vara på säkra sidan.
<#if("NULL" -eq $data){
    $tagg = $null
}
else{
    $tagg = $data
}#>

#Paths till CSV-filerna för handlingar och ärenden.
$CSVAr=Import-Csv "C:\Users\97arer14\Documents\CSVarefixed.csv" -Delimiter ";" -Encoding utf8NoBOM
$CSVHa=Import-Csv "C:\users\97arer14\Documents\csvhanfixed.csv" -Delimiter ";" -Encoding utf8NoBOM
$Diarium = Read-Host -Prompt "Vad ska diariebeteckningen vara på diariet?"
$Datum = Get-Date -Format yyyy-MM-ddTThhmm
$filnamn = $Diarium + $Datum + "Arkivexport.xml"
$XMLInit = @"
<Leveransobjekt xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://xml.ra.se/e-arkiv/FGS-ERMS" xsi:schemaLocation="http://xml.ra.se/e-arkiv/FGS-ERMS/arendehantering.xsd">
    <ArkivobjektListaArenden>
"@
$XMLInit | Out-File "C:\Users\97arer14\Documents\Arkivexport\$filnamn" -Encoding utf8NoBOM
$XMLEnd = @"
</ArkivobjektListaArenden>
</Leveransobjekt>
"@
foreach($arende in $csvar){
    $arendeGUID = New-Guid
    $ArkivobjektArende = @"
<ArkivobjektArende Systemidentifierare="UUID:$arendeGUID">
"@
    #Diarienummer
    $diarienummera = $arende.diarienr
    $arsub = $diarienummera.SubString(0,4)
    $arnusub = $diarienummera.SubString(4,6)
    $altdnr = $Diarium + " " + $arsub + "-" + $arnusub
    $arendenrsub = [int]$arnusub
    $arendenrstring = [string]$arendenrsub
    $trimmadochklartdiarienummer = $arsub + "-" + $arendenrstring
    $DNR = $Diarium + " " + $trimmadochklartdiarienummer
    $ArkivobjektIDAr = "<ArkivobjektID>$DNR</ArkivobjektID>"
    $ExtraIDAr = @"
    <ExtraID ExtraIDTyp="Äldre diarienummerformat">$altdnr</ExtraID>
"@
    #Arkiveringsdatum, tar bara det elektroniska för dagen, att ta analog information (från reversalerna) om när handlingar är arkiverade är onödigt.
    $arkiveringsdatum = Get-Date -Format yyyy-MM-dd
    $avslutsdatum = $arende.avslut_dat
    $Arkiverat= "<Arkiverat>$arkiveringsdatum</Arkiverat>"
    if('NULL' -eq $arende.avslut_dat){
        $Avslutat = $null
    }
    else {
    $Avslutat= "<Avslutat>$avslutsdatum</Avslutat>"
    }
    $regdatum=$arende.reg_dat
    $SkapadAr = "<Skapad>$regdatum</Skapad>"
    $mod_dat = $arende.mod_dat
    $SistaAnvandandetidpunktAr = "<SistaAnvandandetidpunkt>$mod_dat</SistaAnvandandetidpunkt>"

    #Ärendemening och beskrivning (de får båda vara samma bara för att kunna söka på både rubrik och ärendemening)
    $arendemen = $arende.arende_mening
    $BeskrivningAr = "<Beskrivning>$arendemen</Beskrivning>"
    $Arendemening = "<Arendemening>$arendemen</Arendemening>"
    #Registrator och handläggare # BEHÖVER LÖSA ENHET/ORGANISATION-PROBLEMET. Organisation nästan alltid Norrtälje kommun. Enhet behöver komma från DB. Enkel if-sats för möjliga enheter?ö
    #Tror att det är bäst att koda det separat. Alltså att ersätta CSV-filen som har koderna. 
    $registratora = $arende.usrsign_reg
    $arendeRegistrator = "<Namn>$registratora</Namn>"
    
    if("NULL" -eq $arende.usrsign_handl){
        $arendeHandlaggare = $null
    }
    else{
        $hndlgr = $arende.usrsign_handl 
        $arendeHandlaggare = "<Namn>$hndlgr</Namn>"
    }
    if("NULL" -eq $arende.enhet_kod){
        $arendeEnhet = $null
    }
    else{
        $enheta = $arende.enhet_kod
        $arendeEnhet = "<Enhetsnamn>$enheta</Enhetsnamn>"
    }
    #Organisation bör ändras beroende på vilket diarium
    if($null -eq $arendeHandlaggare){
        $AgentArendeHandlaggare = $null
    }
    else{
        $AgentArendeHandlaggare = "<Agent><Roll>Handläggare</Roll>$arendeHandlaggare<Organisationsnamn>Järnvägsparken</Organisationsnamn>$arendeEnhet</Agent>"
    }
    
    $AgentArendeRegistrator = "<Agent><Roll>Registrator</Roll>$arendeRegistrator<Organisationsnamn>Norrtälje kommun</Organisationsnamn>$arendeEnhet</Agent>"
    

    #diarieplan Klasstaggen
    $dpl = $arende.prim_nr
    $klass = "<Klass>$dpl</Klass>"
    #Restriktion
    if($arende.andra_beh -ne "W"){
        $RestriktionAr = @"
<Restriktion Typ="Sekretess"><ForklarandeText>Ärendet hade begränsning i systemet, pröva sekretess</ForklarandeText></Restriktion>
"@
    }
    else{
        $RestriktionAr = $null
    }
    #Motpart är ärendenivå, mottagare är motpart för expedierad handling, avsändare är motpart för inkommen handling. (återanvänds för handlingsmotpart, kund)

    #Måste också kolla större diarium om det finns mer saker i atg_pers_fakta
    if("NULL" -eq $arende.kund_namn){
        $MotpartNamn = $null
    }
    else{
    $motpartname = $arende.kund_namn
    $MotpartNamn = "<Namn>$motpartname</Namn>"
    }
    if("NULL" -eq $arende.kund_gadr1){
        $MotpartOrganisation = $null
    }
    else{
        $motpartkau = $arende.kund_gadr1
        $MotpartOrganisation = "<Organisation>$motpartkau</Organisation>"
    }
    if("NULL" -eq $arende.kund_gadr2){
        $MotpartPostadress = $null
    }
    else{
        $motpartgatadr = $arende.kund_gadr2
        $MotpartPostadress = "<Postadress>$motpartgatadr</Postadress>"
    }
    if("NULL" -eq $arende.kund_postnr){
        $MotpartPostnummer = $null
    }
    else{
        $motpartpostnr = $arende.kund_postnr
        $MotpartPostnummer = "<Postnummer>$motpartpostnr</Postnummer>"
    }
    if("NULL" -eq $arende.kund_padr){
        $MotpartPostort = $null
    }
    else{
        $motpartpostor = $arende.kund_padr
        $MotpartPostort = "<Postort>$motpartpostor</Postort>"
    }

    #Verkar vara relativt sporadiskt hur motpartorg/kundadressuppgift har satts. Får kolla mer på större diarium.
    #Finns också mer information om personen i atg_pers_fakta
    if(("NULL" -eq $arende.kund_namn) -and ("NULL" -eq $arende.kund_gadr1)){
        $Motpart = $null
    }
    else{
        $Motpart = @"
        <Motpart>
            $MotpartNamn
            $MotpartOrganisation
            $MotpartPostadress
            $MotpartPostnummer
            $MotpartPostort
        </Motpart>
"@
    }
    #inkommen/upprättad för ärende, kommer förmodligen se annorlunda ut i andra diarium, nu verkar det bara vara inkomstdatum som finns ifyllt
    $inkommena = $arende.ankomst_dat
    if("NULL" -ne $inkommena){
        $InkommenArende = "<Inkommen>$inkommena</Inkommen>"
    }
    else{
        $InkommenArende = $null
    }
    



    $HandlingsXMLavslut = "</ArkivobjektListaHandlingar>"
    $HandlingsXML = "<ArkivobjektListaHandlingar>"
    
    foreach($handling in $CSVHa){
        $diarienummerh = $handling.diarienr
        if($diarienummerh -eq $diarienummera){
            $handlingsnummer = $handling.atgardsnr
            $HandlingLopnummer = "<Lopnummer>$handlingsnummer</Lopnummer>"
            $handlingstyp = $handling.atgard_typ
            
            $registratorh = $handling.usrsign_reg
            $handlingRegistrator = "<Namn>$registratorh</Namn>"
            
            if("NULL" -eq $handling.enhet_kod){
                $handlingEnhet = $null
            }
            else{
                $enheth = $handling.enhet_kod
                $handlingEnhet = "<Enhetsnamn>$enheth</Enhetsnamn>"
            }
            if("NULL" -eq $handling.usrsign_handl){
                $AgentHandlingHandlaggare = $null
            }
            else{
                $hndlgr = $handling.usrsign_handl 
                $handlingHandlaggare = "<Namn>$hndlgr</Namn>"
                $AgentHandlingHandlaggare = "<Agent><Roll>Handläggare</Roll>$handlingHandlaggare<Organisationsnamn>Järnvägsparken</Organisationsnamn>$handlingEnhet</Agent>"
            }
            
            $AgentHandlingRegistrator = "<Agent><Roll>Registrator</Roll>$handlingRegistrator<Organisationsnamn>Norrtälje kommun</Organisationsnamn>$handlingEnhet</Agent>"

            if("NULL" -eq $handling.kund_namn){
                $MotpartNamn = $null
            }
            else{
            $motpartname = $handling.kund_namn
            $MotpartNamn = "<Namn>$motpartname</Namn>"
            }
            if("NULL" -eq $handling.kund_gadr1){
                $MotpartOrganisation = $null
            }
            else{
                $motpartkau = $handling.kund_gadr1
                $MotpartOrganisation = "<Organisation>$motpartkau</Organisation>"
            }
            if("NULL" -eq $handling.kund_gadr2){
                $MotpartPostadress = $null
            }
            else{
                $motpartgatadr = $handling.kund_gadr2
                $MotpartPostadress = "<Postadress>$motpartgatadr</Postadress>"
            }
            if("NULL" -eq $handling.kund_postnr){
                $MotpartPostnummer = $null
            }
            else{
                $motpartpostnr = $handling.kund_postnr
                $MotpartPostnummer = "<Postnummer>$motpartpostnr</Postnummer>"
            }
            if("NULL" -eq $handling.kund_padr){
                $MotpartPostort = $null
            }
            else{
                $motpartpostor = $handling.kund_padr
                $MotpartPostort = "<Postort>$motpartpostor</Postort>"
            }
            ############## Lägg till
            #### skriv eventuellt in avsändaretaggen för inkommande och mottagaretagge för expedierade. Men blir lite grötigt...
            if($handling.ink_utg -eq "I"){
                $handlinginkdat = $handling.ink_dat
                $handlingInkommande = "<Inkommen>$handlinginkdat</Inkommen>"
                $handlingUtgaende = $null
                $Mottagare = $null
                $StatusHandling = "<StatusHandling>Inkommen</StatusHandling>"
                if(($handling.kund_namn -eq "NULL")-and($handling.kund_gadr1 -eq "NULL")){
                    $Avsandare = $null
                }
                else{
                    $Avsandare = @"
                    <Avsandare>
                        $MotpartNamn
                        $MotpartOrganisation
                        $MotpartPostadress
                        $MotpartPostnummer
                        $MotpartPostort
                    </Avsandare>
"@
                }
            }
            #Varning här att det finns en UPPR i riktining enligt databasen, bara inte använd. UPPR bör om det förekommer användas för att skapa Upprättad taggen och sätta status
            #I nuläget är det en fuling som säger att om handlingen har status U (utgående) men inte har en mottagare är den upprättad. Datum för upprättandet blir...? Förekommer ju inte...
            elseif($handling.ink_utg -eq "U"){
                $handlingutgdat = $handling.utg_dat
                $handlingUtgaende = "<Expedierad>$handlingutgdat</Expedierad>"
                $handlingInkommande = $null
                $Avsandare = $null
                $StatusHandling = "<StatusHandling>Expedierad</StatusHandling>"
                if(($motpartname -eq "NULL")-and($motpartkau -eq "NULL")){
                    $Mottagare = $null
                    $StatusHandling = "<StatusHandling>Upprättad</StatusHandling>"
                    
                    #$handlingUpprattad = "<Upprattad>Tidpunkt"
                    $handlingUtgaende = $null
                }
                else{
                    $Mottagare = @"
                    <Mottagare>
                        $MotpartNamn
                        $MotpartOrganisation
                        $MotpartPostadress
                        $MotpartPostnummer
                        $MotpartPostort
                    </Mottagare>
"@
                }
            }
            else{
                $handlingInkommande = $null
                $handlingUtgaende = $null
            }


            ####
            $handlingsGUID = New-Guid
            $handlingsarkivobjektID = $DNR + "-" + $handlingsnummer
            $handlingsaltdnr = $altdnr +"-"+ $handlingsnummer
            $BeskrivningHa = $handling.atgard_text
            $HandlingsBeskrivning = "<Beskrivning>$BeskrivningHa</Beskrivning>"
            #eventuellt onödigt, men gör det en gnutta mer sökbart.
            $HandlingsRubrik = "<Rubrik>$BeskrivningHa</Rubrik>"
            $haregdat = $handling.reg_dat
            $SkapadHa = "<Skapad>$haregdat</Skapad>"
            $mod_dath = $handling.mod_dat
            $SistaAnvandandetidpunktHa = "<SistaAnvandandetidpunkt>$mod_dath</SistaAnvandandetidpunkt>"
            if($handling.andra_beh -ne "W"){
                $RestriktionHa = @"
        <Restriktion Typ="Sekretess"><ForklarandeText>Handlingen hade begränsning i systemet, pröva sekretess</ForklarandeText></Restriktion>
"@
            }
            else{
                $RestriktionHa = $null
            }
            
            $HandlingsXML += @"
<ArkivobjektHandling Systemidentifierare="UUID:$handlingsGUID">
"@
            $HandlingsXML += "<ArkivobjektID>$handlingsarkivobjektID</ArkivobjektID>"
            $HandlingsXML += @"
<ExtraID ExtraIDTyp="Äldre diarienummerformat">$handlingsaltdnr</ExtraID>
"@
            $HandlingsXML += "<Handlingstyp>$handlingstyp</Handlingstyp>"
            $HandlingsXML += $Avsandare
            $HandlingsXML += $HandlingsBeskrivning
            $HandlingsXML += $handlingUtgaende
            $HandlingsXML += @"
<Gallring Gallras="false"/>
"@
            $HandlingsXML += $AgentHandlingHandlaggare
            $HandlingsXML += $AgentHandlingRegistrator
            $HandlingsXML += $handlingInkommande
            $HandlingsXML += $handlingLopnummer
            $HandlingsXML += $Mottagare
            #Återstår att läggas till
            $HandlingsXML += $NoteringHandling
            $HandlingsXML += $HandlingsRubrik #Onödigt ju, är samma som beskrivning
            $HandlingsXML += $SkapadHa
            $HandlingsXML += $SistaAnvandandetidpunktHa
            $HandlingsXML += $StatusHandling
            #$HandlingsXML += $Upprattad
            $HandlingsXML += "<Atkomst>Norrtälje stadsarkiv</Atkomst>"
            $HandlingsXML += $RestriktionHa
            #HandlingsXML += $Bilaga
            $HandlingsXML += "</ArkivobjektHandling>"
        }     
    }
##Borde gå att lägga ihop $HandlingsXML och $HandlingsXMLAvslut och om de är det enda sätt båda till null
$Handlingslista = $HandlingsXML + $HandlingsXMLAvslut    
if($Handlingslista -eq "<ArkivobjektListaHandlingar></ArkivobjektListaHandlingar>"){
    $HandlingsXML = $null
    $HandlingsXMLavslut = $null
}

#Finns bara avslutade ärenden (hoppas jag)
$XMLStart = @"

        $ArkivobjektArende
            $ArkivObjektIDAr
            $ExtraIDAr
            $Arkiverat
            $Avslutat
            $BeskrivningAr
            <Gallring Gallras="false"/>
            $AgentArendeHandlaggare
            $AgentArendeRegistrator
            $Klass
            $RestriktionAr
            $Motpart
            $NoteringArende
            $SistaAnvandandetidpunktAr
            $SkapadAr
            $InkommenArende
            <StatusArande>Ad Acta.</StatusArande>
            $UpprattadArende
            $ExpedieradArende
            $Arendemening
                $HandlingsXML
                $HandlingsXMLavslut
        </ArkivobjektArende>
"@

$XMLStart | Out-File "C:\Users\97arer14\Documents\Arkivexport\$filnamn" -Encoding utf8NoBOM -Append
}
$XMLEnd | Out-File "C:\Users\97arer14\Documents\Arkivexport\$filnamn" -Encoding utf8NoBOM -Append
