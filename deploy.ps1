# ==========================================
# PowerShell Native Deployment Script for Windows
# ==========================================
param (
    [string]$BucketName,
    [string]$LambdaName,
    [string]$DistributionId,
    [string]$Region = "ap-south-1"
)

# 1. Compile Website
Write-Host "Compiling website template..." -ForegroundColor Cyan
python compile_website.py

# 2. Upload Frontend
if ($BucketName) {
    Write-Host "Uploading frontend assets to S3 bucket: $BucketName ..." -ForegroundColor Cyan
    aws s3 cp index.html s3://$BucketName/index.html --region $Region
    aws s3 cp template.html s3://$BucketName/template.html --region $Region
    if (Test-Path "photos_compressed") {
        aws s3 sync photos_compressed s3://$BucketName/photos_compressed --delete --region $Region
    }
    if (Test-Path "photos") {
        aws s3 sync photos s3://$BucketName/photos --delete --region $Region
    }
} else {
    Write-Host "S3 Bucket Name not provided. Skipping S3 upload." -ForegroundColor Yellow
}

# 3. Zip and Deploy Backend
if ($LambdaName) {
    Write-Host "Packaging and deploying backend lambda function: $LambdaName ..." -ForegroundColor Cyan
    Push-Location backend
    
    # Install production dependencies
    npm install --production
    
    # Remove existing zip
    if (Test-Path "../function.zip") { 
        Remove-Item "../function.zip" -Force 
    }
    
    # Zip package using PowerShell
    Compress-Archive -Path * -DestinationPath ../function.zip -Force
    Pop-Location

    Write-Host "Uploading package to AWS Lambda..." -ForegroundColor Cyan
    aws lambda update-function-code --function-name $LambdaName --zip-file fileb://function.zip --region $Region
} else {
    Write-Host "Lambda Function Name not provided. Skipping Lambda deploy." -ForegroundColor Yellow
}

# 4. Invalidate CloudFront Cache
if ($DistributionId) {
    Write-Host "Invalidating CloudFront cache for Distribution: $DistributionId ..." -ForegroundColor Cyan
    aws cloudfront create-invalidation --distribution-id $DistributionId --paths "/*" --region $Region
} else {
    Write-Host "CloudFront Distribution ID not provided. Skipping invalidation." -ForegroundColor Yellow
}

Write-Host "Deployment process complete!" -ForegroundColor Green
