#!/usr/bin/env bash
# IOX migration test harness.
#
# What it does:
#   1. Spins up a disposable Postgres container (port-mapped only, no volume).
#   2. Applies every migration in version order.
#   3. Loads seed data.
#   4. Verifies counts against the documented schema baseline.
#   5. Tears the container down (always, even on failure).
#
# Intended for: CI, pre-merge checks, post-migration-change sanity.
# NOT intended for: ongoing dev DB — use `docker compose up -d` for that.
#
# Requires: docker, psql (host or via the container).
#
# Exit codes:
#   0 — all checks passed
#   1 — a check failed
#   2 — environment is missing a prerequisite

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MIG_DIR="$REPO_ROOT/schema/migrations"
SEED_FILE="$REPO_ROOT/schema/seed/seed_data.sql"

CONTAINER="iox-migtest-$$"
PORT="${IOX_MIGTEST_PORT:-55432}"
PG_IMAGE="${IOX_PG_IMAGE:-postgres:18}"

# Expected counts. Update when the schema legitimately changes — these are the
# canonical "what does v1.13 look like" numbers.
EXPECTED_TABLES=84
EXPECTED_VIEWS=6
EXPECTED_FKS_MIN=120     # Loose lower bound — actual is ~139, the doc-quoted "~95" is stale.

red()    { printf '\033[31m%s\033[0m\n' "$*"; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
log()    { printf '[migration-test] %s\n' "$*"; }

require() {
  command -v "$1" >/dev/null 2>&1 || { red "Missing prerequisite: $1"; exit 2; }
}

cleanup() {
  local rc=$?
  if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    log "removing container ${CONTAINER}"
    docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true
  fi
  exit $rc
}
trap cleanup EXIT

require docker
require psql

log "starting ephemeral Postgres on :${PORT} (${PG_IMAGE})"
docker run -d --rm \
  --name "${CONTAINER}" \
  -e POSTGRES_DB=iox_test \
  -e POSTGRES_USER=iox \
  -e POSTGRES_PASSWORD=iox \
  -p "${PORT}:5432" \
  "${PG_IMAGE}" >/dev/null

# Wait for readiness — short poll, no leading sleep.
for i in $(seq 1 30); do
  if docker exec "${CONTAINER}" pg_isready -U iox -d iox_test >/dev/null 2>&1; then
    break
  fi
  sleep 1
  if [[ $i -eq 30 ]]; then
    red "Postgres failed to become ready in 30s"
    docker logs "${CONTAINER}" | tail -50
    exit 1
  fi
done

export PGPASSWORD=iox
PSQL=(psql -h localhost -p "${PORT}" -U iox -d iox_test -v ON_ERROR_STOP=1 -X)

# Apply migrations in strict version order.
MIGRATIONS=(
  "iox-core/V1.0__iox_core_project_contract.sql"
  "iox-core/V1.1__iox_core_identity_access.sql"
  "iox-core/V1.2__iox_core_organisation_project.sql"
  "iox-core/V1.3_to_V1.11__iox_core_remaining_segments.sql"
  "iox-core/V1.12__iox_core_extensions_and_foreign_keys.sql"
  "iox-core/V1.13__iox_core_schema_completion.sql"
  "iox-core/V1.14__iox_core_password_hash_and_qa_fk.sql"
  "parametrix/V0.1_to_V0.6__parametrix_parametric_estimation.sql"
)

for m in "${MIGRATIONS[@]}"; do
  log "applying ${m}"
  "${PSQL[@]}" -f "${MIG_DIR}/${m}" >/dev/null
done

log "loading seed data"
"${PSQL[@]}" -f "${SEED_FILE}" >/dev/null || {
  red "seed_data.sql failed"
  exit 1
}

# Verification queries.
count() {
  "${PSQL[@]}" -At -c "$1"
}

TABLES=$(count "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';")
VIEWS=$(count  "SELECT COUNT(*) FROM information_schema.views  WHERE table_schema='public';")
FKS=$(count    "SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_type='FOREIGN KEY' AND constraint_schema='public';")
USERS=$(count  "SELECT COUNT(*) FROM \"User\";")
PROJ=$(count   "SELECT COUNT(*) FROM \"Project\";")

fail=0
check() {
  local label="$1" actual="$2" expected="$3" op="${4:-eq}"
  case "$op" in
    eq) if [[ "$actual" == "$expected" ]]; then green "  ✓ $label = $actual"; else red "  ✗ $label = $actual (expected $expected)"; fail=1; fi ;;
    ge) if [[ "$actual" -ge "$expected" ]]; then green "  ✓ $label = $actual (≥ $expected)"; else red "  ✗ $label = $actual (expected ≥ $expected)"; fail=1; fi ;;
    gt) if [[ "$actual" -gt "$expected" ]]; then green "  ✓ $label = $actual (> $expected)"; else red "  ✗ $label = $actual (expected > $expected)"; fail=1; fi ;;
  esac
}

log "verification"
check "base tables"    "$TABLES" "$EXPECTED_TABLES"
check "views"          "$VIEWS"  "$EXPECTED_VIEWS"
check "foreign keys"   "$FKS"    "$EXPECTED_FKS_MIN" ge
check "seeded users"   "$USERS"  0 gt
check "seeded projects" "$PROJ"  0 gt

# Spot-check a materialized-style view is queryable.
if "${PSQL[@]}" -c 'SELECT 1 FROM "ProjectSummary" LIMIT 1;' >/dev/null 2>&1; then
  green "  ✓ ProjectSummary view queryable"
else
  red "  ✗ ProjectSummary view not queryable"
  fail=1
fi

if [[ $fail -ne 0 ]]; then
  red "migration-test: FAILED"
  exit 1
fi
green "migration-test: PASSED"
