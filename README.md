# Drone Crop Swarm

Advanced drone swarm management and crop monitoring platform with AI-powered analytics.

## 🚀 Quick Start

```bash
# Setup development environment
./scripts/setup.sh

# Start development server
npm run dev
```

## 📦 Deployment

### One-Command Deploy

```bash
./scripts/deploy-all.sh
```

This deploys all services:
1. ✅ **Vercel**: `npm run deploy:web` → instant global edge
2. ✅ **Fly.io GPU workers**: `fly deploy`
3. ✅ **Supabase**: `supabase db push`

### First Revenue

Stripe product is **created automatically on first login**:
- Customer account created
- Product: "Drone Crop Swarm - Pro Plan"
- Price: $99/month
- Webhook integration for subscription management

### Live Monitoring

**PostHog + Sentry** are already wired:
- ✅ User analytics and tracking
- ✅ Error monitoring and alerts
- ✅ Performance monitoring
- ✅ Session replay on errors

## 📖 Documentation

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions.

## 🏗️ Architecture

- **Frontend**: Next.js 14 on Vercel Edge
- **Backend**: Supabase (PostgreSQL + PostGIS + Auth)
- **Workers**: Fly.io GPU instances (A100)
- **Payments**: Stripe
- **Analytics**: PostHog
- **Monitoring**: Sentry

## 🔑 Environment Variables

Copy `.env.example` to `.env.local` and configure:

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Stripe
STRIPE_SECRET_KEY=
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=
STRIPE_WEBHOOK_SECRET=

# PostHog
NEXT_PUBLIC_POSTHOG_KEY=
NEXT_PUBLIC_POSTHOG_HOST=https://app.posthog.com

# Sentry
SENTRY_DSN=
SENTRY_AUTH_TOKEN=
```

## 📂 Project Structure

```
.
├── src/
│   ├── app/              # Next.js app router
│   │   ├── api/          # API routes
│   │   │   ├── onboarding/   # Auto Stripe setup
│   │   │   └── webhooks/     # Stripe webhooks
│   │   ├── layout.tsx    # Root layout (monitoring init)
│   │   └── page.tsx      # Home page
│   └── lib/              # Utilities
│       ├── supabase.ts   # Supabase client
│       ├── stripe.ts     # Stripe integration
│       ├── posthog.ts    # Analytics
│       └── sentry.ts     # Error tracking
├── workers/              # Fly.io GPU workers
│   ├── worker.py         # FastAPI worker
│   ├── Dockerfile        # Worker container
│   └── requirements.txt  # Python deps
├── supabase/
│   ├── config.toml       # Supabase config
│   └── migrations/       # Database schema
├── scripts/
│   ├── deploy-all.sh     # Deploy everything
│   └── setup.sh          # Setup dev environment
├── fly.toml              # Fly.io configuration
├── vercel.json           # Vercel configuration
└── package.json          # Dependencies & scripts
```

## 🧪 Features

- ✅ Multi-tenant farm management with RLS
- ✅ Geospatial drone tracking (PostGIS)
- ✅ GPU-accelerated image processing
- ✅ Automatic Stripe customer creation
- ✅ Real-time analytics with PostHog
- ✅ Error monitoring with Sentry
- ✅ Global edge deployment
- ✅ Auto-scaling GPU workers

## 📝 License

MIT