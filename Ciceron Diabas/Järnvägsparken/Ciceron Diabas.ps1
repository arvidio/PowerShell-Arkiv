#Script för arkivering av Järnvägsparkens handlingar.



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
$CSVdo=Import-Csv "C:\Users\97arer14\Documents\CESVE.csv" -Delimiter ";" -Encoding utf8BOM

New-Item -Name "Arkivexport" -ItemType Directory -Path C:\Users\97arer14\Documents
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
        $AgentArendeHandlaggare = "<Agent><Roll>Handläggare</Roll>$arendeHandlaggare $arendeEnhet</Agent>"
    }
    
    $AgentArendeRegistrator = "<Agent><Roll>Registrator</Roll>$arendeRegistrator $arendeEnhet</Agent>"
    

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
            #Bilagor ######################################################################
            $HandlingAssocDokID = "$diarienummerh"+ ":$handlingsnummer"
            #Tömmer Bilagor från föregående...
            $Bilagor = $null
            foreach($dokument in $CSVdo){
                $dokcsvidf = $dokument.assoc_data
                if($dokcsvidf -eq $HandlingAssocDokID){
                    $HandlingsLagrdata = $dokument.lagr_data
                    if('NULL' -eq $HandlingsLagrdata){
                        $Bilagor = $null
                    }
                    else{
                        $nummer = $HandlingsLagrdata
                        $paddatnummer = $nummer.PadLeft(10,[char]"0")
                        $eftervol1 = $paddatnummer[0] + $paddatnummer[1] + $paddatnummer[2] + "\" + $paddatnummer[3] + $paddatnummer[4] + $paddatnummer[5] + "\" + $paddatnummer[6] + $paddatnummer[7] + "\" + $paddatnummer
                        $fullpath = "\\nkadmdiabas01\D$\diabas\famdata\vol1\" + $eftervol1
                        $filer = Get-ChildItem "$fullpath"
                        $n = 1
                        
                        foreach($fil in $filer){
                            if($fil.Extension -eq $fil.Name){
                                Write-host "Göringe"
                            
                        }
                            else{
                                $filext = $fil.Extension
                                $nypath = "C:\Users\97arer14\Documents\Arkivexport\$diarienummerh"+"_$handlingsnummer"+"_"+"$n"+"$filext"
                                $n++
                                Copy-Item $fil -Destination $nypath
                                $nyfil = Get-ChildItem $nypath
                                #Bevarar gamla filnamnet i ett attribut
                                $BilagaFileName = $fil.Name
                                $BilagaFileHashAll = $nyfil | Get-FileHash
                                $BilagaFileHash = $BilagaFileHashAll.Hash
                                $BilagaLank = $nyfil.Name
                                $BilagaStorlek = $nyfil.Length
                                $Bilagor += @"
                                    <Bilaga Namn="$BilagaFileName" Lank="$BilagaLank" Storlek="$BilagaStorlek" Checksumma="$BilagaFileHash" ChecksummaMetod="SHA-256"/>
"@

                            }
                        }

                    }
                }
            }
            #Bilagor slut ##################################################################
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
            $HandlingsXML += $Bilagor
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

### Skapa ett arkivpaket
Read-Host -Prompt "Kör gärna en prettyprint på arkivexport.xml och ta bort .bakfilen :)"

$LevFiler = Get-ChildItem -Path C:\Users\97arer14\Documents\Arkivexport -Exclude *.xml
$LevXMLfiler = Get-ChildItem -Path C:\users\97arer14\documents\Arkivexport\*.xml
$XSDfil = Get-ChildItem -Path C:\Users\97arer14\Documents\Script\KEEP\arendehantering.xsd
New-Item -Name "Paket" -ItemType Directory -Path "C:\Users\97arer14\Documents\Arkivexport\"
New-Item -Name "Leveranspaket" -ItemType Directory -Path "C:\Users\97arer14\Documents\Arkivexport\Paket\"
New-Item -Name "Content" -ItemType Directory -Path "C:\Users\97arer14\Documents\Arkivexport\Paket\Leveranspaket\"
New-Item -Name "1" -ItemType Directory -Path "C:\Users\97arer14\Documents\Arkivexport\Paket\Leveranspaket\Content\"
New-Item -Name "2" -ItemType Directory -Path "C:\Users\97arer14\Documents\Arkivexport\Paket\Leveranspaket\Content\"
New-Item -Name "System" -ItemType Directory -Path "C:\Users\97arer14\Documents\Arkivexport\Paket\Leveranspaket\"

$OBJIDGUIDObject=New-Guid
$OBJIDGUID=$OBJIDGUIDObject.Guid
$DateTimeExtended = Get-Date -Format yyyy-MM-ddTHH:mm:ss
$DateYYYYMMDD = Get-Date -Format yyyy-MM-dd

