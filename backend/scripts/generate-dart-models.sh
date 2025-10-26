#!/bin/bash

# Generate Dart models from JSON Schemas
# Uses quicktype CLI tool to convert JSON Schema to Dart

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Dart Model Generation from JSON Schemas${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if quicktype is installed
if ! command -v quicktype &> /dev/null; then
    echo -e "${YELLOW}quicktype is not installed. Installing...${NC}"
    npm install -g quicktype
fi

# Directories
SCHEMA_DIR="../schemas"
OUTPUT_DIR="../nutritheous_app/lib/generated/models"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Navigate to script directory
cd "$SCRIPT_DIR"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo -e "${GREEN}Generating Dart models...${NC}"
echo ""

# Function to generate Dart model from schema
generate_model() {
    local schema_file=$1
    local output_name=$2
    local class_name=$3

    echo -e "${BLUE}  → Generating ${class_name} from ${schema_file}${NC}"

    quicktype \
        --src "${schema_file}" \
        --src-lang schema \
        --lang dart \
        --out "${OUTPUT_DIR}/${output_name}.dart" \
        --top-level "${class_name}" \
        --no-enums \
        --density comfortable \
        --null-safety \
        --required-props \
        --copy-with \
        --from-json-dynamic

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}    ✓ ${class_name} generated successfully${NC}"
    else
        echo -e "${RED}    ✗ Failed to generate ${class_name}${NC}"
        return 1
    fi
}

# Generate models
echo -e "${BLUE}Generating enum types...${NC}"
generate_model "${SCHEMA_DIR}/common/analysis-status.json" "analysis_status" "AnalysisStatus"
generate_model "${SCHEMA_DIR}/common/meal-type.json" "meal_type" "MealType"

echo ""
echo -e "${BLUE}Generating main models...${NC}"
generate_model "${SCHEMA_DIR}/models/user.json" "user" "User"
generate_model "${SCHEMA_DIR}/models/meal.json" "meal" "Meal"
generate_model "${SCHEMA_DIR}/models/daily-nutrition-stats.json" "daily_nutrition_stats" "DailyNutritionStats"
generate_model "${SCHEMA_DIR}/models/meal-type-distribution.json" "meal_type_distribution" "MealTypeDistribution"
generate_model "${SCHEMA_DIR}/models/nutrition-summary.json" "nutrition_summary" "NutritionSummary"

echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  Dart models generated successfully!${NC}"
echo -e "${GREEN}  Output directory: ${OUTPUT_DIR}${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Review generated models in: ${OUTPUT_DIR}"
echo -e "  2. Run 'flutter pub get' if needed"
echo -e "  3. Import models in your Flutter code:"
echo -e "     ${BLUE}import 'package:nutritheous_app/generated/models/meal.dart';${NC}"
echo ""
