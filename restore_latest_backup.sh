#!/bin/bash

# Define your bucket
BUCKET="nkorai-blog"
DEST_DIR="./ghost_content"

# Ensure destination directory exists
mkdir -p "$DEST_DIR"

# Get the latest backup file by LastModified timestamp
LATEST_FILE=$(aws s3api list-objects-v2 \
  --bucket "$BUCKET" \
  --query 'Contents[?contains(Key, `blog-backup`)] | sort_by(@, &LastModified)[-1].Key' \
  --output text)

if [ -z "$LATEST_FILE" ]; then
  echo "❌ No backup file found in S3 bucket '$BUCKET'"
  exit 1
fi

echo "✅ Latest backup file: $LATEST_FILE"

# Download the latest backup
aws s3 cp "s3://$BUCKET/$LATEST_FILE" "$DEST_DIR/"

# Extract it
echo "📦 Extracting backup into $DEST_DIR..."
tar -xzvf "$DEST_DIR/$(basename "$LATEST_FILE")" -C "$DEST_DIR"

