/opt/mssql-tools18/bin/sqlcmd \
    -S localhost \
    -U sa \
    -P $SA_PASSWORD \
    -C \
    -Q "RESTORE DATABASE AdventureWorks2017 FROM DISK = '/scripts/AdventureWorks2017.bak' 
        WITH MOVE 'AdventureWorks2017' TO '/var/opt/mssql/data/AdventureWorks2017.mdf', 
        MOVE 'AdventureWorks2017_log' TO '/var/opt/mssql/data/AdventureWorks2017_log.ldf', 
        REPLACE, RECOVERY"