#!/bin/bash

# Nutritheous Icon Generator Script
# Generates all required app icons for Android and iOS from a source image

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SOURCE_ICON="$SCRIPT_DIR/icon.png"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo -e "${RED}❌ Error: Source icon not found at $SOURCE_ICON${NC}"
    echo -e "${YELLOW}📝 Please create a 1024x1024px PNG icon and save it as 'icon.png' in the icons folder${NC}"
    exit 1
fi

# Verify source icon dimensions
SOURCE_WIDTH=$(sips -g pixelWidth "$SOURCE_ICON" | awk '/pixelWidth:/ {print $2}')
SOURCE_HEIGHT=$(sips -g pixelHeight "$SOURCE_ICON" | awk '/pixelHeight:/ {print $2}')

echo -e "${BLUE}🎨 Nutritheous Icon Generator${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "Source icon: $SOURCE_ICON"
echo "Dimensions: ${SOURCE_WIDTH}x${SOURCE_HEIGHT}px"
echo ""

if [ "$SOURCE_WIDTH" -lt 1024 ] || [ "$SOURCE_HEIGHT" -lt 1024 ]; then
    echo -e "${YELLOW}⚠️  Warning: Source icon is smaller than 1024x1024px. Quality may be degraded.${NC}"
    echo ""
fi

# Function to generate icon
generate_icon() {
    local size=$1
    local output=$2
    local name=$3

    mkdir -p "$(dirname "$output")"
    sips -z "$size" "$size" "$SOURCE_ICON" --out "$output" > /dev/null 2>&1
    echo -e "${GREEN}✅ Generated $name ($size x $size)${NC}"
}

echo -e "${BLUE}📱 Generating Android Icons...${NC}"
echo ""

# Android Icons - relative to project root
ANDROID_ROOT="../android/app/src/main/res"

generate_icon 48 "$ANDROID_ROOT/mipmap-mdpi/ic_launcher.png" "mdpi"
generate_icon 72 "$ANDROID_ROOT/mipmap-hdpi/ic_launcher.png" "hdpi"
generate_icon 96 "$ANDROID_ROOT/mipmap-xhdpi/ic_launcher.png" "xhdpi"
generate_icon 144 "$ANDROID_ROOT/mipmap-xxhdpi/ic_launcher.png" "xxhdpi"
generate_icon 192 "$ANDROID_ROOT/mipmap-xxxhdpi/ic_launcher.png" "xxxhdpi"

echo ""
echo -e "${BLUE}🍎 Generating iOS Icons...${NC}"
echo ""

# iOS Icons - need to update Contents.json manually or use flutter_launcher_icons
IOS_ROOT="../ios/Runner/Assets.xcassets/AppIcon.appiconset"

# iOS requires specific naming
generate_icon 20 "$IOS_ROOT/Icon-20.png" "iPhone Notification @1x"
generate_icon 40 "$IOS_ROOT/Icon-40.png" "iPhone Notification @2x / Spotlight @1x"
generate_icon 60 "$IOS_ROOT/Icon-60.png" "iPhone Notification @3x"
generate_icon 29 "$IOS_ROOT/Icon-29.png" "iPhone Settings @1x"
generate_icon 58 "$IOS_ROOT/Icon-58.png" "iPhone Settings @2x"
generate_icon 87 "$IOS_ROOT/Icon-87.png" "iPhone Settings @3x"
generate_icon 80 "$IOS_ROOT/Icon-80.png" "iPhone Spotlight @2x"
generate_icon 120 "$IOS_ROOT/Icon-120.png" "iPhone Spotlight @3x / App @2x"
generate_icon 180 "$IOS_ROOT/Icon-180.png" "iPhone App @3x"
generate_icon 1024 "$IOS_ROOT/Icon-1024.png" "App Store"

echo ""
echo -e "${GREEN}✨ Icon generation complete!${NC}"
echo ""
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "1. For iOS, update Contents.json with new icon references (or use flutter_launcher_icons)"
echo "2. Run: flutter clean"
echo "3. Rebuild your app"
echo "4. Uninstall old version from device"
echo "5. Install to see new icons"
echo ""
echo -e "${BLUE}💡 Tip: For easier icon management, consider using 'flutter_launcher_icons' package${NC}"
echo "   See README.md in this folder for instructions"
