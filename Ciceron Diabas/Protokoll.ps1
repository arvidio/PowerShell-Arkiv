#Kört detta innan, bara för att få bort timmar och sekunder från mod_datum. Irrelevant i sammanhanget och skapar valideringsproblem (vill inte skriva att jag är lat).
<#

$CSV = Import-CSV .\Documents\BSNProtokoll.csv -Delimiter '♥' -Encoding utf8NoBOM
foreach($row in $CSV){
    if('NULL' -ne $row.mod_dat){
        $row.mod_dat = $row.mod_dat.SubString(0,10)
    }
}
$CSV | Export-Csv -Path .\Documents\Protokollfixad.csv -encoding utf8NoBOM -Delimiter "♥" -UseQuotes Never

#>

$CSV= Import-CSV .\Documents\Protokollfixad.CSV -Delimiter '♥' -Encoding utf8NoBOM


#
$HandlingsXML = $null #Bara för att fixa återkörning
$DagensDatum = Get-Date -Format yyyy-MM-ddTTHHmm
$Namnd = Read-Host -Prompt "Skriv BSN, BMN, FMN, KFN, KS, NKAB, ON, SN, THN, UN eller VN"
$Arkivbildare = Read-Host -Prompt "Skriv in arkivbildare i versaler, typ KOMMUNSTYRELSEN"
$kod = Read-Host -Prompt "Skriv in siffrorna för arkivbildarens lokala kod från Visual Arkiv"
#Nedan får alla handlingar inlagda i sig på rad.
$filnamn = $Namnd + $DagensDatum + "ProtokollExport.xml"
$XMLInit = @"
<Leveransobjekt xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://xml.ra.se/e-arkiv/FGS-ERMS" xsi:schemaLocation="http://xml.ra.se/e-arkiv/FGS-ERMS/arendehantering.xsd">
    <ArkivobjektListaHandlingar>
"@
$XMLInit | Out-File ".\Documents\Arkivexport\$filnamn" -Encoding utf8NoBOM
#Används i slutet av scriptet när alla loopar är genomförda
$XMLEnd = @"
</ArkivobjektListaHandlingar>
</Leveransobjekt>
"@

$SlutTagg = "</ArkivobjektHandling>"

