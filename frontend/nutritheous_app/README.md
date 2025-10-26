# Nutritheous App

Flutter app for tracking meals and nutrition. Works on iOS, Android, and Web.

## What it does

Take a photo of your meal, get instant nutrition data. The app talks to the Spring Boot backend which uses OpenAI Vision to analyze the food.

You can also skip the photo and just type what you ate ("black coffee", "scrambled eggs") and it'll estimate the nutrition.

## Tech

- Flutter 3.24, Dart 3.5
- Riverpod for state management
- Dio for API calls
- Hive for local storage
- Material Design 3

## Setup

### Install Flutter

Get Flutter from https://docs.flutter.dev/get-started/install

Check it's working:
```bash
flutter doctor
```

### Run the app

```bash
cd frontend/nutritheous_app

# Install dependencies
flutter pub get

# Set up environment
cp .env.example .env
# Edit .env with your backend URL

# Run it
flutter run
```

### Configure .env

Create a `.env` file:

```env
# Local development
API_BASE_URL=http://localhost:8081/api

# Android emulator (can't use localhost)
# API_BASE_URL=http://10.0.2.2:8081/api

# Production
# API_BASE_URL=https://api.analyze.food/api
```

The app loads this at runtime, so you can change the API URL without rebuilding.

## Project Structure

```
lib/
├── config/
│   └── api_config.dart        # API endpoints
│
├── models/                    # Data models
│   ├── meal.dart
│   ├── nutrition.dart
│   ├── user.dart
│   └── user_profile.dart
│
├── services/                  # Backend API clients
│   ├── api_client.dart
│   ├── auth_service.dart
│   ├── meal_service.dart
│   └── statistics_service.dart
│
├── state/
│   └── providers.dart         # Riverpod providers
│
├── ui/
│   ├── screens/              # Full page views
│   └── widgets/              # Reusable components
│
└── main.dart                 # Entry point
```

## Key Features

**Meal Tracking:**
- Upload photos or text descriptions
- AI analyzes nutrition automatically
- Edit meals after uploading

**Analytics:**
- Daily calorie tracking with goals
- Weekly calendar view
- Nutrition trends (line charts)
- Macro breakdowns

**User Profile:**
- Set your age, height, weight
- Activity level and goals
- Auto-calculates daily calorie needs

## Building

### Android

```bash
# Debug APK
flutter build apk

# Release APK
flutter build apk --release

# App bundle for Play Store
flutter build appbundle --release
```

APK output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and upload to App Store.

### Web

```bash
flutter build web --release
```

Output: `build/web/`

Deploy this folder to any static hosting (Firebase, Netlify, etc).

## Platform Setup

### iOS Permissions

Edit `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Take photos of your meals</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Choose meal photos from your library</string>
```

### Android Permissions

Already configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Android Build Config

In `android/app/build.gradle`:
- `minSdkVersion 21`
- `compileSdkVersion 34`
- `targetSdkVersion 34`

## Code Generation

The app uses code generation for JSON serialization:

```bash
# Generate once
flutter pub run build_runner build

# Watch for changes
flutter pub run build_runner watch

# Clean and rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

Run this whenever you modify model classes with `@JsonSerializable()`.

## State Management

Uses Riverpod 2.6. Key providers in `lib/state/providers.dart`:

- `currentUserProvider` - Logged in user
- `mealsListProvider` - All user meals
- `todayMealsProvider` - Today's meals
- `userProfileProvider` - User profile data
- `statisticsProvider` - Analytics data

## Common Issues

**"Unable to connect to backend"**
- Check `API_BASE_URL` in `.env`
- Make sure backend is running
- On Android emulator, use `10.0.2.2` instead of `localhost`

**"Camera not working"**
- Check platform permissions (Info.plist for iOS, AndroidManifest.xml for Android)
- Test on real device (camera doesn't work in iOS simulator)

**"Build failed after adding dependencies"**
- Run `flutter clean && flutter pub get`
- For iOS: `cd ios && pod install && cd ..`

**"Hot reload not working"**
- Sometimes you need a full restart after changing `.env` or adding assets
- Stop the app and run `flutter run` again

## Development Tips

### Running on specific device

```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run on Chrome
flutter run -d chrome

# Run on iPhone simulator
flutter run -d "iPhone 15"
```

### Logging

The app uses `logger` package. Check terminal output when running `flutter run` for logs.

### Format code

```bash
flutter format .
```

### Analyze code

```bash
flutter analyze
```

## Testing

```bash
# Run tests
flutter test

# With coverage
flutter test --coverage

# View coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Deployment

### Android Play Store

1. Create keystore for signing
2. Configure `android/key.properties`
3. Build: `flutter build appbundle --release`
4. Upload to Play Console

### iOS App Store

1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select Product > Archive
3. Distribute to App Store Connect
4. Submit in App Store Connect

### Web

```bash
flutter build web --release
```

Deploy `build/web/` folder to:
- Firebase Hosting
- Netlify
- Vercel
- Any static host

## Dependencies

Main packages (see `pubspec.yaml` for versions):

```yaml
dependencies:
  flutter_riverpod: ^2.6.1      # State management
  dio: ^5.7.0                   # HTTP client
  hive: ^2.2.3                  # Local storage
  hive_flutter: ^1.1.0
  cached_network_image: ^3.4.1  # Image caching
  image_picker: ^1.1.2          # Camera/gallery
  fl_chart: ^0.69.0             # Charts
  intl: ^0.19.0                 # Date formatting
  flutter_dotenv: ^5.2.1        # Environment config
  logger: ^2.5.0                # Logging
```

---

Back to [main README](../../README.md)
