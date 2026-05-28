# Local IOX dev database

A one-command local Postgres with the full IOX schema and seed data applied.

## Prereqs

- Docker Desktop (or any Docker engine that supports compose v2)
- `psql` client (optional — for ad-hoc queries from the host)

## Start

```bash
docker compose up -d
```

First boot:
- Pulls `postgres:18`
- Creates database `iox_dev` with user `iox` / password `iox`
- Runs every migration in version order (V1.0 → V1.13, then ParametriX V0.1–V0.6)
- Loads `seed_data.sql` (Southgate Business Park scenario)

Subsequent boots reuse the `iox-pgdata` volume — migrations are **not** re-applied.

## Connect

```bash
psql -h localhost -p 5432 -U iox -d iox_dev
# password: iox
```

DSN for application code:
```
postgresql://iox:iox@localhost:5432/iox_dev
```

## Verify

```bash
# Expected: 84
psql -h localhost -U iox -d iox_dev -c \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';"

# Expected: 6
psql -h localhost -U iox -d iox_dev -c \
  "SELECT COUNT(*) FROM information_schema.views WHERE table_schema='public';"

# Expected: ~95
psql -h localhost -U iox -d iox_dev -c \
  "SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_type='FOREIGN KEY';"
```

## Reset

If you change a migration and want a clean rebuild:

```bash
docker compose down -v   # -v drops the volume — destroys local data
docker compose up -d
```

## Port conflict

Set `IOX_DB_PORT` to remap the host port:

```bash
IOX_DB_PORT=5433 docker compose up -d
```

## Notes

- This is **not** a Flyway-managed instance. Migrations apply once at first init via the Postgres entrypoint. For ongoing migration testing use `tools/migration-test.sh`.
- The mounted SQL files are read-only — editing in place is safe, but a `docker compose down -v` is required for changes to take effect on next boot.
