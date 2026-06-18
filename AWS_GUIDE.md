# AWS Serverless Temple Booking Platform - Deployment Guide

This guide explains the architecture, step-by-step AWS CloudFormation deployment, database integration, GitHub Actions CI/CD setup, and cost calculations for the serverless Temple/Pooja Booking System.

---

## 1. Architecture Diagram

```mermaid
graph TD
    Client[Client Browser] -->|HTTPS Requests| CF[AWS CloudFront CDN]
    Client -->|Booking Confirmed| SES[AWS SES Email Service]
    CF -->|Default Route /*| S3[AWS S3 Bucket: index.html]
    CF -->|API Route /api/*| AGW[AWS API Gateway HTTP API]
    AGW -->|Triggers| Lambda[AWS Lambda: Node.js Backend]
    Lambda -->|Queries| Neon[Neon PostgreSQL DB]
    Lambda -->|API Calls| RZP[Razorpay SDK Payments]
    Lambda -->|Sends Email| SES
    SES -->|Notification| Email[indrakantivenkatagopalakrishna@gmail.com]
```

---

## 2. Infrastructure Setup (AWS Console / CLI)

### Step 2.1: Pre-requisites
1. Active AWS Account.
2. Active Neon PostgreSQL account (free tier works perfectly).
3. Active Razorpay merchant account (test mode API keys are fine).
4. AWS CLI configured on your local workstation.

### Step 2.2: Deploy CloudFormation Stack
We use the provided CloudFormation template located at `infra/cloudformation.yaml`.

Run the following command to deploy the stack:
```bash
aws cloudformation deploy \
  --template-file infra/cloudformation.yaml \
  --stack-name temple-booking-stack \
  --parameter-overrides \
      DatabaseUrl="postgresql://[user]:[password]@[host]/[dbname]?sslmode=require" \
      RazorpayKeyId="your_razorpay_key_id" \
      RazorpayKeySecret="your_razorpay_key_secret" \
  --capabilities CAPABILITY_IAM \
  --region ap-south-1
```
*(You can use `ap-south-1` for Mumbai/India for lowest latency, or `us-east-1` for standard).*

Once the command finishes, note down the outputs in the AWS Console:
* `S3BucketName` (e.g., `temple-booking-frontend-123456789012-prod`)
* `LAMBDA_FUNCTION_NAME` (e.g., `temple-booking-backend-prod`)
* `CloudFrontDistributionId` (e.g., `E2A1B2C3D4E5F6`)
* `WebsiteURL` (e.g., `https://dxxxxxxxxxx.cloudfront.net`)

---

## 3. Database Initialization (Neon PostgreSQL)

1. Connect to your Neon PostgreSQL console or use a Postgres client (like DBeaver, pgAdmin, or psql).
2. Open the file `database/schema.sql` and run all SQL commands.
3. This creates the tables: `users`, `slots`, `bookings`, `payments`, and `admin_users`, and seeds a default admin account:
   * **Username:** `admin`
   * **Password:** `AdminPass123!`

---

## 4. GitHub Actions CI/CD Setup

1. Open your repository on GitHub.
2. Go to **Settings** -> **Secrets and variables** -> **Actions** -> **Secrets**.
3. Create the following Repository Secrets:
   * `AWS_ACCESS_KEY_ID`: Your AWS User Access Key
   * `AWS_SECRET_ACCESS_KEY`: Your AWS User Secret Access Key
   * `AWS_REGION`: e.g. `ap-south-1` (or your chosen region)
   * `S3_BUCKET_NAME`: The name of the S3 bucket created by CloudFormation
   * `LAMBDA_FUNCTION_NAME`: `temple-booking-backend-prod`
   * `CLOUDFRONT_DISTRIBUTION_ID`: The ID of your CloudFront distribution

Every push to the `main` or `master` branch will trigger an automated build, compile `index.html` with assets, sync the S3 bucket, package the Lambda backend zip, update the Lambda function code, and invalidate the CloudFront CDN caches.

---

## 5. Cost Estimate (10 to 50 users/day)

This architecture is optimized for near-zero cost, especially at low-tier traffic volumes.

| AWS Resource | Standard Pricing | Estimate for 10-50 Users/day | Monthly Cost |
| :--- | :--- | :--- | :--- |
| **AWS S3** | $0.023 per GB/mo | Site is ~1MB. Total storage < 10MB. | **$0.00** (Free Tier) |
| **AWS CloudFront** | 1TB free outbound transfer/mo | 50 users * 1MB * 30 days = 1.5GB/mo transfer | **$0.00** (Free Tier) |
| **AWS Lambda** | 1M free requests/mo | 50 bookings + 500 slot checks = 16,500 requests/mo | **$0.00** (Free Tier) |
| **API Gateway** | 1M free HTTP requests/mo | 16,500 requests/mo | **$0.00** (Free Tier) |
| **Neon PostgreSQL** | Free tier includes 1 project / 0.5 GiB RAM / 3 GiB storage | Fits 100% inside Neon free plan | **$0.00** (Free Tier) |
| **CloudWatch Logs** | 5GB free ingestion/mo | ~50MB logs/mo | **$0.00** (Free Tier) |
| **TOTAL** | | | **$0.00 / month** |

*Note: Once out of the AWS Free Tier (after 12 months for S3/CloudFront), the S3 and CloudFront costs for 1.5GB data transfer will be less than $0.15 USD per month.*
