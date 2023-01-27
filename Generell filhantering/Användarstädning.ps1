$CSV = import-csv .\Downloads\GDPR.csv -Delimiter ";" -Encoding utf8NoBOM

foreach($user in $CSV){
    $Name= $user.Name
    $LastName = $user.LastName
    $Email = $user.Email
    $mob = $user.MobilePhoneNumber
    $TeamsMember = $user.TeamsMember
    if($TeamsMember -eq "#Nortälje kommun #Kommunstyrelsen                                   "){
        $TeamsMember = "#Norrtälje kommun#Kommunstyrelsen#Kommunstyrelsekontoret"
    }
}