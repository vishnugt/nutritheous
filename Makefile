.PHONY: help run fresh db-status build test clean docker-up docker-down swagger flutter-build flutter-run

# Default target
help:
	@echo "Nutritheous - Available Commands:"
	@echo ""
	@echo "Backend (Spring Boot):"
	@echo "  make run         - Stop existing process and start backend"
	@echo "  make fresh       - Clean database, stop existing process, and start fresh"
	@echo "  make db-status   - Check database tables and structure"
	@echo "  make build       - Build the backend application"
	@echo "  make test        - Run backend tests"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make swagger     - Generate swagger.json API documentation"
	@echo ""
	@echo "Frontend (Flutter):"
	@echo "  make flutter-build - Build Flutter app"
	@echo "  make flutter-run   - Run Flutter app"
	@echo ""
	@echo "Infrastructure:"
	@echo "  make docker-up   - Start Docker containers"
	@echo "  make docker-down - Stop Docker containers"
	@echo ""

# Run: Stop existing process and start
run:
	@echo "Stopping any existing application..."
	@pkill -f 'bootRun' || true
	@lsof -ti:8081 | xargs kill -9 2>/dev/null || true
	@sleep 2
	@echo "Starting backend application..."
	@cd backend && set -a && . ../.env && set +a && ./gradlew bootRun

# Fresh: Clean database and start fresh
fresh:
	@echo "Cleaning database..."
	@docker exec nutritheous-postgres psql -U nutritheous -d nutritheous -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" || echo "Error: Database not accessible. Run 'make docker-up' first."
	@echo "Stopping any existing application..."
	@pkill -f 'bootRun' || true
	@lsof -ti:8081 | xargs kill -9 2>/dev/null || true
	@sleep 2
	@echo "Starting backend application (migrations will run automatically)..."
	@cd backend && set -a && . ../.env && set +a && ./gradlew bootRun

# Check database status
db-status:
	@echo "Checking database tables..."
	@docker exec nutritheous-postgres psql -U nutritheous -d nutritheous -c "\dt" || echo "Error: Database not accessible. Run 'make docker-up' first."
	@echo ""
	@echo "Checking users table:"
	@docker exec nutritheous-postgres psql -U nutritheous -d nutritheous -c "\d users" || true
	@echo ""
	@echo "Checking meals table:"
	@docker exec nutritheous-postgres psql -U nutritheous -d nutritheous -c "\d meals" || true

# Build the application
build:
	@echo "Building backend application..."
	@cd backend && ./gradlew build -x test

# Run tests
test:
	@echo "Running backend tests..."
	@cd backend && ./gradlew test

# Clean build artifacts
clean:
	@echo "Cleaning backend build artifacts..."
	@cd backend && ./gradlew clean

# Generate swagger documentation
swagger:
	@echo "Generating swagger.json API documentation..."
	@cd backend && ./gradlew generateSwaggerDocs
	@echo ""
	@echo "Swagger documentation generated at: backend/build/docs/swagger.json"

# Flutter build
flutter-build:
	@echo "Building Flutter app..."
	@cd frontend/nutritheous_app && flutter pub get && flutter build apk

# Flutter run
flutter-run:
	@echo "Running Flutter app..."
	@cd frontend/nutritheous_app && flutter run

# Start Docker containers
docker-up:
	@echo "Starting Docker containers..."
	@docker-compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 10

# Stop Docker containers
docker-down:
	@echo "Stopping Docker containers..."
	@docker-compose down
