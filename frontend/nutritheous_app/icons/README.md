# Nutritheous App Icons

This folder contains the source icon and generated app icons for all platforms.

## Quick Start (Recommended)

The easiest way to generate all required icons is using the `flutter_launcher_icons` package:

### 1. Add to pubspec.yaml

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "icons/icon.png"
  min_sdk_android: 21

  # Optional: Adaptive icons for Android
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "icons/icon_foreground.png"
```

### 2. Place Your Icon

- Put your **1024x1024px** icon as `icon.png` in this folder
- For Android adaptive icons, also create `icon_foreground.png` (432x432px)

### 3. Generate Icons

```bash
flutter pub get
dart run flutter_launcher_icons
```

This will automatically generate all required sizes for Android and iOS.

---

## Manual Generation (Alternative)

If you prefer manual control, use the provided script:

### 1. Place Source Icon
- Create a **1024x1024px PNG** icon and save as `icon.png` in this folder

### 2. Run Generation Script
```bash
chmod +x generate_icons.sh
./generate_icons.sh
```

---

## Required Icon Sizes

### Android (mipmap folders)

| Size | Density | Usage |
|------|---------|-------|
| 48x48 | mdpi | Medium density |
| 72x72 | hdpi | High density |
| 96x96 | xhdpi | Extra high density |
| 144x144 | xxhdpi | Extra extra high density |
| 192x192 | xxxhdpi | Extra extra extra high density |

### iOS (Assets.xcassets)

| Size | Scale | Device |
|------|-------|--------|
| 20x20 | @1x | iPhone Notification |
| 40x40 | @2x | iPhone Notification |
| 60x60 | @3x | iPhone Notification |
| 29x29 | @1x | iPhone Settings |
| 58x58 | @2x | iPhone Settings |
| 87x87 | @3x | iPhone Settings |
| 40x40 | @1x | iPhone Spotlight |
| 80x80 | @2x | iPhone Spotlight |
| 120x120 | @3x | iPhone Spotlight |
| 120x120 | @2x | iPhone App |
| 180x180 | @3x | iPhone App |
| 1024x1024 | @1x | App Store |

---

## Design Guidelines

### General
- ✅ Square image (1:1 aspect ratio)
- ✅ No transparency (use solid background)
- ✅ Simple, recognizable design
- ✅ Works well at small sizes
- ✅ Distinctive color scheme

### Android Adaptive Icons
- Foreground: 432x432px centered on 1024x1024px canvas
- Safe zone: Keep important content within 264x264px center
- Background: Solid color or simple pattern

### iOS
- Fill entire square (no rounded corners, iOS adds them)
- No text or thin lines (hard to read at small sizes)
- High contrast

---

## Current Status

- [ ] Source icon (1024x1024px) - `icon.png`
- [ ] Android adaptive foreground - `icon_foreground.png`
- [ ] Icons generated for Android
- [ ] Icons generated for iOS

---

## Tools

### Online Generators
- [App Icon Generator](https://www.appicon.co/)
- [Icon Kitchen](https://icon.kitchen/)
- [MakeAppIcon](https://makeappicon.com/)

### Local Tools
- **flutter_launcher_icons** (recommended)
- ImageMagick: `brew install imagemagick`
- macOS sips: Built-in, use provided script

---

## Notes

After generating icons, you may need to:
1. Run `flutter clean`
2. Rebuild the app
3. Uninstall old version from device
4. Reinstall to see new icons
