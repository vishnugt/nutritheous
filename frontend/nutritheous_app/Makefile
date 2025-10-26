.PHONY: help setup build run test clean doctor format lint generate

help: ## Show this help message
	@echo "Nutritheous Flutter App - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Install dependencies and setup the project
	@echo "Setting up Nutritheous Flutter app..."
	flutter pub get
	@echo "Running code generation..."
	dart run build_runner build --delete-conflicting-outputs
	@echo "Setup complete!"

build: ## Build the app for all platforms
	@echo "Building Flutter app..."
	flutter build apk
	flutter build ios --no-codesign
	@echo "Build complete!"

build-android: ## Build for Android
	@echo "Building for Android..."
	flutter build apk --release
	@echo "Android build complete!"

build-ios: ## Build for iOS
	@echo "Building for iOS..."
	flutter build ios --release --no-codesign
	@echo "iOS build complete!"

run: ## Run the app in debug mode
	@echo "Running Nutritheous app..."
	flutter run

run-release: ## Run the app in release mode
	@echo "Running Nutritheous app in release mode..."
	flutter run --release

test: ## Run all tests
	@echo "Running tests..."
	flutter test
	@echo "Tests complete!"

test-coverage: ## Run tests with coverage
	@echo "Running tests with coverage..."
	flutter test --coverage
	@echo "Generating coverage report..."
	genhtml coverage/lcov.info -o coverage/html
	@echo "Coverage report generated in coverage/html/"

integration-test: ## Run integration tests
	@echo "Running integration tests..."
	flutter test integration_test
	@echo "Integration tests complete!"

clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	flutter clean
	rm -rf .dart_tool
	rm -rf build
	@echo "Clean complete!"

deep-clean: clean ## Deep clean including dependencies
	@echo "Performing deep clean..."
	rm -rf pubspec.lock
	rm -rf .flutter-plugins
	rm -rf .flutter-plugins-dependencies
	@echo "Deep clean complete! Run 'make setup' to reinstall."

doctor: ## Run Flutter doctor
	@echo "Running Flutter doctor..."
	flutter doctor -v

format: ## Format all Dart files
	@echo "Formatting Dart files..."
	dart format lib test
	@echo "Formatting complete!"

lint: ## Run the linter
	@echo "Running linter..."
	flutter analyze
	@echo "Linting complete!"

generate: ## Run code generation
	@echo "Running code generation..."
	dart run build_runner build --delete-conflicting-outputs
	@echo "Code generation complete!"

watch: ## Watch for changes and run code generation
	@echo "Watching for changes..."
	dart run build_runner watch --delete-conflicting-outputs

upgrade: ## Upgrade Flutter dependencies
	@echo "Upgrading dependencies..."
	flutter pub upgrade
	@echo "Upgrade complete!"

outdated: ## Check for outdated dependencies
	@echo "Checking for outdated dependencies..."
	flutter pub outdated

check: lint test ## Run linter and tests
	@echo "All checks passed!"

dev: generate run ## Generate code and run the app

release-apk: ## Build release APK
	@echo "Building release APK..."
	flutter build apk --release --split-per-abi
	@echo "Release APK built!"

release-bundle: ## Build release App Bundle
	@echo "Building release App Bundle..."
	flutter build appbundle --release
	@echo "Release App Bundle built!"

icons: ## Generate app icons
	@echo "Generating app icons..."
	flutter pub run flutter_launcher_icons
	@echo "App icons generated!"

splash: ## Generate splash screen
	@echo "Generating splash screen..."
	flutter pub run flutter_native_splash:create
	@echo "Splash screen generated!"

.DEFAULT_GOAL := help
