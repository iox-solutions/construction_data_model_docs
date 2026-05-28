#!/bin/bash
set -e

# Apply IOX Seed Data Script (Entra ID Compatible)
# Loads realistic construction project data into an initialized schema
#
# Prerequisites: Migrations must be applied first
#
# Usage:
#   bash scripts/apply_seed_data.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=========================================="
echo "IOX Seed Data Loader"
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

# Get fresh access token
echo "Retrieving access token from Azure..."
TOKEN=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv 2>/dev/null) || {
  echo "Error: Failed to get access token. Make sure you are logged in: az login"
  exit 1
}

export PGPASSWORD="$TOKEN"
CONNECTION="-h $PG_HOST -U $PG_USER -d $PG_DB"

# Verify connection
echo "Testing connection..."
psql $CONNECTION -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" > /dev/null 2>&1 || {
  echo "✗ Error: Failed to connect to PostgreSQL."
  exit 1
}
echo "✓ Connection successful"
echo ""

SEED_FILE="$PROJECT_DIR/schema/seed/seed_data.sql"
if [[ ! -f "$SEED_FILE" ]]; then
  echo "✗ Error: Seed data file not found: $SEED_FILE"
  exit 1
fi

echo "Loading seed data (5 projects with realistic scenario data)..."
echo ""

if psql $CONNECTION -f "$SEED_FILE" > /dev/null 2>&1; then
  echo "✓ Seed data loaded successfully"
else
  echo "✗ Error: Failed to load seed data"
  exit 1
fi

echo ""
echo "=========================================="
echo "Data Load Complete ✓"
echo "=========================================="
echo ""

# Quick summary
echo "Data Summary:"
psql $CONNECTION -c "
SELECT
  (SELECT COUNT(*) FROM \"Project\") as projects,
  (SELECT COUNT(*) FROM \"Contract\") as contracts,
  (SELECT COUNT(*) FROM \"User\") as users,
  (SELECT COUNT(*) FROM \"Organization\") as organizations,
  (SELECT COUNT(*) FROM \"ActionItem\" WHERE \"status\" = 'OPEN') as open_actions,
  (SELECT COUNT(*) FROM \"Risk\" WHERE \"status\" = 'OPEN') as identified_risks;
"

echo ""
echo "Next step:"
echo "  Generate schema docs:  bash scripts/generate_docs.sh"
echo ""
