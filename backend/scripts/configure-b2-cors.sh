#!/bin/bash

# Configure CORS for Backblaze B2 bucket using AWS CLI
# Make sure you have AWS CLI installed and configured

BUCKET_NAME="aincrad"
ENDPOINT="https://s3.us-west-000.backblazeb2.com"

# Create CORS configuration file
cat > /tmp/cors-config.json << 'EOF'
{
  "CORSRules": [
    {
      "AllowedOrigins": ["*"],
      "AllowedMethods": ["GET", "HEAD"],
      "AllowedHeaders": ["*"],
      "ExposeHeaders": ["ETag", "x-amz-request-id"],
      "MaxAgeSeconds": 3600
    }
  ]
}
EOF

echo "Setting CORS configuration for bucket: $BUCKET_NAME"

# Apply CORS configuration using AWS CLI
aws s3api put-bucket-cors \
  --bucket "$BUCKET_NAME" \
  --cors-configuration file:///tmp/cors-config.json \
  --endpoint-url "$ENDPOINT"

if [ $? -eq 0 ]; then
  echo "✓ CORS configuration applied successfully!"
  echo ""
  echo "Verifying CORS configuration..."
  aws s3api get-bucket-cors \
    --bucket "$BUCKET_NAME" \
    --endpoint-url "$ENDPOINT"
else
  echo "✗ Failed to apply CORS configuration"
  echo "You may need to configure AWS CLI credentials first:"
  echo "  aws configure set aws_access_key_id 0005e099e0db5d30000000001"
  echo "  aws configure set aws_secret_access_key K000ZIWEKpK5/efIyVCuWDza+LWT4Ro"
fi

# Clean up
rm -f /tmp/cors-config.json