foreach($afile in $LevFiler){
    #Variabler relaterat till filer
    $filename=$afile.Name
    $fileGUIDObject = New-Guid
    $fileGUID = $fileGUIDObject.Guid
    $fileLastWriteTimeDate = $afile | Select-Object -ExpandProperty LastWriteTime | Get-Date -Format yyyy-MM-ddTHH:mm:ss
    $fileSize = $afile.length
    $fileExtUse = $afile.Extension.trim(".","1")
    $fileChecksumSHA256Object = $afile | Get-FileHash -Algorithm SHA256
    $fileChecksumSHA256 = $fileChecksumSHA256Object.Hash
    
    if($afile.Extension -eq ".tif"){
        $MIMEType = "image/tiff"
    }
    elseif($afile.Extension -eq ".pdf"){
        $MIMEType = "application/pdf"
    }
    elseif($afile.Extension -eq ".doc"){
        $MIMEType = "application/msword"
    }
    else{
        $MIMEType = $null
        $afile.Extension
        "Behöver läggas till MIMETYPE för den."
    }
    $metsfilexml=@"
    <mets:file ID="ID$fileGUID" USE="$fileExtUse" MIMETYPE="$MIMEType" SIZE="$fileSize" CREATED="$fileLastWriteTimeDate" CHECKSUM="$fileChecksumSHA256" CHECKSUMTYPE="SHA-256" ext:ORIGINALFILENAME="$filename">
        <mets:FLocat LOCTYPE="URL" xlink:type="simple" xlink:href="file:///Content/1/$filename"/>
    </mets:file>
"@

Copy-Item $afile.FullName -Destination C:\Users\97arer14\Documents\Arkivexport\Paket\Leveranspaket\Content\1
$metsfilexml | Out-File C:\Users\97arer14\Documents\Script\metsfiles.xml -Encoding utf8NoBOM -Append
}
foreach($xfile in $LevXMLFiler){
    #Variabler relaterat till filer
    $filename=$xfile.Name
    $fileGUIDObject = New-Guid
    $fileGUID = $fileGUIDObject.Guid
    $fileLastWriteTimeDate = $xfile | Select-Object -ExpandProperty LastWriteTime | Get-Date -Format yyyy-MM-ddTHH:mm:ss
    $fileSize = $xfile.length
    $fileExtUse = $xfile.Extension.trim(".","1")
    $fileChecksumSHA256Object = $xfile | Get-FileHash -Algorithm SHA256
    $fileChecksumSHA256 = $fileChecksumSHA256Object.Hash
    
    
    $metsfilexml=@"
    <mets:file ID="ID$fileGUID" USE="$fileExtUse" MIMETYPE="text/xml" SIZE="$fileSize" CREATED="$fileLastWriteTimeDate" CHECKSUM="$fileChecksumSHA256" CHECKSUMTYPE="SHA-256" ext:ORIGINALFILENAME="$filename">
        <mets:FLocat LOCTYPE="URL" xlink:type="simple" xlink:href="file:///Content/2/$filename"/>
    </mets:file>
"@
Copy-Item $xfile.FullName -Destination C:\Users\97arer14\Documents\Arkivexport\Paket\Leveranspaket\Content\2
$metsfilexml | Out-File C:\Users\97arer14\Documents\Script\metsfiles.xml -Encoding utf8NoBOM -Append
}
foreach($xsdfile in $XSDfil){
    #Variabler relaterat till filer
    $filename=$xsdfile.Name
    $fileGUIDObject = New-Guid
    $fileGUID = $fileGUIDObject.Guid
    $fileLastWriteTimeDate = $xsdfile | Select-Object -ExpandProperty LastWriteTime | Get-Date -Format yyyy-MM-ddTHH:mm:ss
    $fileSize = $xsdfile.length
    $fileExtUse = $xsdfile.Extension.trim(".","1")
    $fileChecksumSHA256Object = $xsdfile | Get-FileHash -Algorithm SHA256
    $fileChecksumSHA256 = $fileChecksumSHA256Object.Hash
    
    
    $metsfilexml=@"
    <mets:file ID="ID$fileGUID" USE="$fileExtUse" MIMETYPE="text/xml" SIZE="$fileSize" CREATED="$fileLastWriteTimeDate" CHECKSUM="$fileChecksumSHA256" CHECKSUMTYPE="SHA-256" ext:ORIGINALFILENAME="$filename">
        <mets:FLocat LOCTYPE="URL" xlink:type="simple" xlink:href="file:///System/$filename"/>
    </mets:file>
"@

Copy-Item $xsdfile.FullName -Destination C:\Users\97arer14\Documents\Arkivexport\Paket\Leveranspaket\System
$metsfilexml | Out-File C:\Users\97arer14\Documents\Script\metsfiles.xml -Encoding utf8NoBOM -Append
}



