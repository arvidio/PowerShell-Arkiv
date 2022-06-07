# Detta har inte kommit så långt, men EAC-AB008_20211029_11-03-02.xml är export från Visual till EAC.
# Finns säkert användning för principen när det kommer till jobb med XML, men som sagt tror jag inte att något händer i detta script för tillfället.

#Hämta xml...
$EAC=[XML](Get-Content .\Desktop\EAC_AB008_20220406_09-02-15.xml -encoding ISO-8859-1)
$EAD=[XML](Get-Content .\Desktop\EAD_AB008_20220406_09-02-12.xml -encoding ISO-8859-1)
$arkivbildareEAC = $EAC.eacgrp.condescgrp.eac
$arkivbildareEAD = $EAD.eadgrp.archdescgrp.ead




$sok = Read-Host "Vilket arkiv vill du hitta?"
foreach ($arkiv in $arkivbildareEAC){
    $arkivbildareNamn = $arkiv.condesc.identity.corphead.part
    if($arkivbildareNamn -like "*$sok*"){
        if ($arkivbildareNamn -is [array]){
            $i=1
            foreach($occur in $arkivbildareNamn){
                "Namn $i"
                $occur
                $i++
            }
        }
        else{
            "Namn:"
            $arkivbildareNamn}
    }
}

#Kontrollera verksamhetsår
foreach ($arkiv in $arkivbildareEAD){
    $verksamhetsTid=$arkiv.archdesc.did.unitdate.'#text'
    if($verksamhetsTid -match '^\d\d\d\d -- \d\d\d\d$'){
        $splitVerksamhetsTid=$verksamhetsTid.Split(" -- ")
        $senasteVerksamhetsTid=$splitVerksamhetsTid[1]
        $senasteVerksamhetsTidInt = $senasteVerksamhetsTid.ToInt32($null)
        $serieid=$arkiv.archdesc.c.did.unitid
        $serienamn = $arkiv.archdesc.c.did.unittitle
        $volym=$arkiv.archdesc.dsc.c.c
        foreach ($n in $volym){
            $volymTid=$n.did.unitdate
            $volymId=$n.did.unitid
            if ($volymTid -match '^\d\d\d\d -- \d\d\d\d$'){
            $splitVolymTid = $volymTid.Split(" -- ")
            $senasteVolymTid = $splitVolymTid[1]
            $sensateVolymTidInt=$senasteVolymTid.ToInt32($null)
            if ($sensateVolymTidInt -gt $senasteVerksamhetsTidInt){
                "Volym $volymId i $serieid $serienamn har diskrepans"
                $n.ParentNode.ParentNode.ParentNode.ParentNode.archdesc.did.unittitle
                "senaste verksamhetsår"
                $senasteVerksamhetsTidInt
                "senaste volym"
                $sensateVolymTidInt
                }
            }
            elseif ($volymTid -match '^\d{4}$'){
                $sensateVolymTidInt= $VolymTid.ToInt32($null)
                if ($sensateVolymTidInt -gt $senasteVerksamhetsTidInt){
                "Volym $volymId i $serieid $serienamn har diskrepans"
                $n.ParentNode.ParentNode.ParentNode.ParentNode.archdesc.did.unittitle
                "senaste verksamhetsår"
                $senasteVerksamhetsTidInt
                "senaste volym"
                $sensateVolymTidInt
                }
            }
            else{
                $felformat = $n.ParentNode.ParentNode.ParentNode.ParentNode.archdesc.did.unittitle
                $felformat | out-file C:\Users\97arer14\Desktop\txt.txt -Append
            }
        }
    }
    else{}
}

foreach ($arkiv in $arkivbildareEAD){
    $verksamhetsTid=$arkiv.archdesc.did.unitdate.'#text'
    if($verksamhetsTid -match '^\d\d\d\d -- \d\d\d\d$'){
        $splitVerksamhetsTid=$verksamhetsTid.Split(" -- ")
        $senasteVerksamhetsTid=$splitVerksamhetsTid[1]
        $senasteVerksamhetsTidInt = $senasteVerksamhetsTid.ToInt32($null)
        $serieid=$arkiv.archdesc.c.did.unitid
        $serienamn = $arkiv.archdesc.c.did.unittitle
        $serier = $arkiv.archdesc.c
        #$volym=$arkiv.archdesc.dsc.c.c
        foreach ($serie in $serier){
            $volymer = $serie.c
            $serieid= $serie.did.unitid
            $serienamn = $serie.did.unittitle
            foreach($volym in $volymer){
            $volymTid=$volym.did.unitdate
            $volymId=$volym.did.unitid
            if ($volymTid -match '^\d\d\d\d -- \d\d\d\d$'){
            $splitVolymTid = $volymTid.Split(" -- ")
            $senasteVolymTid = $splitVolymTid[1]
            $sensateVolymTidInt=$senasteVolymTid.ToInt32($null)
            if ($sensateVolymTidInt -gt $senasteVerksamhetsTidInt){
                "Volym $volymId i $serieid $serienamn har diskrepans"
                $volym.ParentNode.ParentNode.ParentNode.ParentNode.archdesc.did.unittitle
                "senaste verksamhetsår"
                $senasteVerksamhetsTidInt
                "senaste volym"
                $sensateVolymTidInt
                }
            }
            elseif ($volymTid -match '^\d{4}$'){
                $sensateVolymTidInt= $VolymTid.ToInt32($null)
                if ($sensateVolymTidInt -gt $senasteVerksamhetsTidInt){
                "Volym $volymId i $serieid $serienamn har diskrepans"
                $volym.ParentNode.ParentNode.ParentNode.ParentNode.archdesc.did.unittitle
                "senaste verksamhetsår"
                $senasteVerksamhetsTidInt
                "senaste volym"
                $sensateVolymTidInt
                }
            }
            else{
                $felformat = $n.ParentNode.ParentNode.ParentNode.ParentNode.archdesc.did.unittitle
                $felformat | out-file C:\Users\97arer14\Desktop\txt.txt -Append
            }
        }
    }
}
    else{}
}
