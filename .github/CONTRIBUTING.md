# Contributing

Thanks for your interest in contributing! This repo builds `builtnoble/chinook-postgres`, a PostgreSQL 16
Docker image with the [Chinook sample database](https://github.com/lerocha/chinook-database) preloaded.
It's used as the database for the Chinook API sandbox, so changes here should keep it easy to start,
write to, and reset.

This file takes precedence over the organization-wide default. The
[Code of Conduct](https://github.com/builtnoble/.github/blob/HEAD/CODE_OF_CONDUCT.md) and
[Security Policy](https://github.com/builtnoble/.github/blob/HEAD/SECURITY.md) from the organization's
`.github` repository still apply. Please report vulnerabilities privately as described there, not in a
public issue.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) with Buildx
- Git

No Postgres install is needed; everything runs in containers.

## Getting started

```bash
git clone git@github.com:builtnoble/chinook-postgres.git
cd chinook-postgres
docker build -t chinook-postgres:test .
docker run -d --name chinook-dev -e POSTGRES_PASSWORD=dev -p 5432:5432 chinook-postgres:test
docker exec -it chinook-dev psql -U postgres -d chinook
```

Remove it when you're done: `docker rm -f chinook-dev`.

## How the repo works

| Path | Purpose |
| --- | --- |
| `init.sql` | Schema and seed data. Runs **once**, on the first start of an empty data directory. |
| `reset.sh` | Installed as `chinook-reset`. Drops and re-seeds the Chinook tables from `init.sql`. |
| `Dockerfile` | Pinned Postgres base image, default database name, healthcheck and labels. |
| `tests/` | Image structure tests and a generic smoke test. |
| `.github/workflows/docker-publish.yml` | Test job and publishing. |

Things to keep in mind when changing the database:

- **`init.sql` doesn't re-run on an existing volume.** To test a change, start a new container (or remove
  the volume); don't expect an already running one to pick it up.
- **Seed `INSERT`s must leave out `id`.** Ids are `SERIAL`, and omitting them keeps the sequences in step
  with the data so new rows don't collide with seeded ones.
- **Keep `reset.sh` in step with `init.sql`.** The list of tables it drops is written out by hand. If you
  add, rename or remove a table, update that list.
- **Foreign keys are `ON DELETE NO ACTION` unless the child row has no meaning without its parent**
  (`playlist_tracks`, `invoice_lines`). Explain any new `CASCADE` in your PR.
- The Chinook tables are also described by a Drizzle schema in the `chinook-api` repo. Schema changes
  here usually need a matching change there.
- Changing the Postgres **major** version means existing data volumes can't be reused without a
  dump/restore. Call that out in your PR.

## Running the checks locally

CI runs these on every pull request. The tool versions are pinned in the `env:` block of the workflow;
use the same ones.

```bash
# Build
docker build -t chinook-postgres:test .

# Lint the Dockerfile
docker run --rm -i hadolint/hadolint:v2.15.1 < Dockerfile

# Image metadata, files and installed tools
container-structure-test test --image chinook-postgres:test --config tests/container-structure-test.yaml

# Starts the image and waits for it to become healthy
tests/smoke-test.sh chinook-postgres:test -e POSTGRES_PASSWORD=test

# Vulnerability scan of OS packages (this one blocks publishing)
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:0.76.1 \
  image --pkg-types os --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 chinook-postgres:test
```

[container-structure-test](https://github.com/GoogleContainerTools/container-structure-test) needs to be
installed separately.

Trivy only blocks on fixable HIGH/CRITICAL findings in OS packages. Findings in binaries bundled by the
upstream `postgres` image (for example `gosu`) are reported in CI but don't block, because a change in
this repo can't fix them.

When you change behavior, add or update a test in `tests/` for it.

## Commits and branches

- Use [Conventional Commits](https://www.conventionalcommits.org/): `type: subject`. Types used here are
  `feat`, `fix`, `refactor`, `chore`, `docs`, `test` and `ci`.
- Keep commits atomic: one logical change per commit.
- Name branches `type/short-description`, for example `fix/healthcheck-user`.

## Pull requests

1. Branch from `main` and open a PR against `main`.
2. CI runs the checks above, then builds the image for amd64 and arm64 **without pushing it**.
3. All checks must pass before merging.

## Publishing and releases

Contributors don't publish anything. Maintainers do, via git tags:

| Event | Tags published to Docker Hub |
| --- | --- |
| Pull request | none (build only) |
| Push to `main` | `edge` |
| Stable tag `vX.Y.Z` | `X.Y.Z`, `X.Y`, `X`, `latest` |
| Pre-release tag, e.g. `vX.Y.Z-rc1` | `X.Y.Z-rc1` only |

Published version tags are never moved or deleted; a bad release is fixed with a new patch version.
