#Skrivet för PowerShell 7.2
#Script för att skapa ett paket med två lönelistor, en lilla och en stora. YYYY-MM-DD_lonelistor_månad_lilla/stora.docx
#Innan bör de konverteras till docx och namnsättas enligt ovan.
#De bör även ligga i C:\users\97arer14\documents\script\leveransfiler\, samt vara de enda filerna i mappen
Set-Location "C:\Users\97arer14"
#Nya temporära mappar för baspaketstruktur
New-Item -Path .\Documents\Script\ -Name leveranspaket -ItemType Directory
New-Item -Path .\Documents\Script\leveranspaket\ -Name "content" -ItemType Directory
New-Item -Path .\Documents\Script\leveranspaket\content -Name "1" -ItemType Directory

#Variabler
$OBJIDGUIDObject=New-Guid
$OBJIDGUID=$OBJIDGUIDObject.Guid
$DateTimeExtended = Get-Date -Format yyyy-MM-ddTHH:mm:ss
$DateYYYYMMDD = Get-Date -Format yyyy-MM-dd

$actualfiles=get-childitem .\Documents\Script\leveransfiler\
foreach($afile in $actualfiles){
#Variabler relaterat till filer
$filename=$afile.Name
$fileGUIDObject = New-Guid
$fileGUID = $fileGUIDObject.Guid
$fileLastWriteTimeDate = $afile | Select-Object -ExpandProperty LastWriteTime | Get-Date -Format yyyy-MM-ddTHH:mm:ss
$fileSize = $afile.length
$fileExtUse = $afile.Extension.trim(".","1")
$fileChecksumSHA256Object = $afile | Get-FileHash -Algorithm SHA256
$fileChecksumSHA256 = $fileChecksumSHA256Object.Hash

#Variabler för mets startdate enddate samt för paketnummer (bara vilken månad utifrån filnamnet)
$delatnamndash = $filename.Split("-")
$DateYear = $delatnamndash[0]
$DateMonth = $delatnamndash[1]
$delatnamnuscore=$filename.Split("_")
$monthText = $delatnamnuscore[2]
if($filename -like "*lilla*"){
$DateLilla = $delatnamnuscore[0]
}
elseif ($filename -like "*stora*"){
$DateStora = $delatnamnuscore[0]
}
else{
Read-Host -Prompt "fel på filnamnen hittar ej stora/lilla"
}
#en per fil
#KOLLA MIMETYPE OCH USE
#
#KOLLA MIMETYPE
$metsfilexml=@"
<mets:file ID="ID$fileGUID" USE="$fileExtUse" MIMETYPE="application/vnd.openxmlformats-officedocument.wordprocessingml.document" SIZE="$fileSize" CREATED="$fileLastWriteTimeDate" CHECKSUM="$fileChecksumSHA256" CHECKSUMTYPE="SHA-256" ext:ORIGINALFILENAME="$filename" ext:ARCHIVALRECORDTYPE="Lönelista">
    <mets:FLocat LOCTYPE="URL" xlink:type="simple" xlink:href="file:///content/1/$filename"/>
</mets:file>
"@
Copy-Item $afile.FullName -Destination .\Documents\Script\leveranspaket\content\1
$metsfilexml | Out-File .\Documents\Script\metsfiles.xml -Encoding utf8NoBOM -Append
}


$metsfilesxmloutput=Get-ChildItem -Path .\Documents\Script\metsfiles.xml
$metsfiles = Get-Content $metsfilesxmloutput -Encoding utf8NoBOM -Raw
remove-item $metsfilesxmloutput

#"komplett" XML-dokument
$XMLSIPdokument=@"
<?xml version="1.0" encoding="UTF-8"?>
<mets:mets xmlns:mets="http://www.loc.gov/METS/"
           xmlns:xlink="http://www.w3.org/1999/xlink"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xmlns:ext="ExtensionMETS"
           OBJID="GUID:$OBJIDGUID"
           LABEL="Leverans av lönelistor $monthText $DateYear. Stor körning $DateStora och liten körning $DateLilla. Konverteras till PDF/A-1a."
           TYPE="No specification"
           PROFILE="http://xml.ra.se/e-arkiv/METS/CommonSpecificationSwedenPackageProfile.xml"
           ext:ACCESSRESTRICT="Secrecy and PuL"
           ext:AGREEMENTFORM="AGREEMENT"
           ext:APPRAISAL="No"
           ext:ARCHIVALNAME="Kommunstyrelsen"
           ext:ENDDATE="$DateLilla"
           ext:PACKAGENUMBER="$DateMonth"
           ext:STARTDATE="$DateStora"
           ext:SYSTEMTYPE="Lönesystem">
  <mets:metsHdr CREATEDATE="$DateTimeExtended"
                RECORDSTATUS="NEW"
                ext:OAISSTATUS="SIP">
    <mets:agent ROLE="CREATOR"
                TYPE="INDIVIDUAL">
      <mets:name>Arvid Eriksson</mets:name>
    </mets:agent>
    <mets:agent ROLE="CREATOR"
                TYPE="ORGANIZATION">
      <mets:name>Kommunstyrelsekontorets löneenhet</mets:name>
    </mets:agent>
    <mets:agent ROLE="EDITOR"
                TYPE="ORGANIZATION">
      <mets:name/>
    </mets:agent>
    <mets:agent ROLE="ARCHIVIST"
                TYPE="ORGANIZATION">
      <mets:name>KOMMUNSTYRELSEN</mets:name>
      <mets:note>Local:10002</mets:note>
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
      <mets:name>Löneenheten</mets:name>
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
      <mets:name>eCompanion</mets:name>
    </mets:agent>
    <mets:altRecordID TYPE="SUBMISSIONAGREEMENT">$DateYYYYMMDD</mets:altRecordID>
    <mets:altRecordID TYPE="REFERENCECODE">2.3.13</mets:altRecordID>
    <mets:altRecordID TYPE="PREVIOUSREFERENCECODE">G:2</mets:altRecordID>
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

$XMLSIPdokument | Out-File .\Documents\Script\leveranspaket\sip.xml -Encoding utf8

$Datekombinerat = $DateStora + "_" + $DateLilla
Compress-Archive -Path .\Documents\Script\leveranspaket\* -DestinationPath ".\Documents\Script\NK_Lonelistor_$Datekombinerat" -CompressionLevel Optimal
Remove-Item -Path .\Documents\Script\leveranspaket\ -Recurse