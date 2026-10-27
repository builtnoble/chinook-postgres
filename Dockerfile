FROM postgres:16.15-alpine3.24

# The official entrypoint defaults POSTGRES_DB to POSTGRES_USER; default it to "chinook" instead.
ENV POSTGRES_DB=chinook

# Runs once, on first start of an empty data directory.
COPY init.sql /docker-entrypoint-initdb.d/
