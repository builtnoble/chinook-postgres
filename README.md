# Chinook Postgres

A Docker image for PostgreSQL with the Chinook sample database pre-configured.

## Features

- Based on PostgreSQL 16 Alpine
- Normalized Chinook database schema and sample data included
- Configurable database name via environment variable
- Writable: auto-generated ids with sequences synced to the seed data
- One-command reset back to the seed data
- Built-in healthcheck (`pg_isready`)

## Quick Start

### Pull and run the container

```bash
docker run -d \
  --name chinook-db \
  -e POSTGRES_DB=chinook \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=yourpassword \
  -p 5432:5432 \
  builtnoble/chinook-postgres:latest
```

### Custom database name

To specify a custom database name, set the `POSTGRES_DB` environment variable:

```bash
docker run -d \
  --name chinook-db \
  -e POSTGRES_DB=my_custom_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=yourpassword \
  -p 5432:5432 \
  builtnoble/chinook-postgres:latest
```

### Connect to the database

```bash
docker exec -it chinook-db psql -U postgres -d chinook
```

Or use any PostgreSQL client:

- **Host:** localhost
- **Port:** 5432
- **Database:** chinook (or your custom name)
- **Username:** postgres
- **Password:** yourpassword

## Building Locally

```bash
docker build -t chinook-postgres .
```

## Environment Variables

| Variable            | Description                    | Default    |
| ------------------- | ------------------------------ | ---------- |
| `POSTGRES_DB`       | Name of the database to create | `chinook`  |
| `POSTGRES_USER`     | PostgreSQL superuser name      | `postgres` |
| `POSTGRES_PASSWORD` | PostgreSQL superuser password  | (required) |

## Database Schema

The Chinook database includes tables for:

- Artists
- Albums
- Tracks
- And more...

See `init.sql` for the complete schema and sample data.

### Writing data and deletes

Every table has an auto-generated `id` (`SERIAL`), except `playlist_tracks`, whose key is
`(playlist_id, track_id)`. The sequences start after the seeded rows, so inserts need no explicit id.

Foreign keys are `ON DELETE NO ACTION` (deletes fail while child rows exist), except for child rows
that have no meaning without their parent, which cascade:

| Deleting...  | Also deletes...                         |
| ------------ | --------------------------------------- |
| a playlist   | its `playlist_tracks` rows              |
| a track      | its `playlist_tracks` rows              |
| an invoice   | its `invoice_lines` rows                |

Deleting an artist that still has albums, an album that still has tracks, or a track that appears on an
invoice line fails with a foreign key error.

#### Soft-deleting tracks

`tracks` has one column that is not in upstream Chinook: `deleted_at TIMESTAMP`, `NULL` in the seed. Set it to
mark a track as deleted without removing the row, so invoice lines that refer to the track stay valid. Nothing in the
database reads it; whatever queries the tracks decides whether to leave deleted ones out. A volume created from an
earlier image does not have the column (`init.sql` only runs on an empty volume), and `chinook-reset` adds it.

## Resetting the data

Data written to the database persists for as long as the data volume does. To get back to the seed data
there are two options.

**Reset in place** (keeps the container and volume; leaves any non-Chinook tables, such as auth tables,
alone):

```bash
docker exec chinook-db chinook-reset
```

**Recreate the volume** (wipes everything and re-runs `init.sql` on next start). Mount a named volume
so the data survives container restarts, and remove it to start over:

```bash
docker run -d --name chinook-db -v chinook-data:/var/lib/postgresql/data ... builtnoble/chinook-postgres:latest
docker rm -f chinook-db && docker volume rm chinook-data
```

With Docker Compose, declare a named volume on the `db` service and use `docker compose down -v`.

## License

The code in this repository (Dockerfile, scripts, tests and workflows) is released under the
[MIT License](LICENSE).

The schema and sample data in `init.sql` are derived from the
[Chinook database](https://github.com/lerocha/chinook-database) by Luis Rocha, also MIT-licensed; its
notice is reproduced in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). The image is built on the
official `postgres` image, whose software remains under its own licenses.

Both license files are included in the image at `/usr/share/licenses/chinook-postgres/`.
