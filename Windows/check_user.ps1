param ([string]$User,[string]$Ip)
    $luser = $(.\PsExec.exe \\$Ip qwinsta).ToLower()
    if ($luser.Length -gt 0){
        foreach ( $line in $luser ){if ($line.contains($User) -eq 1){$luser = 1}}
        if($luser -eq 1){      
            $nome + " logado."  
            .\pgsql\bin\psql.exe -d adsso -c "INSERT INTO users_logged values ('$nome','$ip',now()) on conflict (login,ip) do update set date = now();" -q
        } else {
            $nome + " não logado."
            .\pgsql\bin\psql.exe -d adsso -c "DELETE FROM users_logged WHERE login = '$nome' and ip = '$ip';" -q
        }
    }
#}
