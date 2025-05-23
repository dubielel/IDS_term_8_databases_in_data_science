#!/bin/bash

# Wait 60 seconds for SQL Server to start up by ensuring that 
# calling SQLCMD does not return an error code, which will ensure that sqlcmd is accessible
# and that system and user databases return "0" which means all databases are in an "online" state
# https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-databases-transact-sql?view=sql-server-2017 

DBSTATUS=1
ERRCODE=1
i=0

while [[ $DBSTATUS -ne 0 ]] && [[ $i -lt 60 ]] && [[ $ERRCODE -ne 0 ]]; do
    i=$i+1
    DBSTATUS=$(/opt/mssql-tools18/bin/sqlcmd -h -1 -t 1 -U sa -P $SA_PASSWORD -C -Q "SET NOCOUNT ON; Select SUM(state) from sys.databases")
    ERRCODE=$?
    sleep 1
done

if [ $DBSTATUS -ne 0 ] OR [ $ERRCODE -ne 0 ]; then 
    echo "SQL Server took more than 60 seconds to start up or one or more databases are not in an ONLINE state"
    exit 1
fi

echo "SQL server is ready!"

/opt/mssql-tools18/bin/sqlcmd  -S localhost -U sa -P $SA_PASSWORD -C -Q "CREATE DATABASE northwind"
/opt/mssql-tools18/bin/sqlcmd  -S localhost -U sa -P $SA_PASSWORD -C -d northwind -i /scripts/ms_north_ddl.sql
/opt/mssql-tools18/bin/sqlcmd  -S localhost -U sa -P $SA_PASSWORD -C -d northwind -i /scripts/ms_north_data.sql
/opt/mssql-tools18/bin/sqlcmd  -S localhost -U sa -P $SA_PASSWORD -C -d northwind -i /scripts/ms_other.sql

echo "Data has been imported successfully!"