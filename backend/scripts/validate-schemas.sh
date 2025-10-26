#!/bin/bash

# Validate all JSON Schema files

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  JSON Schema Validation${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCHEMA_DIR="$(cd "$SCRIPT_DIR/../schemas" && pwd)"

# Check if ajv-cli is installed
if ! command -v ajv &> /dev/null; then
    echo -e "${YELLOW}ajv-cli is not installed. Installing...${NC}"
    npm install -g ajv-cli ajv-formats
fi

echo -e "${GREEN}Validating JSON Schema files...${NC}"
echo ""

# Find all JSON schema files
schema_files=$(find "$SCHEMA_DIR" -name "*.json" -type f)

errors=0
total=0

for schema in $schema_files; do
    total=$((total + 1))
    filename=$(basename "$schema")

    echo -n -e "${BLUE}  Validating ${filename}...${NC} "

    # Validate schema syntax
    if ajv compile -s "$schema" --spec=draft7 > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo -e "${RED}    Schema validation failed for ${filename}${NC}"
        ajv compile -s "$schema" --spec=draft7
        errors=$((errors + 1))
    fi
done

echo ""
echo -e "${BLUE}================================================${NC}"

if [ $errors -eq 0 ]; then
    echo -e "${GREEN}  ✓ All ${total} schemas are valid!${NC}"
    echo -e "${BLUE}================================================${NC}"
    exit 0
else
    echo -e "${RED}  ✗ ${errors} of ${total} schemas have errors${NC}"
    echo -e "${BLUE}================================================${NC}"
    exit 1
fi
