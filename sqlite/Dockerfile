FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y sqlite3

WORKDIR /scripts

COPY *.sql .

WORKDIR /data

RUN sqlite3 /data/northwind.db < /scripts/sqlite_north_ddl.sql && \
    sqlite3 /data/northwind.db < /scripts/sqlite_north_data.sql && \
    sqlite3 /data/northwind.db < /scripts/sqlite_other.sql

# Keep the container running
CMD ["tail", "-f", "/dev/null"]