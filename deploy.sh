#!/bin/bash
# ==========================================
# Bash Deployment Script for Linux / Git Bash / macOS
# ==========================================

# Exit on error
set -e

# Help instructions
usage() {
  echo "Usage: $0 -b <s3-bucket-name> -l <lambda-function-name> -c <cloudfront-distribution-id> [-r <aws-region>]"
  exit 1
}

# Defaults
REGION="ap-south-1"

# Parse arguments
while getopts "b:l:c:r:" opt; do
  case ${opt} in
    b ) BUCKET_NAME=$OPTARG ;;
    l ) LAMBDA_NAME=$OPTARG ;;
    c ) DISTRIBUTION_ID=$OPTARG ;;
    r ) REGION=$OPTARG ;;
    \? ) usage ;;
  esac
done

if [ -z "$BUCKET_NAME" ] || [ -z "$LAMBDA_NAME" ] || [ -z "$DISTRIBUTION_ID" ]; then
  echo "Error: Missing required parameters."
  usage
fi

echo "Compiling website template..."
python compile_website.py

echo "Uploading frontend assets to S3: $BUCKET_NAME..."
aws s3 cp index.html s3://$BUCKET_NAME/index.html --region $REGION
aws s3 cp template.html s3://$BUCKET_NAME/template.html --region $REGION
if [ -d "photos_compressed" ]; then
  aws s3 sync photos_compressed s3://$BUCKET_NAME/photos_compressed --delete --region $REGION
fi
if [ -d "photos" ]; then
  aws s3 sync photos s3://$BUCKET_NAME/photos --delete --region $REGION
fi

echo "Packaging and deploying backend Lambda: $LAMBDA_NAME..."
cd backend
npm install --production

# Remove old zip if exists
rm -f ../function.zip
zip -r ../function.zip . -x "*.git*"
cd ..

echo "Uploading package to AWS Lambda..."
aws lambda update-function-code --function-name $LAMBDA_NAME --zip-file fileb://function.zip --region $REGION

echo "Invalidating CloudFront CDN cache: $DISTRIBUTION_ID..."
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*" --region $REGION

echo "Deployment complete!"
