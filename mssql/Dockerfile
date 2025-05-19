FROM mcr.microsoft.com/mssql/server:2022-latest

WORKDIR /scripts

COPY *.sql .
COPY *.sh .
COPY *.bak .

# IDK why I need to change the user to root to make the scripts executable
USER root
RUN chmod +x *.sh

ENTRYPOINT ["./entrypoint.sh"]