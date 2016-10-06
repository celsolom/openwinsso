$rede = '0.0.0.0/0'
$final = Get-Date
while (1) {
    $nome =""
    $ip = ""
    $tag = 0
    $inicio = $final - $(New-TimeSpan -Seconds 2)
    # Recupera os eventos de login
    $events = Get-WinEvent -computer $ldapserver -FilterHashtable @{"ProviderName"="Microsoft-Windows-Security-Auditing";Id=4624; StartTime=$inicio; EndTime=$(Get-Date)} -ErrorAction SilentlyContinue | %{([xml]$_.ToXml()).Event.EventData.Data}

    $final = Get-Date

    "Linhas: " + $events.count
    "Inicio: " + $inicio
    "Final: " + $final

    foreach ( $event in $events) {
        #"Evento: " + $event
        if ( $event.Name -eq "TargetUserName" -and $event.InnerText.ToCharArray() -notcontains '$'){
            $tag = 1
            $nome = $event.InnerText
            $nome = $nome.ToLower()
            $nome = $nome.trim()
        }

        if ($event.Name -eq "IpAddress" -and $event.InnerText.Length -ge 7 -and $tag -eq 1 ){
            $ip = $event.InnerText
            $ip = $ip.trim()
            $tag = 0
        }
        #"Nome: " + $nome.Length + " IP: " + $ip.Length  + " TAG: " + $tag
        if ( $nome.Length -gt 0 -and $ip.Length -gt 0 -and $tag -eq 0 ) {
            #"Nome: " + $nome + " IP: " + $ip
            $sql = "COPY (select count(*) from users_logged where login = '$nome' and ip = '$ip') TO STDOUT (FORMAT CSV, HEADER, DELIMITER ',', FORCE_QUOTE * ) ;"
            $logged = .\pgsql\bin\psql.exe -d adsso -c "$sql"
            $logged = convertfrom-csv -InputObject $logged
            if ($logged.count -eq 0) {
                    
                $sql = "COPY (select (inet '$ip' << inet '$rede') as answer) TO STDOUT (FORMAT CSV, HEADER, DELIMITER ',', FORCE_QUOTE * ) ;"
                $testip = .\pgsql\bin\psql.exe -d adsso -c "$sql"
                $testip = convertfrom-csv -InputObject $testip

                $sql = "COPY (select count (*) from users where login = '$nome') TO STDOUT (FORMAT CSV, HEADER, DELIMITER ',', FORCE_QUOTE * ) ;"
                $testnome = .\pgsql\bin\psql.exe -d adsso -c "$sql"
                $testnome = convertfrom-csv -InputObject $testnome
                    
                if($testip.answer -eq 't' -and $testnome.count -eq 1){
                    $sql = "COPY (select count(*) from users_valid where login = '$nome' and ip = '$ip') TO STDOUT (FORMAT CSV, HEADER, DELIMITER ',', FORCE_QUOTE * ) ;"
                    $testvalid = .\pgsql\bin\psql.exe -d adsso -c "$sql"
                    $testvalid = convertfrom-csv -InputObject $testvalid
                    if($testvalid.count -eq 0){
                        "Nome: " + $nome + " IP: " + $ip
                        Invoke-Command {.\check_user.ps1 -Ip $ip -User $nome}
                        #$job = Start-Job -ScriptBlock {.\check_user.ps1 -Ip $ip -User $nome}
                        #Wait-Job $job.Id -Timeout 4
                    }
                }
            }
            $nome = ""
            $ip = ""
        }
    }
 }