foreach($row in $CSV){
    $SystemidentifierareGUID = New-Guid
    $StartTagg = @"
<ArkivobjektHandling Systemidentifierare="$SystemidentifierareGUID">
"@
    #ArkivobjektID
    #Nämnd + dokid? typ det enda jag kan tänka mig.
    $DokumentID = $row.dok_id
    $ArkivobjektIDTagg = "<ArkivobjektID>$Namnd-$DokumentID</ArkivobjektID>"

    #Beskrivning
    $beskr = $row.beskr
    $BeskrivningTagg = "<Beskrivning>$beskr</Beskrivning>"
    
    #Gallring
    $GallringsTagg = '<Gallring Gallras="false"/>'

    #Rubrik
    #Lägger den under Egnaelement i scriptet då den använder samma variabler.

    #Skapad
    $Skapad = $row.reg_dat
    $SkapadTagg = "<Skapad>$Skapad</Skapad>"

    #SistaAnvändandetidpunkt
    $SistaAtp = $row.mod_dat
    $SistaAnvandandetidpunktTagg = "<SistaAnvandandetidpunkt>$SistaATP</SistaAnvandandetidpunkt>"
    
    #Åtkomst
    $AtkomstTagg = "<Atkomst>Originalprotokollen finns på Norrtälje stadsarkiv</Atkomst>"

    #Bilaga
    $Bilagor = $null #tömmer variabeln från tidigare loop
    $nummer = $row.lagr_data
    $paddatnummer = $nummer.PadLeft(10,[char]"0")
    $eftervol1 = $paddatnummer[0] + $paddatnummer[1] + $paddatnummer[2] + "\" + $paddatnummer[3] + $paddatnummer[4] + $paddatnummer[5] + "\" + $paddatnummer[6] + $paddatnummer[7] + "\" + $paddatnummer
    $fullpath = "\\nkadmdiabas01\D$\diabas\famdata\vol1\" + $eftervol1
    $filer = Get-ChildItem "$fullpath"
    $n = 1
                        
    foreach($fil in $filer){
            if($fil.Extension -eq $fil.Name){
                    $fil.Name
                    }
            else{
                    $filext = $fil.Extension
                    $nypath = ".\Documents\Arkivexport\$dokumentid"+"_$Namnd"+"_"+"$n"+"$filext"
                    $testpath = Test-Path $nypath
                    $n++
                    if($testpath -eq $true){
                        "$nypath finns redan, lägg på lite (kolla mappen så att inte nästkommande nummer också finns)"
                        $n = Read-Host -Prompt "Skriv en siffra (gärna 2,3,4,5, i ordning)"
                        $nypath = ".\Documents\Arkivexport\$dokumentid"+"_$Namnd"+"_"+"$n"+"$filext"
                    }
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

    #EgnaElement
    $InstansDatum = $row.Assoc_fritext

    $Beslutsinstans1 = $InstansDatum.Split(': ')[1]
    $Beslutsinstans2 = $Beslutsinstans1.Split(',')[0]
    $Beslutsinstans = $Beslutsinstans2.Trim()   
    $BeslutsinstansTagg = @"
    <EgetElement Namn="Beslutsinstans" DataTyp="String">
        <Varde>$Beslutsinstans</Varde>
    </EgetElement>

"@

    $SammantradesDatum1 = $InstansDatum.Split(': ')[2]
    $SammantradesDatum = $SammantradesDatum1.Trim()
    $SammantradesdatumTagg = @"
    <EgetElement Namn="Sammanträdesdatum" DataTyp="String">
        <Varde>$SammantradesDatum</Varde>
    </EgetElement>
"@
$EgetElement = $BeslutsinstansTagg + $SammantradesdatumTagg

$EgnaElementTagg = @"
<EgnaElement>
$EgetElement
</EgnaElement>
"@
    
#Rubrik (Ligger här för att den använder samma variabler som EgnaElement)
$Rubrikstring = "Protokoll från $Beslutsinstans $SammantradesDatum"
$RubrikTagg = "<Rubrik>$Rubrikstring</Rubrik>"

#Skriv ut informationen
$HandlingsXML += $StartTagg
$HandlingsXML += $ArkivobjektIDTagg
$HandlingsXML += $BeskrivningTagg
$HandlingsXML += $GallringsTagg
$HandlingsXML += $RubrikTagg
$HandlingsXML += $SkapadTagg
$HandlingsXML += $SistaAnvandandetidpunktTagg
$HandlingsXML += $AtkomstTagg
$HandlingsXML += $Bilagor
$HandlingsXML += $EgnaElementTagg
$HandlingsXML += $SlutTagg
}
$HandlingsXML += $XMLEnd
$HandlingsXML | Out-File ".\Documents\Arkivexport\$filnamn" -Encoding utf8NoBOM -Append

Read-Host -Prompt "Fungerade det så långt?"

$x = [XML](Get-Content ".\Documents\Arkivexport\$filnamn")
$x.Save(".\Documents\Arkivexport\$filnamn")

Read-Host -Prompt "Fungerade PrettyPrint?"

$LevFiler = Get-ChildItem -Path ".\Documents\Arkivexport" -Exclude *.xml
$LevXMLfiler = Get-ChildItem -Path .\documents\Arkivexport\*.xml
$XSDfil = Get-ChildItem -Path .\Documents\Script\KEEP\arendehantering.xsd
New-Item -Name "Paket" -ItemType Directory -Path .\Documents\Arkivexport\
New-Item -Name "Leveranspaket" -ItemType Directory -Path .\Documents\Arkivexport\Paket\
New-Item -Name "Content" -ItemType Directory -Path .\Documents\Arkivexport\Paket\Leveranspaket\
New-Item -Name "1" -ItemType Directory -Path .\Documents\Arkivexport\Paket\Leveranspaket\Content\
New-Item -Name "2" -ItemType Directory -Path .\Documents\Arkivexport\Paket\Leveranspaket\Content\
New-Item -Name "System" -ItemType Directory -Path .\Documents\Arkivexport\Paket\Leveranspaket\

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
    elseif($afile.Extension -eq ".txt"){
        $MIMEType = "text/plain"
    }
    elseif($afile.Extension -eq ".eml"){
        $MIMEType = "application/octet-stream"
    }
    elseif($afile.Extension -eq ".docx"){
        $MIMEType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    }
    elseif($afile.Extension -eq ".jpg"){
        $MIMEType = "image/jpeg"
    }
    elseif($afile.Extension -eq ".rtf"){
        $MIMEType = "text/rtf"
    }
    elseif($afile.Extension -eq ".xls"){
        $MIMEType = "application/vnd.ms-excel"
    }
    elseif($afile.Extension -eq ".xlsx"){
        $MIMEType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    }
    elseif($afile.Extension -eq ".pptx"){
        $MIMEType = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    }
    elseif($afile.Extension -eq ".htm"){
        $MIMEType = "text/html"
    }
    elseif($afile.Extension -eq ".png"){
        $MIMEType = "image/png"
    }
    elseif($afile.Extension -eq ".odt"){
        $MIMEType = "application/vnd.oasis.opendocument.text"
    }
    elseif($afile.Extension -eq ".msg"){
        $MIMEType = "application/octet-stream"
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

Copy-Item $afile.FullName -Destination .\Documents\Arkivexport\Paket\Leveranspaket\Content\1
$metsfilexml | Out-File .\Documents\Script\metsfiles.xml -Encoding utf8NoBOM -Append
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
Copy-Item $xfile.FullName -Destination .\Documents\Arkivexport\Paket\Leveranspaket\Content\2
$metsfilexml | Out-File .\Documents\Script\metsfiles.xml -Encoding utf8NoBOM -Append
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

Copy-Item $xsdfile.FullName -Destination .\Documents\Arkivexport\Paket\Leveranspaket\System
$metsfilexml | Out-File .\Documents\Script\metsfiles.xml -Encoding utf8NoBOM -Append
}



$metsfilesxmloutput=Get-ChildItem -Path .\Documents\Script\metsfiles.xml
$metsfiles = Get-Content $metsfilesxmloutput -Encoding utf8NoBOM -Raw
remove-item $metsfilesxmloutput

$XMLSIPdokument=@"
<?xml version="1.0" encoding="UTF-8"?>
<mets:mets xmlns:mets="http://www.loc.gov/METS/"
           xmlns:xlink="http://www.w3.org/1999/xlink"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xmlns:ext="ExtensionMETS"
           OBJID="GUID:$OBJIDGUID"
           LABEL="Protokoll från $Arkivbildare, ur Ciceron Diabas."
           TYPE="ERMS"
           PROFILE="http://xml.ra.se/e-arkiv/METS/CommonSpecificationSwedenPackageProfile.xml"
           ext:ACCESSRESTRICT="Secrecy and PuL"
           ext:AGREEMENTFORM="AGREEMENT"
           ext:APPRAISAL="No"
           ext:ARCHIVALNAME="$Arkivbildare"
           ext:PACKAGENUMBER="1"
           ext:SYSTEMTYPE="Ärendehanteringssystem">
  <mets:metsHdr CREATEDATE="$DateTimeExtended"
                RECORDSTATUS="NEW"
                ext:OAISSTATUS="SIP">
    <mets:agent ROLE="CREATOR"
                TYPE="INDIVIDUAL">
      <mets:name>Arvid Eriksson</mets:name>
      <mets:note>arvid.eriksson@norrtalje.se</mets:note>
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
      <mets:name>$Arkivbildare</mets:name>
      <mets:note>Local:$kod</mets:note>
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

$XMLSIPdokument | Out-File .\Documents\Arkivexport\Paket\Leveranspaket\sip.xml -Encoding utf8
$Paketnamn =  $Namnd + "DiabasProtokoll" + $DateYYYYMMDD
Compress-Archive -Path .\Documents\Arkivexport\Paket\Leveranspaket\* -DestinationPath ".\Documents\Script\$Paketnamn" -CompressionLevel Optimal -Force
##Remove-Item -Path .\Documents\Arkivexport\ -Recurse
