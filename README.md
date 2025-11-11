# Chinook Postgres

A Docker image for PostgreSQL with the Chinook sample database pre-configured.

## Features

- Based on PostgreSQL 16 Alpine
- Normalized Chinook database schema and sample data included
- Configurable database name via environment variable

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

## License

This project is provided as-is for educational and development purposes.