$metsfilesxmloutput=Get-ChildItem -Path C:\Users\97arer14\Documents\Script\metsfiles.xml
$metsfiles = Get-Content $metsfilesxmloutput -Encoding utf8NoBOM -Raw
remove-item $metsfilesxmloutput

$XMLSIPdokument=@"
<?xml version="1.0" encoding="UTF-8"?>
<mets:mets xmlns:mets="http://www.loc.gov/METS/"
           xmlns:xlink="http://www.w3.org/1999/xlink"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xmlns:ext="ExtensionMETS"
           OBJID="GUID:$OBJIDGUID"
           LABEL="Diarieförda ärenden Järnvägsparken, ur Ciceron Diabas"
           TYPE="ERMS"
           PROFILE="http://xml.ra.se/e-arkiv/METS/CommonSpecificationSwedenPackageProfile.xml"
           ext:ACCESSRESTRICT="Secrecy and PuL"
           ext:AGREEMENTFORM="AGREEMENT"
           ext:APPRAISAL="No"
           ext:ARCHIVALNAME="FASTIGHETSBOLAGET JÄRNVÄGSPARKEN HB"
           ext:PACKAGENUMBER="1"
           ext:SYSTEMTYPE="Ärendehanteringssystem">
  <mets:metsHdr CREATEDATE="$DateTimeExtended"
                RECORDSTATUS="NEW"
                ext:OAISSTATUS="SIP">
    <mets:agent ROLE="CREATOR"
                TYPE="INDIVIDUAL">
      <mets:name>Järnvägsparken HB</mets:name>
    </mets:agent>
    <mets:agent ROLE="CREATOR"
                TYPE="ORGANIZATION">
      <mets:name>Norrtälje stadsarkiv</mets:name>
    </mets:agent>
    <mets:agent ROLE="EDITOR"
                TYPE="ORGANIZATION">
      <mets:name/>
    </mets:agent>
    <mets:agent ROLE="ARCHIVIST"
                TYPE="ORGANIZATION">
      <mets:name>FASTIGHETSBOLAGET JÄRNVÄGSPARKEN HB</mets:name>
      <mets:note>Local:1673</mets:note>
    </mets:agent>
    <mets:agent ROLE="PRESERVATION"
                TYPE="ORGANIZATION">
      <mets:name>Norrtälje stadsarkiv</mets:name>
    </mets:agent>
    <mets:agent ROLE="IPOWNER"
                TYPE="ORGANIZATION">
      <mets:name>KOMMUNSTYRELSEN</mets:name>
      <mets:note>Local:10002</mets:note>
    </mets:agent>
    <mets:agent ROLE="OTHER"
                OTHERROLE="SUBMITTER"
                TYPE="ORGANIZATION">
      <mets:name>Norrtälje stadsarkiv</mets:name>
    </mets:agent>
    <mets:agent ROLE="OTHER"
                OTHERROLE="PRODUCER"
                TYPE="ORGANIZATION">
      <mets:name>Norrtälje stadsarkiv</mets:name>
    </mets:agent>
    <mets:agent ROLE="CREATOR"
                TYPE="OTHER"
                OTHERTYPE="SOFTWARE">
      <mets:name>Script</mets:name>
    </mets:agent>
    <mets:agent ROLE="ARCHIVIST"
                TYPE="OTHER"
                OTHERTYPE="SOFTWARE">
      <mets:name>Ciceron Classic</mets:name>
      <mets:note>5.7.0</mets:note>
    </mets:agent>
    <mets:altRecordID TYPE="SUBMISSIONAGREEMENT">$DateYYYYMMDD</mets:altRecordID>
  </mets:metsHdr>
  <mets:fileSec>
    <mets:fileGrp ID="fgrp001"
                  USE="FILES">
$metsfiles
    </mets:fileGrp>
  </mets:fileSec>
  <mets:structMap LABEL="No structMap defined in this information package">
    <mets:div LABEL="Empty"/>
  </mets:structMap>
</mets:mets>
"@

$XMLSIPdokument | Out-File C:\users\97arer14\Documents\Arkivexport\Paket\Leveranspaket\sip.xml -Encoding utf8

Compress-Archive -Path C:\Users\97arer14\Documents\Arkivexport\Paket\Leveranspaket\* -DestinationPath "C:\users\97arer14\Documents\Script\JVPDiabas$DateYYYYMMDD" -CompressionLevel Optimal -Force
Remove-Item -Path C:\Users\97arer14\Documents\Arkivexport\ -Recurse