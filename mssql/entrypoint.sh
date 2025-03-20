#!/bin/bash

# Start the script to create the DB and user
/scripts/import-data.sh &

# Start SQL Server
/opt/mssql/bin/sqlservr