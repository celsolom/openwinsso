while(1){
    $psql = ".\pgsql\bin\psql.exe -d adsso -c "
    $sql = "COPY (select login,ip from users_expired) TO STDOUT (FORMAT CSV, HEADER, DELIMITER ',', FORCE_QUOTE * ) ;"
    $logged = .\pgsql\bin\psql.exe -d adsso -c "$sql"
    $logged = convertfrom-csv -InputObject $logged
    #$logged | Out-GridView

    foreach ( $user in $logged) {
        $ip = $user.ip
        $nome = $user.login
            "Nome: " + $nome + " IP: " + $ip
            Invoke-Command {.\check_user.ps1 -Ip $ip -User $nome}
            #$job = Start-Job -ScriptBlock {.\check_user.ps1 -Ip $ip -User $nome}
            #Wait-Job $job.Id -Timeout 4
            #.\check_user.ps1 -Ip $ip -User $nome
    }
    sleep 1
}
