# at least postgres is available for arm64 arch out of the box
FROM postgres:16

WORKDIR /scripts

COPY *.sql .

WORKDIR /docker-entrypoint-initdb.d

COPY pg_north_ddl_data.sql .

COPY pg_other.sql .
