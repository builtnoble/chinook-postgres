#!/bin/sh
# Restore the Chinook tables to their original seed data without recreating the volume.
# Usage: docker exec <container> chinook-reset
#
# Drops and recreates only the Chinook tables, in a single transaction, so a failure
# leaves the existing data untouched. Tables owned by other tools (e.g. Better Auth's
# users/sessions) are not touched, so logins survive a reset.
set -e

SEED=/docker-entrypoint-initdb.d/init.sql

{
    echo "DROP TABLE IF EXISTS"
    echo "    playlist_tracks, invoice_lines, invoices, customers, employees,"
    echo "    tracks, albums, artists, genres, media_types, playlists"
    echo "CASCADE;"
    cat "$SEED"
} | psql -q -v ON_ERROR_STOP=1 --single-transaction \
    -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-chinook}"

echo "Chinook data reset to seed state."
