#!/bin/bash
set -e

# Azure PostgreSQL Migration Script (Entra ID Compatible)
# Applies IOX Core + ParametriX migrations in correct FK dependency order
#
# Usage (Entra ID):
#   bash scripts/apply_migrations.sh
#   (Will prompt for: Host, Username, Database)
#
# OR with environment variables:
#   export PG_HOST="your-server.postgres.database.azure.com"
#   export PG_USER="your-email@company.com"
#   export PG_DB="iox_dev"
#   bash scripts/apply_migrations.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "IOX PostgreSQL Migration Script"
echo "=========================================="
echo ""

# Get connection details from env vars or prompt
if [[ -z "$PG_HOST" ]]; then
  read -p "PostgreSQL Server (e.g., iox-datamodel.postgres.database.azure.com): " PG_HOST
fi

if [[ -z "$PG_USER" ]]; then
  read -p "Username (e.g., your-email@company.com): " PG_USER
fi

if [[ -z "$PG_DB" ]]; then
  read -p "Database name (e.g., iox_dev): " PG_DB
fi

echo ""
echo "Server: $PG_HOST"
echo "User:   $PG_USER"
echo "Database: $PG_DB"
echo ""

# Get fresh access token from Azure CLI
echo "Retrieving access token from Azure..."
TOKEN=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv 2>/dev/null) || {
  echo "Error: Failed to get access token."
  echo "Make sure you are logged in: az login"
  exit 1
}

# Set password to token for Entra ID authentication
export PGPASSWORD="$TOKEN"

# Connection parameters
CONNECTION="-h $PG_HOST -U $PG_USER -d $PG_DB"

echo "Testing connection..."
psql $CONNECTION -c "SELECT NOW();" > /dev/null 2>&1 || {
  echo "✗ Error: Failed to connect to PostgreSQL."
  echo "  Check: server name, username, database name, firewall rules"
  exit 1
}
echo "✓ Connection successful"
echo ""

# Migration order (strict FK dependency order)
MIGRATIONS=(
  "schema/migrations/iox-core/V1.0__iox_core_project_contract.sql"
  "schema/migrations/iox-core/V1.1__iox_core_identity_access.sql"
  "schema/migrations/iox-core/V1.2__iox_core_organisation_project.sql"
  "schema/migrations/iox-core/V1.3_to_V1.11__iox_core_remaining_segments.sql"
  "schema/migrations/iox-core/V1.12__iox_core_extensions_and_foreign_keys.sql"
  "schema/migrations/iox-core/V1.13__iox_core_schema_completion.sql"
  "schema/migrations/parametrix/V0.1_to_V0.6__parametrix_parametric_estimation.sql"
)

echo "Applying migrations in order..."
echo ""

FAILED=0
for migration in "${MIGRATIONS[@]}"; do
  migration_path="$PROJECT_DIR/$migration"
  if [[ ! -f "$migration_path" ]]; then
    echo "✗ ERROR: Migration file not found: $migration"
    FAILED=1
    continue
  fi

  filename=$(basename "$migration")
  echo "→ Applying $filename"

  if psql $CONNECTION -f "$migration_path" > /dev/null 2>&1; then
    echo "  ✓ Success"
  else
    echo "✗ ERROR: Failed to apply $filename"
    FAILED=1
    break
  fi
done

if [[ $FAILED -eq 1 ]]; then
  echo ""
  echo "Migration failed. Check error details above."
  exit 1
fi

echo ""
echo "=========================================="
echo "Migration Complete ✓"
echo "=========================================="
echo ""

# Verification
echo "Schema verification:"
TABLE_COUNT=$(psql $CONNECTION -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';")
echo "  Base Tables: $TABLE_COUNT (expected: 84)"

VIEW_COUNT=$(psql $CONNECTION -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'VIEW';")
echo "  Materialized Views: $VIEW_COUNT (expected: 6)"

FK_COUNT=$(psql $CONNECTION -t -c "SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_type = 'FOREIGN KEY' AND table_schema = 'public';")
echo "  Foreign Keys: $FK_COUNT (expected: ~95)"

echo ""
echo "Next steps:"
echo "  1. Load seed data:    bash scripts/apply_seed_data.sh"
echo "  2. Generate docs:     bash scripts/generate_docs.sh"
echo ""
