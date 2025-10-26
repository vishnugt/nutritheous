#!/bin/bash

set -e

echo "========================================="
echo "MinIO Bucket Setup Script"
echo "========================================="

# MinIO configuration
MINIO_HOST=${MINIO_HOST:-localhost:9000}
MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY:-minioadmin}
MINIO_SECRET_KEY=${MINIO_SECRET_KEY:-minioadmin}
BUCKET_NAME=${MINIO_BUCKET:-nutritheous-images}

# Check if MinIO client (mc) is installed
if ! command -v mc &> /dev/null; then
    echo "MinIO client (mc) is not installed."
    echo "Installing MinIO client..."

    # Detect OS
    OS="$(uname -s)"
    case "${OS}" in
        Linux*)
            wget https://dl.min.io/client/mc/release/linux-amd64/mc
            chmod +x mc
            sudo mv mc /usr/local/bin/
            ;;
        Darwin*)
            brew install minio/stable/mc 2>/dev/null || {
                curl https://dl.min.io/client/mc/release/darwin-amd64/mc -o mc
                chmod +x mc
                sudo mv mc /usr/local/bin/
            }
            ;;
        *)
            echo "Unsupported OS: ${OS}"
            exit 1
            ;;
    esac
fi

# Configure MinIO client
echo "Configuring MinIO client..."
mc alias set local http://${MINIO_HOST} ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}

# Create bucket if it doesn't exist
echo "Creating bucket: ${BUCKET_NAME}..."
mc mb local/${BUCKET_NAME} --ignore-existing

# Set bucket policy to allow public read (optional, adjust as needed)
# mc anonymous set download local/${BUCKET_NAME}

echo ""
echo "========================================="
echo "MinIO setup completed successfully!"
echo "========================================="
echo "Bucket '${BUCKET_NAME}' is ready to use."
echo ""
