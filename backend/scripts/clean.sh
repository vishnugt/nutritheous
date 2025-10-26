#!/bin/bash

set -e

echo "========================================="
echo "Cleaning Nutritheous Server"
echo "========================================="

# Stop and remove Docker containers
echo "Stopping Docker containers..."
docker-compose down

# Remove Docker volumes (optional, comment out if you want to preserve data)
read -p "Do you want to remove all data (PostgreSQL and MinIO)? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing Docker volumes..."
    docker-compose down -v
fi

# Clean Gradle build
echo "Cleaning Gradle build..."
./gradlew clean || echo "Gradle clean skipped (gradlew not executable or Gradle not installed)"

echo ""
echo "========================================="
echo "Cleanup completed!"
echo "========================================="
echo ""
