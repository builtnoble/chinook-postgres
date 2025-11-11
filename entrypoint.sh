#!/bin/bash
set -e

# Set default database name if not provided
export POSTGRES_DB=${POSTGRES_DB:-chinook}

echo "Initializing PostgreSQL with database: $POSTGRES_DB"

# Call the original postgres entrypoint
exec docker-entrypoint.sh "$@"
