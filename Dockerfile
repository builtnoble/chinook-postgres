FROM postgres:16.15-alpine3.24

LABEL org.opencontainers.image.title="chinook-postgres" \
      org.opencontainers.image.description="PostgreSQL 16 with the Chinook sample database preloaded" \
      org.opencontainers.image.source="https://github.com/builtnoble/chinook-postgres"

# The official entrypoint defaults POSTGRES_DB to POSTGRES_USER; default it to "chinook" instead.
ENV POSTGRES_DB=chinook

# Runs once, on first start of an empty data directory.
COPY init.sql /docker-entrypoint-initdb.d/

# Restores the seed data in place: docker exec <container> chinook-reset
COPY --chmod=755 reset.sh /usr/local/bin/chinook-reset

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
    CMD pg_isready -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB}" || exit 1
