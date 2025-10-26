# Nutritheous Backend

Spring Boot REST API for the Nutritheous meal tracking app.

## Overview

This is the backend that powers Nutritheous. It handles user authentication, stores meal data, manages image uploads to Google Cloud Storage, and talks to OpenAI's Vision API for nutrition analysis.

Stack:
- Spring Boot 3.2 (Java 17)
- PostgreSQL 15
- Google Cloud Storage
- OpenAI GPT-4 Vision

## Getting Started

### Requirements

- Java 17 or newer
- PostgreSQL 15+
- Google Cloud Platform account (for storage)
- OpenAI API key

### Setup

From the root directory:

```bash
# 1. Set up environment
cp .env.example .env
# Edit .env with your credentials

# 2. Start PostgreSQL
make docker-up

# 3. Run the backend
cd backend
./gradlew bootRun
```

API runs on http://localhost:8081

### Configuration

All config comes from environment variables (loaded from `.env`). Here's what you need:

**Database:**
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=nutritheous
DB_USERNAME=nutritheous
DB_PASSWORD=nutritheous
```

**Google Cloud Storage:**
```env
GCS_PROJECT_ID=your-project-id
GCS_CREDENTIALS_JSON={"type":"service_account",...}
GCS_BUCKET_NAME=your-bucket
```

You can provide GCS credentials two ways:
1. As JSON string in `GCS_CREDENTIALS_JSON` (recommended)
2. As file path in `GCS_CREDENTIALS_PATH` (for local dev)

**OpenAI:**
```env
OPENAI_API_KEY=sk-proj-...
OPENAI_MODEL=gpt-4o-mini
```

**JWT:**
```env
JWT_SECRET=your-super-secret-key  # Use: openssl rand -base64 32
JWT_EXPIRATION=86400000           # 24 hours
```

## Project Structure

```
backend/
├── src/main/java/com/nutritheous/
│   ├── auth/              # Users, login, JWT
│   ├── meal/              # Meal CRUD and service
│   ├── storage/           # Google Cloud Storage
│   ├── analyzer/          # OpenAI Vision integration
│   ├── image/             # Image compression
│   ├── statistics/        # Analytics endpoints
│   ├── config/            # Spring config, security
│   └── common/            # DTOs, exceptions
│
└── src/main/resources/
    ├── application.properties
    └── db/migration/      # Flyway migrations
```

## Database

Uses Flyway for migrations. Migration files are in `src/main/resources/db/migration/`.

Key tables:
- `users` - User accounts and auth
- `meals` - Meal entries with nutrition data
- `user_profile` - User profiles (age, weight, goals, etc.)

To reset the database:
```bash
make fresh
```

To check migration status:
```bash
./gradlew flywayInfo
```

## API Endpoints

### Auth

**Register:**
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

**Login:**
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response:
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "user@example.com",
  "role": "USER"
}
```

### Meals

All meal endpoints require `Authorization: Bearer <token>` header.

**Upload Meal:**
```http
POST /api/meals/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

Form fields:
- image: File (optional)
- mealType: BREAKFAST|LUNCH|DINNER|SNACK
- mealTime: 2024-10-26T12:00:00Z
- description: Text description (optional)
```

Either `image` or `description` must be provided (or both).

**Get Meals:**
```http
GET /api/meals
Authorization: Bearer <token>
```

**Get Single Meal:**
```http
GET /api/meals/{id}
Authorization: Bearer <token>
```

**Update Meal:**
```http
PUT /api/meals/{id}
Authorization: Bearer <token>
Content-Type: application/json

{
  "calories": 450,
  "proteinG": 30,
  "fatG": 15,
  ...
}
```

**Delete Meal:**
```http
DELETE /api/meals/{id}
Authorization: Bearer <token>
```

**Get Meals by Date Range:**
```http
GET /api/meals/range?startDate=2024-10-01T00:00:00Z&endDate=2024-10-31T23:59:59Z
Authorization: Bearer <token>
```

### Statistics

```http
GET /api/statistics/daily?date=2024-10-26
GET /api/statistics/weekly?startDate=2024-10-20
GET /api/statistics/monthly?year=2024&month=10
```

### API Documentation

When running locally:
- Swagger UI: http://localhost:8081/swagger-ui.html
- OpenAPI JSON: http://localhost:8081/v3/api-docs

## How It Works

### Meal Upload Flow

1. User uploads image/text via Flutter app
2. Backend validates request
3. If image provided:
   - Compresses image (max 300KB)
   - Uploads to Google Cloud Storage
4. Sends image URL + description to OpenAI Vision
5. OpenAI returns nutrition data as JSON
6. Saves meal + nutrition to PostgreSQL
7. Returns meal data to app

### Image Storage

Images are stored in Google Cloud Storage with this structure:
```
bucket-name/
└── {userId}/
    └── {randomUUID}.jpg
```

Signed URLs are generated on-demand with 24-hour expiry.

### AI Analysis

The `OpenAIVisionService` sends the meal image to GPT-4 Vision with a prompt asking for:
- Calories
- Macros (protein, carbs, fat)
- Fiber, sugar, sodium, etc.
- Serving size
- Ingredients list

The AI response is parsed and stored in the `nutrition` JSONB column.

## Development

### Running Tests

```bash
./gradlew test
```

### Building

```bash
# Build JAR
./gradlew bootJar

# Run JAR
java -jar build/libs/nutritheous-server-0.0.1-SNAPSHOT.jar
```

### Code Structure

The code follows standard Spring Boot patterns:
- Controllers handle HTTP requests
- Services contain business logic
- Repositories interact with database
- DTOs for request/response objects
- Global exception handler for errors

## Deployment

Current deployment is at https://api.analyze.food

For your own deployment:

1. Set all environment variables
2. Use a strong random JWT_SECRET
3. Configure CORS for your frontend domain
4. Enable HTTPS
5. Set up database backups
6. Configure logging/monitoring

### Docker

You can run it with Docker Compose:
```bash
docker-compose up -d backend
```

The `docker-compose.yml` in the root includes both PostgreSQL and the backend.

## Common Issues

**"GCS credentials not configured"**
- Make sure either `GCS_CREDENTIALS_JSON` or `GCS_CREDENTIALS_PATH` is set in your `.env`

**"Failed to authenticate user"**
- Check your JWT_SECRET is set
- Verify the token hasn't expired

**"Database connection failed"**
- Make sure PostgreSQL is running (`make docker-up`)
- Check DB_* environment variables

## Contributing

Keep it simple:
1. Write tests for new features
2. Follow existing code style
3. Add Flyway migrations for schema changes
4. Update API docs if adding endpoints

---

Back to [main README](../README.md)
