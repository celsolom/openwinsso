while (1) {
    $groups = Import-Csv $csv_path
    
    #limpa tabela de update
    $sql = "DELETE FROM users_groups_update;`n"
    
        
    foreach ( $group in $groups) {
        $groupname = $group.GRUPOAD
        #$group
        #insere grupo na tabela GROUPS
        #.\pgsql\bin\psql.exe -d adsso -c "INSERT INTO groups values ('$groupname') on conflict (groupname) do nothing;"
        $sql = $sql + "INSERT INTO groups values ('$groupname') ON CONFLICT (groupname) DO NOTHING;`n"
        
        #Busca membros do grupo
        $members = Get-ADGroupMember -Identity $(Get-ADGroup -LDAPFilter "(name=$groupname)") -Recursive | Select -ExpandProperty samaccountname
    
        #Adiciona membros a tabela users_groups_update
        foreach ( $member in $members ) {
            #$member
            $login = $member.ToLower()
            #.\pgsql\bin\psql.exe -d adsso -c "insert INTO users_groups_update values ('$login','$groupname') on conflict (login, groupname) do nothing;"
            $sql = $sql + "INSERT INTO users_groups_update VALUES ('$login','$groupname') ON CONFLICT (login, groupname) DO NOTHING;`n"
        }
    }
            
    #insere usuários novos
    #.\pgsql\bin\psql.exe -d adsso -c "insert into users_groups select * from users_groups_update except select * from users_groups on conflict (login, groupname) do nothing"
    $sql = $sql + "INSERT INTO users_groups SELECT * FROM users_groups_update EXCEPT SELECT * FROM users_groups ON CONFLICT (login, groupname) DO NOTHING;`n"

    #remove usuários deletados
    #.\pgsql\bin\psql.exe -d adsso -c "delete from users_groups where exists (select * from users_groups except select * from users_groups_update);"    
    $sql = $sql + "DELETE FROM users_groups WHERE EXISTS (SELECT * FROM users_groups EXCEPT SELECT * FROM users_groups_update);"

    New-Item temp.sql -ItemType "file" -Value $sql
    .\pgsql\bin\psql.exe -d adsso -f temp.sql -q
    del temp.sql
sleep 300
}
