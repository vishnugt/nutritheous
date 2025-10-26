#!/bin/bash

set -e

echo "========================================="
echo "Nutritheous Server Setup Script"
echo "========================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
    echo ".env file created. Please update it with your configuration."
fi

# Start Docker containers
echo "Starting PostgreSQL and MinIO containers..."
docker-compose up -d

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 10

# Wait for MinIO to be ready
echo "Waiting for MinIO to be ready..."
sleep 5

echo ""
echo "========================================="
echo "Setup completed successfully!"
echo "========================================="
echo ""
echo "Services:"
echo "  - PostgreSQL: localhost:5432"
echo "  - MinIO API: localhost:9000"
echo "  - MinIO Console: localhost:9001"
echo ""
echo "Next steps:"
echo "  1. Update .env file with your configuration"
echo "  2. Run 'make build' to build the application"
echo "  3. Run 'make run' to start the application"
echo "  4. Access Swagger UI at http://localhost:8081/swagger-ui.html"
echo ""
