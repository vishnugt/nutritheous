#!/bin/bash

# Master script to generate models for both Java and Dart from JSON Schemas

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}  Model Generation from JSON Schemas${NC}"
echo -e "${BLUE}  Generating models for Java and Dart/Flutter${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Step 1: Generate Java models
echo -e "${GREEN}[1/2] Generating Java models with Gradle...${NC}"
echo ""

cd "$PROJECT_ROOT"
./gradlew generateJsonSchema2Pojo

if [ $? -eq 0 ]; then
    echo -e "${GREEN}    ✓ Java models generated successfully${NC}"
    echo -e "${GREEN}      Location: build/generated-sources/js2p/${NC}"
else
    echo -e "${RED}    ✗ Failed to generate Java models${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}------------------------------------------------------${NC}"
echo ""

# Step 2: Generate Dart models
echo -e "${GREEN}[2/2] Generating Dart models with quicktype...${NC}"
echo ""

cd "$SCRIPT_DIR"
./generate-dart-models.sh

if [ $? -eq 0 ]; then
    echo -e "${GREEN}    ✓ Dart models generated successfully${NC}"
else
    echo -e "${RED}    ✗ Failed to generate Dart models${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  ✓ All models generated successfully!${NC}"
echo -e "${GREEN}======================================================${NC}"
echo ""
echo -e "${BLUE}Generated files:${NC}"
echo -e "  Java:   ${PROJECT_ROOT}/build/generated-sources/js2p/"
echo -e "  Dart:   ${PROJECT_ROOT}/nutritheous_app/lib/generated/models/"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Review generated models"
echo -e "  2. Rebuild Java project: ${BLUE}./gradlew build${NC}"
echo -e "  3. Run Flutter app: ${BLUE}cd nutritheous_app && flutter run${NC}"
echo ""
