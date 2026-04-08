# Deployment Guide

This guide covers deploying all components of the Drone Crop Swarm application.

## Prerequisites

Before deploying, ensure you have:

1. Node.js 20+ installed
2. Accounts created on:
   - [Vercel](https://vercel.com)
   - [Fly.io](https://fly.io)
   - [Supabase](https://supabase.com)
   - [Stripe](https://stripe.com)
   - [PostHog](https://posthog.com)
   - [Sentry](https://sentry.io)

## 1. Vercel Web Deployment

Deploy the Next.js application to Vercel's global edge network.

### Setup

```bash
# Install dependencies
npm install

# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login
```

### Configure Environment Variables

Set the following environment variables in your Vercel project:

```bash
vercel env add NEXT_PUBLIC_SUPABASE_URL
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY
vercel env add SUPABASE_SERVICE_ROLE_KEY
vercel env add STRIPE_SECRET_KEY
vercel env add NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
vercel env add STRIPE_WEBHOOK_SECRET
vercel env add NEXT_PUBLIC_POSTHOG_KEY
vercel env add NEXT_PUBLIC_POSTHOG_HOST
vercel env add SENTRY_DSN
vercel env add SENTRY_AUTH_TOKEN
```

### Deploy

```bash
# Deploy to production
npm run deploy:web

# Deploy preview
npm run deploy:web:preview
```

The application will be available at your Vercel domain with instant global edge deployment.

## 2. Fly.io GPU Workers

Deploy GPU-accelerated image processing workers.

### Setup

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Login to Fly
flyctl auth login

# Create app
flyctl apps create drone-crop-swarm-gpu
```

### Configure Secrets

```bash
flyctl secrets set SENTRY_DSN="your-sentry-dsn"
flyctl secrets set POSTHOG_KEY="your-posthog-key"
flyctl secrets set POSTHOG_HOST="https://app.posthog.com"
flyctl secrets set SUPABASE_URL="your-supabase-url"
flyctl secrets set SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
```

### Deploy

```bash
# Deploy GPU workers
fly deploy

# Check status
flyctl status

# View logs
flyctl logs
```

## 3. Supabase Database

Set up and deploy the database schema.

### Setup

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref
```

### Deploy Schema

```bash
# Push database migrations
supabase db push

# Verify migrations
supabase db diff
```

### Enable PostGIS

In your Supabase dashboard:
1. Go to Database → Extensions
2. Enable `postgis`
3. Enable `uuid-ossp`

## 4. Stripe Setup

Configure Stripe for automatic revenue.

### Create Product

The application automatically creates:
- A Stripe customer on first user login
- A product "Drone Crop Swarm - Pro Plan"
- A price of $99/month

### Configure Webhook

1. Go to Stripe Dashboard → Developers → Webhooks
2. Add endpoint: `https://your-domain.vercel.app/api/webhooks/stripe`
3. Select events:
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
4. Copy webhook secret and set as `STRIPE_WEBHOOK_SECRET`

## 5. PostHog Analytics

Live monitoring is pre-configured.

### Setup

1. Create a project in PostHog
2. Copy your Project API Key
3. Set as `NEXT_PUBLIC_POSTHOG_KEY`
4. Set host as `NEXT_PUBLIC_POSTHOG_HOST=https://app.posthog.com`

Events tracked:
- User authentication
- Stripe customer creation
- Image processing requests
- Page views and interactions

## 6. Sentry Error Monitoring

Error tracking is pre-wired.

### Setup

1. Create a project in Sentry
2. Copy your DSN
3. Set as `SENTRY_DSN`
4. Create an auth token for releases
5. Set as `SENTRY_AUTH_TOKEN`

All errors are automatically captured from:
- Next.js frontend
- API routes
- GPU workers

## Quick Deploy All

```bash
# 1. Deploy web to Vercel
npm run deploy:web

# 2. Deploy GPU workers to Fly.io
fly deploy

# 3. Deploy database schema
supabase db push
```

## Post-Deployment Checklist

- [ ] Web app is accessible at Vercel URL
- [ ] GPU workers are running on Fly.io
- [ ] Database schema is deployed to Supabase
- [ ] Stripe webhook is configured and receiving events
- [ ] PostHog is receiving analytics events
- [ ] Sentry is receiving error reports
- [ ] First user login creates Stripe customer automatically

## Environment Variables Summary

| Variable | Service | Description |
|----------|---------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase | Your Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase | Public anon key |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase | Service role key (secret) |
| `STRIPE_SECRET_KEY` | Stripe | Secret API key |
| `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` | Stripe | Publishable key |
| `STRIPE_WEBHOOK_SECRET` | Stripe | Webhook signing secret |
| `NEXT_PUBLIC_POSTHOG_KEY` | PostHog | Project API key |
| `NEXT_PUBLIC_POSTHOG_HOST` | PostHog | PostHog host URL |
| `SENTRY_DSN` | Sentry | Data Source Name |
| `SENTRY_AUTH_TOKEN` | Sentry | Auth token for releases |

## Troubleshooting

### Vercel deployment fails
- Check environment variables are set correctly
- Verify build command runs locally: `npm run build`

### Fly.io GPU workers not starting
- Check GPU availability: `flyctl scale show`
- View logs: `flyctl logs`

### Supabase migrations fail
- Ensure PostGIS extension is enabled
- Check for syntax errors: `supabase db lint`

### Stripe webhook not working
- Verify webhook URL is correct
- Check webhook secret is set
- Test with Stripe CLI: `stripe listen --forward-to localhost:3000/api/webhooks/stripe`
