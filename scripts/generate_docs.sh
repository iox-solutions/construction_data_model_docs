#!/bin/bash
set -e

# SchemaSpy Documentation Generator (Entra ID Compatible)
# Generates HTML ERD diagrams and schema documentation from a live PostgreSQL database
#
# Prerequisites: Docker must be installed
#
# Usage:
#   bash scripts/generate_docs.sh
#   (Will prompt for connection details)

# Check for Docker
if ! command -v docker &> /dev/null; then
  echo "Error: Docker is not installed. SchemaSpy requires Docker to run."
  echo "Install Docker from https://www.docker.com/products/docker-desktop"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_DIR/docs/schema-html"

echo "=========================================="
echo "SchemaSpy Schema Documentation Generator"
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
echo "Database: $PG_DB"
echo "Output: $OUTPUT_DIR"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Get access token for Entra ID
echo "Retrieving access token from Azure..."
TOKEN=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv 2>/dev/null) || {
  echo "Error: Failed to get access token. Make sure you are logged in: az login"
  exit 1
}

# Test connection first
export PGPASSWORD="$TOKEN"
psql -h $PG_HOST -U $PG_USER -d $PG_DB -c "SELECT NOW();" > /dev/null 2>&1 || {
  echo "✗ Error: Failed to connect to PostgreSQL."
  echo "  Check: server name, username, database name, firewall rules"
  exit 1
}

echo "✓ Connection verified"
echo ""

echo "Pulling SchemaSpy image..."
docker pull schemaspy/schemaspy:latest > /dev/null 2>&1

echo "Generating schema documentation (this may take a minute)..."
docker run --rm \
  -v "$OUTPUT_DIR:/output" \
  -w /output \
  schemaspy/schemaspy:latest \
  --database-type pgsql \
  --host "$PG_HOST" \
  --port 5432 \
  --database-name "$PG_DB" \
  --user "$PG_USER" \
  --password "$TOKEN" \
  --schema public \
  > /dev/null 2>&1 || {
  echo "✗ ERROR: SchemaSpy failed to generate documentation."
  echo "  Check your database connection and that all migrations have been applied."
  exit 1
}

echo ""
echo "=========================================="
echo "Documentation Generated Successfully ✓"
echo "=========================================="
echo ""
echo "Open the documentation:"
echo "  open $OUTPUT_DIR/index.html"
echo ""
echo "The HTML docs include:"
echo "  • Entity-Relationship Diagrams (ERDs)"
echo "  • Table structure with all columns and constraints"
echo "  • Foreign key relationships"
echo "  • Index details"
echo "  • Full schema reference"
echo ""
