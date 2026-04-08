# Deployment Guide

This guide covers deploying AetherAg Orbit to various cloud platforms.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Environment Variables](#environment-variables)
- [Deployment Options](#deployment-options)
  - [Option 1: Vercel (Frontend) + Railway (Backend)](#option-1-vercel--railway)
  - [Option 2: AWS (Full Stack)](#option-2-aws-full-stack)
  - [Option 3: Google Cloud Platform](#option-3-google-cloud-platform)
  - [Option 4: Docker Compose (VPS)](#option-4-docker-compose-vps)
- [Database Setup](#database-setup)
- [Post-Deployment](#post-deployment)
- [Monitoring](#monitoring)

## Prerequisites

Before deploying, ensure you have:

- [ ] Supabase project set up with migrations applied
- [ ] Mapbox account and access token
- [ ] Docker Hub account (for Docker deployments)
- [ ] Cloud provider account (AWS, GCP, Vercel, etc.)
- [ ] Domain name (optional but recommended)
- [ ] SSL certificates (handled automatically by most platforms)

## Environment Variables

Set up the following environment variables in your deployment platform:

### Frontend (.env)
```bash
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_API_URL=https://your-api-domain.com
NEXT_PUBLIC_MAPBOX_TOKEN=pk.your-mapbox-token
```

### Backend (.env)
```bash
DATABASE_URL=postgresql://user:password@host:5432/dbname
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-service-role-key
SECRET_KEY=your-jwt-secret-key-min-32-chars
CORS_ORIGINS=https://your-frontend-domain.com
```

## Deployment Options

### Option 1: Vercel (Frontend) + Railway (Backend)

**Recommended for**: Quick deployment with minimal configuration

#### Deploy Frontend to Vercel

1. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

2. **Deploy**
   ```bash
   cd apps/web
   vercel --prod
   ```

3. **Configure Environment Variables**
   - Go to Vercel Dashboard → Project → Settings → Environment Variables
   - Add all frontend environment variables
   - Redeploy if needed

4. **Custom Domain** (Optional)
   - Go to Vercel Dashboard → Project → Settings → Domains
   - Add your custom domain and configure DNS

#### Deploy Backend to Railway

1. **Create Railway Project**
   ```bash
   # Install Railway CLI
   npm i -g @railway/cli

   # Login
   railway login

   # Initialize project
   cd apps/api
   railway init
   ```

2. **Deploy**
   ```bash
   railway up
   ```

3. **Configure Environment Variables**
   - Go to Railway Dashboard → Project → Variables
   - Add all backend environment variables

4. **Configure Domain**
   - Railway provides a default domain
   - Add custom domain in Settings → Domains

---

### Option 2: AWS (Full Stack)

**Recommended for**: Production deployments with full control

#### Architecture
- **Frontend**: AWS Amplify or S3 + CloudFront
- **Backend**: ECS Fargate or EC2
- **Database**: RDS PostgreSQL with PostGIS
- **Storage**: S3 for images
- **CDN**: CloudFront

#### Deploy Frontend to AWS Amplify

1. **Connect Repository**
   - Go to AWS Amplify Console
   - Click "New app" → "Host web app"
   - Connect your Git repository
   - Select the `apps/web` directory as root

2. **Build Settings** (amplify.yml)
   ```yaml
   version: 1
   applications:
     - frontend:
         phases:
           preBuild:
             commands:
               - npm ci
           build:
             commands:
               - npm run build --workspace=@aetherag-orbit/web
         artifacts:
           baseDirectory: apps/web/.next
           files:
             - '**/*'
         cache:
           paths:
             - node_modules/**/*
   ```

3. **Environment Variables**
   - Add all frontend environment variables in Amplify Console

#### Deploy Backend to AWS ECS

1. **Create ECR Repository**
   ```bash
   aws ecr create-repository --repository-name aetherag-api
   ```

2. **Build and Push Docker Image**
   ```bash
   # Authenticate Docker to ECR
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

   # Build image
   cd apps/api
   docker build -t aetherag-api .

   # Tag image
   docker tag aetherag-api:latest YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/aetherag-api:latest

   # Push image
   docker push YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/aetherag-api:latest
   ```

3. **Create ECS Cluster**
   ```bash
   aws ecs create-cluster --cluster-name aetherag-cluster
   ```

4. **Create Task Definition** (task-definition.json)
   ```json
   {
     "family": "aetherag-api",
     "networkMode": "awsvpc",
     "requiresCompatibilities": ["FARGATE"],
     "cpu": "1024",
     "memory": "2048",
     "containerDefinitions": [
       {
         "name": "api",
         "image": "YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/aetherag-api:latest",
         "portMappings": [
           {
             "containerPort": 8000,
             "protocol": "tcp"
           }
         ],
         "environment": [
           {"name": "DATABASE_URL", "value": "YOUR_DATABASE_URL"},
           {"name": "SECRET_KEY", "value": "YOUR_SECRET_KEY"}
         ]
       }
     ]
   }
   ```

5. **Create Service**
   ```bash
   aws ecs create-service \
     --cluster aetherag-cluster \
     --service-name aetherag-api-service \
     --task-definition aetherag-api \
     --desired-count 2 \
     --launch-type FARGATE \
     --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}"
   ```

#### Set up RDS PostgreSQL

1. **Create RDS Instance**
   ```bash
   aws rds create-db-instance \
     --db-instance-identifier aetherag-db \
     --db-instance-class db.t3.medium \
     --engine postgres \
     --engine-version 16.1 \
     --master-username postgres \
     --master-user-password YOUR_PASSWORD \
     --allocated-storage 20 \
     --publicly-accessible
   ```

2. **Enable PostGIS**
   ```sql
   -- Connect to database and run:
   CREATE EXTENSION postgis;
   ```

3. **Run Migrations**
   ```bash
   # Update DATABASE_URL to point to RDS
   psql $DATABASE_URL -f supabase/migrations/20240101000000_initial_schema.sql
   psql $DATABASE_URL -f supabase/migrations/20240101000001_rls_policies.sql
   ```

---

### Option 3: Google Cloud Platform

**Recommended for**: ML/AI workloads with GPU support

#### Deploy Frontend to Cloud Run

1. **Build Container**
   ```bash
   gcloud builds submit --tag gcr.io/PROJECT_ID/aetherag-web apps/web
   ```

2. **Deploy to Cloud Run**
   ```bash
   gcloud run deploy aetherag-web \
     --image gcr.io/PROJECT_ID/aetherag-web \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated
   ```

#### Deploy Backend to Cloud Run

1. **Build Container**
   ```bash
   gcloud builds submit --tag gcr.io/PROJECT_ID/aetherag-api apps/api
   ```

2. **Deploy to Cloud Run**
   ```bash
   gcloud run deploy aetherag-api \
     --image gcr.io/PROJECT_ID/aetherag-api \
     --platform managed \
     --region us-central1 \
     --set-env-vars DATABASE_URL=xxx,SECRET_KEY=xxx \
     --allow-unauthenticated
   ```

#### Set up Cloud SQL

1. **Create Instance**
   ```bash
   gcloud sql instances create aetherag-db \
     --database-version=POSTGRES_16 \
     --tier=db-f1-micro \
     --region=us-central1
   ```

2. **Create Database**
   ```bash
   gcloud sql databases create aetherag_orbit --instance=aetherag-db
   ```

3. **Enable PostGIS and Run Migrations**
   ```bash
   gcloud sql connect aetherag-db --user=postgres
   # Then run SQL migrations
   ```

---

### Option 4: Docker Compose (VPS)

**Recommended for**: Self-hosted deployments, full control

#### Set up VPS (DigitalOcean, Linode, etc.)

1. **Provision Server**
   - Ubuntu 22.04 LTS
   - Minimum 4GB RAM, 2 vCPUs
   - 50GB SSD

2. **Install Dependencies**
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y

   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh

   # Install Docker Compose
   sudo apt install docker-compose -y

   # Install Nginx
   sudo apt install nginx -y
   ```

3. **Clone Repository**
   ```bash
   git clone https://github.com/username/aetherag-orbit.git
   cd aetherag-orbit
   ```

4. **Configure Environment**
   ```bash
   cp .env.example .env
   nano .env  # Edit with your values
   ```

5. **Start Services**
   ```bash
   docker-compose up -d
   ```

6. **Configure Nginx** (/etc/nginx/sites-available/aetherag)
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://localhost:3000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }

       location /api {
           proxy_pass http://localhost:8000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

7. **Enable SSL with Let's Encrypt**
   ```bash
   sudo apt install certbot python3-certbot-nginx -y
   sudo certbot --nginx -d your-domain.com
   ```

8. **Enable and Start Nginx**
   ```bash
   sudo ln -s /etc/nginx/sites-available/aetherag /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl restart nginx
   ```

---

## Database Setup

### Supabase (Recommended)

1. **Create Project**
   - Go to https://app.supabase.com
   - Create new project
   - Note the database URL and API keys

2. **Run Migrations**
   ```bash
   # Install Supabase CLI
   npm install -g supabase

   # Link project
   supabase link --project-ref YOUR_PROJECT_REF

   # Push migrations
   supabase db push
   ```

3. **Configure Storage**
   - Go to Storage → New bucket
   - Create `drone-images` bucket
   - Set bucket policies for public read

### Self-Hosted PostgreSQL

If not using Supabase:

1. **Install PostgreSQL with PostGIS**
   ```bash
   sudo apt install postgresql-16 postgresql-16-postgis-3 -y
   ```

2. **Create Database**
   ```bash
   sudo -u postgres psql
   CREATE DATABASE aetherag_orbit;
   \c aetherag_orbit
   CREATE EXTENSION postgis;
   ```

3. **Run Migrations**
   ```bash
   psql -U postgres -d aetherag_orbit -f supabase/migrations/20240101000000_initial_schema.sql
   psql -U postgres -d aetherag_orbit -f supabase/migrations/20240101000001_rls_policies.sql
   ```

---

## Post-Deployment

### 1. Verify Deployment

```bash
# Check frontend
curl https://your-domain.com

# Check API
curl https://your-domain.com/api/health

# Check database connection
curl https://your-domain.com/api/v1/drones
```

### 2. Set up Monitoring

#### Application Monitoring
- Set up Sentry for error tracking
- Configure logging with CloudWatch (AWS) or Cloud Logging (GCP)

#### Infrastructure Monitoring
- Set up uptime monitoring (UptimeRobot, Pingdom)
- Configure alerts for high CPU/memory usage
- Monitor database performance

### 3. Configure Backups

#### Database Backups
```bash
# Automated daily backups
0 2 * * * pg_dump -U postgres aetherag_orbit > /backups/db_$(date +\%Y\%m\%d).sql
```

#### Application Backups
- Enable automated backups on cloud provider
- Store backups in S3 or Cloud Storage

### 4. Security Checklist

- [ ] SSL/TLS enabled on all endpoints
- [ ] Environment variables secured
- [ ] Database connections use SSL
- [ ] CORS properly configured
- [ ] Rate limiting enabled
- [ ] Security headers configured
- [ ] Regular security audits scheduled

---

## Monitoring

### Recommended Tools

- **Application Performance**: Sentry, New Relic
- **Uptime Monitoring**: UptimeRobot, Pingdom
- **Infrastructure**: CloudWatch, Datadog, Grafana
- **Logs**: ELK Stack, CloudWatch Logs, Papertrail

### Key Metrics to Monitor

- API response times
- Database query performance
- Error rates
- CPU and memory usage
- Disk usage
- Network traffic
- Drone telemetry data throughput
- AI model inference times

---

## Troubleshooting

### Common Issues

**Frontend not connecting to API**
- Verify NEXT_PUBLIC_API_URL is correct
- Check CORS configuration in backend
- Ensure API is accessible from frontend domain

**Database connection errors**
- Verify DATABASE_URL format
- Check database server is running
- Ensure PostGIS extension is enabled
- Verify network/firewall rules

**AI model errors**
- Ensure model files are present in `models/` directory
- Check sufficient memory/GPU available
- Verify PyTorch/CUDA installation

---

## Support

For deployment issues:
- Check GitHub Issues
- Review deployment logs
- Contact support: [your-email@example.com](mailto:your-email@example.com)

---

Last updated: 2024-01-01
